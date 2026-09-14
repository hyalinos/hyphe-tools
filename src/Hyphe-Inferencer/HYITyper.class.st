"
Typing rules, Sec 3.3.2-3.3.10, plus the reachability walk and Bottom propagation of Sec 3.3.9 (Tasks 7-8). Theta (instance/class vars) is shared across the whole reconstruction run (flow-insensitive, merged via ~ on assign-ivar); Gamma (locals) is a fresh, flow-sensitive Dictionary per method, mutated in place as statements are typed. Wired into a HYISigma as its bodyBlock via asSigmaBodyBlock.
"
Class {
	#name : 'HYITyper',
	#superclass : 'Object',
	#instVars : [
		'sigma',
		'lookup',
		'theta'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'typing' }
HYITyper class >> bottomProducingSelectors [
	"The canonical Bottom-producing family (Sec 3.3.9): error:, subclassResponsibility, shouldNotImplement, notYetImplemented. Deliberately excludes halt/halt: (resumable, not a real dead end) and doesNotUnderstand: (routinely overridden for legitimate proxy/dynamic-dispatch purposes)."

	^ #( #error: #subclassResponsibility #shouldNotImplement #notYetImplemented )
]

{ #category : 'instance creation' }
HYITyper class >> sigma: aSigma definerIndex: aDefinerIndex [
	"Constructor."

	^ self new
		  setSigma: aSigma definerIndex: aDefinerIndex;
		  yourself
]

{ #category : 'typing' }
HYITyper class >> undefinedObjectType [
	"The type of an implicit nil / a method that falls off its end without an explicit return -- Fixed-NS(UndefinedObject)."

	^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'UndefinedObject')
]

{ #category : 'sigma integration' }
HYITyper >> asSigmaBodyBlock [
	"Answers the block HYISigma uses as its bodyBlock -- ignores the sigma argument it's passed (the typer already holds its own reference) and just delegates to reconstructMethod:."

	^ [ :s :key | self reconstructMethod: key ]
]

{ #category : 'typing' }
HYITyper >> compositeSelectorOf: aMessageNode [
	"Answers the message node's own selector -- a thin accessor kept as its own method so callers read as intent, rather than a bare AST accessor."

	^ aMessageNode selector
]

{ #category : 'typing' }
HYITyper >> extractMethodType: aToolsResult [
	"Unwraps a MethodType tau from a single-entry TypeVariant, answering nil for anything else (Cand, Conflict, a two-entry variant, or a variant whose tau isn't a MethodType at all) -- used where a caller specifically needs argTypes, not just the return type."

	(aToolsResult isTypeVariant and: [ aToolsResult isSingle and: [ aToolsResult entries first value isMethodType ] ]) ifTrue: [
		^ aToolsResult entries first value ].
	^ nil
]

{ #category : 'typing' }
HYITyper >> foldBranchUnion: aCollection [
	"Reduces a non-empty collection of TypeResults to one, by repeatedly applying (+) -- used both for reachability's outcome union and for Lookup's Case-4 union of several candidate definers' answers."

	^ aCollection allButFirst inject: aCollection first into: [ :acc :each | acc branchUnion: each ]
]

{ #category : 'typing-support' }
HYITyper >> isBottomProducingStatement: aStatement [
	"Sec 3.3.9: the canonical Bottom-producing family, detected by the reachability walk on a top-level STATEMENT, not a flat search of the body. halt/halt: excluded (resumable); doesNotUnderstand: excluded (routinely overridden); general <Exception>signal: deferred (harder, out of scope here). Cascades are not specially handled -- a bare 'self error: ...; yourself' statement is not detected -- documented simplification, rare in practice."

	^ (aStatement isKindOf: OCMessageNode) and: [ HYITyper bottomProducingSelectors includes: aStatement selector ]
]

{ #category : 'typing' }
HYITyper >> isBranchingSelector: aSymbol [
	"True for the four conditional selectors the branching typing rule (if-expr / if-expr-one-sided) recognizes."

	^ #( #ifTrue:ifFalse: #ifFalse:ifTrue: #ifTrue: #ifFalse: ) includes: aSymbol
]

{ #category : 'reachability' }
HYITyper >> reachabilityOf: statements gamma: g className: cn selector: sel [
	"Walks Stmt* in order. Answers outcomes -> fallsThrough. A top-level ^Expr or a Bottom-producing statement is reachable and terminates (later statements: dead code, excluded entirely). A branching send recurses into EACH branch independently.

	A Bottom-producing statement is deliberately NOT typed for effect: the whole point of detecting it is to avoid the send actually happening, and (critically) a self-send to a real, unstubbed kernel method (e.g. Object>>error:) would otherwise trigger full recursive reconstruction of that method's entire real call graph -- exactly the eager whole-image fan-out Task 5 warns against, and which hung the live image once already while building this. A minor, documented cost: any Gamma side effect inside the discarded statement's arguments is lost (rare in practice for this family)."

	| outcomes idx |
	outcomes := OrderedCollection new.
	idx := 1.
	[ idx <= statements size ] whileTrue: [
			| st isBranch branchInfo |
			st := statements at: idx.
			(st isKindOf: OCReturnNode) ifTrue: [
					outcomes add: (self
							 typeExpr: st value
							 gamma: g
							 className: cn
							 selector: sel).
					^ outcomes -> false ].
			(self isBottomProducingStatement: st) ifTrue: [
					outcomes add: HYIBottom value.
					^ outcomes -> false ].
			isBranch := (st isKindOf: OCMessageNode) and: [
				            (self isBranchingSelector: st selector) and: [ st arguments allSatisfy: [ :a | a isKindOf: OCBlockNode ] ] ].
			isBranch
				ifTrue: [
						branchInfo := self
							              reachabilityOfBranchingStatement: st
							              gamma: g
							              className: cn
							              selector: sel.
						outcomes addAll: branchInfo key.
						branchInfo value ifFalse: [ ^ outcomes -> false ] ]
				ifFalse: [
						self
							typeStatementForEffect: st
							gamma: g
							className: cn
							selector: sel ].
			idx := idx + 1 ].
	^ outcomes -> true
]

{ #category : 'reachability' }
HYITyper >> reachabilityOfBranchingStatement: aNode gamma: g className: cn selector: sel [
	"A branching statement (its own value discarded) terminates only if EVERY branch terminates. Gamma afterward merges only the branches that fall through -- a terminating branch''s last Gamma is moot, control never continues from there."

	| blocks branchGammas results fallingGammas anyFallsThrough allOutcomes |
	blocks := aNode arguments.
	branchGammas := blocks collect: [ :b | g copy ].
	results := OrderedCollection new.
	blocks with: branchGammas do: [ :b :bg |
			results add: (self
					 reachabilityOf: b body statements
					 gamma: bg
					 className: cn
					 selector: sel) ].
	blocks size = 1 ifTrue: [
			branchGammas := branchGammas , (Array with: g copy).
			results add: OrderedCollection new -> true ].
	fallingGammas := OrderedCollection new.
	branchGammas with: results do: [ :bg :res | res value ifTrue: [ fallingGammas add: bg ] ].
	fallingGammas isEmpty ifFalse: [
		g keys do: [ :k | g at: k put: (self foldBranchUnion: (fallingGammas collect: [ :bg | bg at: k ])) ] ].
	anyFallsThrough := results anySatisfy: [ :r | r value ].
	allOutcomes := OrderedCollection new.
	results do: [ :r | allOutcomes addAll: r key ].
	^ allOutcomes -> anyFallsThrough
]

{ #category : 'reconstruction' }
HYITyper >> reconstructMethod: aKey [
	"Sec 3.3.9: Sigma(C,m) := (+) of all reachable outcomes' types (or Fixed-S(self) if none). Resolves the open question at the end of Sec 3.3.9 (a branch can fall through while a sibling has an explicit ^) by treating a top-level fall-through as ONE MORE outcome (implicit Fixed-S(self)), not an all-or-nothing fallback that only applies when the whole set is empty.

	Answers a bare return-type TypeResult, NOT a MethodType-wrapped one -- Sigma's cell VALUE stays return-type-shaped throughout (matching Lookup's one consistent assumption); HYISigma>>computeCell: is where a real tool's fuller MethodType (Sec 3.3.2) gets reconciled down to its returnType before merging, since Gamma-zero seeding (toolsOnlyFor:) is the one place that genuinely needs the argTypes, not the cell value at large."

	| cn sel behavior cm ast gamma outcomeInfo outcomes |
	cn := aKey className.
	sel := aKey selector.
	behavior := HYIExpander resolveClassNamed: cn.
	behavior ifNil: [ ^ HYITypeVariant unknown ].
	(behavior includesSelector: sel) ifFalse: [ ^ HYITypeVariant unknown ].
	cm := behavior >> sel.
	ast := [ cm ast ]
		       on: Error
		       do: [ :e | nil ].
	ast ifNil: [ ^ HYITypeVariant unknown ].
	gamma := Dictionary new.
	self seedArguments: ast gamma: gamma forKey: aKey.
	outcomeInfo := [
		               self
			               reachabilityOf: ast body statements
			               gamma: gamma
			               className: cn
			               selector: sel ]
		               on: Error
		               do: [ :e | OrderedCollection new -> true ].
	outcomes := outcomeInfo key.
	outcomeInfo value ifTrue: [ outcomes := outcomes copyWith: (HYITypeVariant fixedS: HYISelfRef value) ].
	outcomes isEmpty ifTrue: [ ^ HYITypeVariant fixedS: HYISelfRef value ].
	^ self foldBranchUnion: outcomes
]

{ #category : 'seeding' }
HYITyper >> seedArguments: ast gamma: g forKey: aKey [
	"Gamma-zero(x) = dom(Sigma(C,sel))(i) for the i-th method argument (Sec 3.3.2) -- sourced from R_tools'' own MethodType, since Sigma(C,sel) itself is the very cell being computed. Falls back to Unknown(Top) when the tools have no argument-typed MethodType to offer."

	| toolsResult mt |
	toolsResult := sigma toolsOnlyFor: aKey.
	mt := self extractMethodType: toolsResult.
	ast arguments doWithIndex: [ :argNode :i |
			| argType wrapped |
			argType := (mt notNil and: [ i <= mt argTypes size ])
				           ifTrue: [ mt argTypes at: i ]
				           ifFalse: [ nil ].
			wrapped := argType
				           ifNil: [ HYITypeVariant unknown ]
				           ifNotNil: [ self wrapArgType: argType stability: toolsResult entries first key ].
			g at: argNode name asSymbol put: wrapped ]
]

{ #category : 'private' }
HYITyper >> setSigma: aSigma definerIndex: aDefinerIndex [
	"Private initializer, called only from the class-side constructor -- also builds this typer's own Lookup (sharing the same Sigma/DefinerIndex) and a fresh, empty Theta."

	sigma := aSigma.
	lookup := HYILookup sigma: aSigma definerIndex: aDefinerIndex.
	theta := Dictionary new
]

{ #category : 'typing-support' }
HYITyper >> startClassForSend: aReceiverNode currentClass: cn [
	"super is a purely syntactic marker on THIS send -- not recoverable from a type alone, since super and self carry the identical type Fixed-S(Self) (Sec 3.3.4). Any other receiver whose TYPE happens to be Fixed-S(Self) (a self-send, or a chain from one) starts from the current class C."

	(aReceiverNode isKindOf: OCVariableNode) ifTrue: [
		aReceiverNode variable isSuperVariable ifTrue: [ ^ self superclassNameOf: cn ] ].
	^ cn
]

{ #category : 'typing-support' }
HYITyper >> superclassNameOf: cn [
	"Precondition: superclass(C) exists -- else a static-diagnostic error, out of scope (Sec 3.3.1). Falls back to nil, which lookupFrom: turns into Unknown(Top) rather than raising, since this reconstructor has no separate diagnostic channel yet (Task 11)."

	| behavior sup |
	behavior := HYIExpander resolveClassNamed: cn.
	behavior ifNil: [ ^ nil ].
	sup := behavior superclass.
	sup ifNil: [ ^ nil ].
	^ sup name asString
]

{ #category : 'typing' }
HYITyper >> typeAssignment: aNode gamma: g className: cn selector: sel [
	"assign-local / assign-ivar (Sec 3.3.3): types the right-hand side first, then either merges it into Theta's bucket for cn (ivar/class-var assignment -- via ~, so multiple writer methods on the same class accumulate evidence) or overwrites Gamma outright (local assignment, flow-sensitive, no merge)."

	| v name r |
	r := self
		     typeExpr: aNode value
		     gamma: g
		     className: cn
		     selector: sel.
	v := aNode variable variable.
	name := aNode variable name asSymbol.
	(v isInstanceVariable or: [ v isClassVariable ])
		ifTrue: [
				| bucket old |
				bucket := theta at: cn ifAbsentPut: [ Dictionary new ].
				old := bucket at: name ifAbsentPut: [ HYITypeVariant unknown ].
				bucket at: name put: old ~ r ]
		ifFalse: [ g at: name put: r ].
	^ r
]

{ #category : 'typing' }
HYITyper >> typeBlock: aNode gamma: g className: cn selector: sel [
	"Ordinary block construction. Pinned default: non-local ^ inside a block is not analysed -- treated as Top. Gamma has no nesting (pinned default): the block gets a FRESH scope with only its own params (Unknown(Top)); outer locals are not visible (a captured read yields Top per the pinned default), except ivars/self, which are not scoped by Gamma at all."

	| blockGamma argTypes retType stmts |
	aNode containsReturn ifTrue: [
		^ HYITypeVariant fixedNS: (HYIBlockType argTypes: (aNode arguments collect: [ :a | HYITop value ]) returnType: HYITop value) ].
	blockGamma := Dictionary new.
	aNode arguments do: [ :a | blockGamma at: a name asSymbol put: HYITypeVariant unknown ].
	argTypes := aNode arguments collect: [ :a | HYITop value ].
	stmts := aNode body statements.
	stmts isEmpty
		ifTrue: [ retType := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'UndefinedObject') ]
		ifFalse: [
				stmts allButLast do: [ :st |
						self
							typeStatementForEffect: st
							gamma: blockGamma
							className: cn
							selector: sel ].
				retType := self
					           typeValueOfStatement: stmts last
					           gamma: blockGamma
					           className: cn
					           selector: sel ].
	^ HYITypeVariant fixedNS: (HYIBlockType argTypes: argTypes returnType: retType)
]

{ #category : 'typing' }
HYITyper >> typeBranchValue: aBlockNode gamma: g className: cn selector: sel [
	"The VALUE of one branch block in expression position -- blocks in branch position are looked through (Sec 3.3.7): no fresh scope, the CURRENT gamma is used and mutated directly (unlike an ordinary block value, Sec 3.3.10). g here is already a branch-local copy made by the caller."

	| stmts |
	stmts := aBlockNode body statements.
	stmts isEmpty ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'UndefinedObject') ].
	stmts allButLast do: [ :st |
			self
				typeStatementForEffect: st
				gamma: g
				className: cn
				selector: sel ].
	^ self
		  typeValueOfStatement: stmts last
		  gamma: g
		  className: cn
		  selector: sel
]

{ #category : 'typing' }
HYITyper >> typeBranchingValue: aNode gamma: g className: cn selector: sel [
	"if-expr / if-expr-one-sided, Sec 3.3.7: the branching send''s value is R1 (+) R2, and Gamma afterward is the branch-wise (+) (not the Gamma of whichever branch was typed last) -- Sec 3.3.7's explicit decision."

	| blocks branchGammas branchResults keys |
	blocks := aNode arguments.
	branchGammas := blocks collect: [ :b | g copy ].
	branchResults := OrderedCollection new.
	blocks with: branchGammas do: [ :b :bg |
			branchResults add: (self
					 typeBranchValue: b
					 gamma: bg
					 className: cn
					 selector: sel) ].
	blocks size = 1 ifTrue: [
			branchGammas := branchGammas , (Array with: g copy).
			branchResults add: self class undefinedObjectType ].
	keys := g keys.
	keys do: [ :k | g at: k put: (self foldBranchUnion: (branchGammas collect: [ :bg | bg at: k ])) ].
	^ self foldBranchUnion: branchResults
]

{ #category : 'typing' }
HYITyper >> typeCascade: aNode gamma: g className: cn selector: sel [
	"Cascade (Sec 3.3.6): types every cascaded message's arguments (for their Gamma/Theta side effects), but only the LAST message's Lookup result becomes the cascade's own type -- matches real cascade semantics, where only the final message's return value is what the whole expression evaluates to."

	| receiverType startClass result |
	receiverType := self
		                typeExpr: aNode receiver
		                gamma: g
		                className: cn
		                selector: sel.
	startClass := (receiverType isTypeVariant and: [ receiverType isSingle and: [ receiverType entries first value isSelfRef ] ])
		              ifTrue: [ self startClassForSend: aNode receiver currentClass: cn ]
		              ifFalse: [ nil ].
	aNode messages do: [ :m |
			m arguments do: [ :a |
					self
						typeExpr: a
						gamma: g
						className: cn
						selector: sel ].
			result := lookup lookup: receiverType selector: m selector startClass: startClass ].
	^ result
]

{ #category : 'typing' }
HYITyper >> typeExpr: aNode gamma: g className: cn selector: sel [
	"Dispatch over the simplified grammar''s Expr productions, Sec 2.1/3.3.x."

	(aNode isKindOf: OCLiteralValueNode) ifTrue: [ ^ self typeLiteralValue: aNode value ].
	(aNode isKindOf: OCLiteralArrayNode) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Array') ].
	(aNode isKindOf: OCArrayNode) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Array') ].
	(aNode isKindOf: OCVariableNode) ifTrue: [ ^ self typeVariableNode: aNode gamma: g className: cn ].
	(aNode isKindOf: OCAssignmentNode) ifTrue: [
			^ self
				  typeAssignment: aNode
				  gamma: g
				  className: cn
				  selector: sel ].
	(aNode isKindOf: OCBlockNode) ifTrue: [
			^ self
				  typeBlock: aNode
				  gamma: g
				  className: cn
				  selector: sel ].
	(aNode isKindOf: OCCascadeNode) ifTrue: [
			^ self
				  typeCascade: aNode
				  gamma: g
				  className: cn
				  selector: sel ].
	(aNode isKindOf: OCMessageNode) ifTrue: [
			^ self
				  typeMessageSend: aNode
				  gamma: g
				  className: cn
				  selector: sel ].
	^ HYITop value
]

{ #category : 'typing-literals' }
HYITyper >> typeLiteralValue: aRawValue [
	"lit-int-small/large-pos/large-neg, lit-float, lit-string, lit-symbol, lit-char, lit-true, lit-false, lit-nil."

	(aRawValue isKindOf: SmallInteger) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger') ].
	(aRawValue isKindOf: LargePositiveInteger) ifTrue: [
		^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'LargePositiveInteger') ].
	(aRawValue isKindOf: LargeNegativeInteger) ifTrue: [
		^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'LargeNegativeInteger') ].
	(aRawValue isKindOf: Float) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Float') ].
	(aRawValue isKindOf: ScaledDecimal) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'ScaledDecimal') ].
	(aRawValue isKindOf: Symbol) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Symbol') ].
	(aRawValue isKindOf: String) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'String') ].
	(aRawValue isKindOf: Character) ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Character') ].
	aRawValue == true ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'True') ].
	aRawValue == false ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'False') ].
	aRawValue isNil ifTrue: [ ^ HYITypeVariant fixedNS: (HYIStructNominal nominal: 'UndefinedObject') ].
	^ HYITypeVariant fixedNS: (HYIStructNominal nominal: aRawValue class name asString)
]

{ #category : 'typing' }
HYITyper >> typeMessageSend: aNode gamma: g className: cn selector: sel [
	"Entry point for any message send: routes a branching send (ifTrue:/ifFalse:/ifTrue:ifFalse:/ifFalse:ifTrue: with block arguments) to typeBranchingValue:, everything else to the ordinary-send rule."

	| selSym |
	selSym := aNode selector.
	((self isBranchingSelector: selSym) and: [ aNode arguments allSatisfy: [ :a | a isKindOf: OCBlockNode ] ]) ifTrue: [
			^ self
				  typeBranchingValue: aNode
				  gamma: g
				  className: cn
				  selector: sel ].
	^ self
		  typeOrdinarySend: aNode
		  gamma: g
		  className: cn
		  selector: sel
]

{ #category : 'typing' }
HYITyper >> typeOrdinarySend: aNode gamma: g className: cn selector: sel [
	"msg-send / msg-send-keyword / msg-send-super, Sec 3.3.7. Arguments are typed only for their Gamma/Theta side effects and otherwise ignored, per the accepted simplification of Sec 3.3.1 (no TypeVar/apply)."

	| receiverType startClass |
	aNode arguments do: [ :a |
			self
				typeExpr: a
				gamma: g
				className: cn
				selector: sel ].
	receiverType := self
		                typeExpr: aNode receiver
		                gamma: g
		                className: cn
		                selector: sel.
	startClass := (receiverType isTypeVariant and: [ receiverType isSingle and: [ receiverType entries first value isSelfRef ] ])
		              ifTrue: [ self startClassForSend: aNode receiver currentClass: cn ]
		              ifFalse: [ nil ].
	^ lookup lookup: receiverType selector: aNode selector startClass: startClass
]

{ #category : 'typing' }
HYITyper >> typeStatementForEffect: aStatement gamma: g className: cn selector: sel [
	"Types a statement purely for its Gamma/Theta side effects; the value is discarded."

	(aStatement isKindOf: OCReturnNode)
		ifTrue: [
				self
					typeExpr: aStatement value
					gamma: g
					className: cn
					selector: sel ]
		ifFalse: [
				self
					typeExpr: aStatement
					gamma: g
					className: cn
					selector: sel ]
]

{ #category : 'typing' }
HYITyper >> typeValueOfStatement: aStatement gamma: g className: cn selector: sel [
	"The VALUE of the last statement of a value-position block body. Pragmatic simplification: a bare ^ here is a non-local return in value position, which is not analysed (pinned default) -- treated as if it were simply the returned expression''s value, rather than modelled as a real non-local exit."

	(aStatement isKindOf: OCReturnNode) ifTrue: [
			^ self
				  typeExpr: aStatement value
				  gamma: g
				  className: cn
				  selector: sel ].
	^ self
		  typeExpr: aStatement
		  gamma: g
		  className: cn
		  selector: sel
]

{ #category : 'typing' }
HYITyper >> typeVariableNode: aNode gamma: g className: cn [
	"var-local / var-ivar / var-self / var-super (Sec 3.3.4): self and super both answer Fixed-S(Self); an instance or class variable reads Theta's bucket for cn (Unknown if never yet written); an AST node the compiler itself couldn't resolve (OCUnresolvedVariable, e.g. a global read) answers bare Top rather than guessing; anything else is an ordinary local, read from Gamma."

	| v name |
	v := aNode variable.
	(v isSelfVariable or: [ v isSuperVariable ]) ifTrue: [ ^ HYITypeVariant fixedS: HYISelfRef value ].
	name := aNode name asSymbol.
	(v isInstanceVariable or: [ v isClassVariable ]) ifTrue: [
		^ (theta at: cn ifAbsentPut: [ Dictionary new ]) at: name ifAbsentPut: [ HYITypeVariant unknown ] ].
	(v isKindOf: OCUnresolvedVariable) ifTrue: [ ^ HYITop value ].
	^ g at: name ifAbsentPut: [ HYITypeVariant unknown ]
]

{ #category : 'typing' }
HYITyper >> wrapArgType: aTau stability: aStability [
	"Wraps one argument's tau with a Stability tag for seeding Gamma-zero -- a bare Top always wraps Unknown regardless of the stability given, matching Task 1's invariant."

	aTau isTop ifTrue: [ ^ HYITypeVariant unknown ].
	^ HYITypeVariant tau: aTau stability: aStability
]
