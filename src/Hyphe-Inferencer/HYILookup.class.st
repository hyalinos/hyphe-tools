"
Message-send lookup, Sec 3.3.1: goes from a receiver's TypeResult to a MethodType TypeResult for a selector, via the 4 documented cases plus target/startClass/substSelf and the min-tag rule. Combines Task 4's Sigma, Task 5's HYIExpander/HYIDefinerIndex, and Task 2's ~ is NOT used here (lookup collects candidates, it does not merge evidence about them).
"
Class {
	#name : 'HYILookup',
	#superclass : 'Object',
	#instVars : [
		'sigma',
		'definerIndex'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'typing-support' }
HYILookup class >> extractReturnType: aTypeResult [
	"Sigma cells are conceptually a MethodType (Sec 3.3.2's settled decision: 'Sigma holds a MethodType, not a bare return type'), but Lookup only ever consumes the RETURN portion (argument types are read only once, in Gamma-zero seeding, Sec 3.3.2 -- Lookup's own accepted simplification never reads them again). Unwraps .returnType when a cell's tau is actually an HYIMethodType; a cell whose tau is already a plain return type (a stub or an adapter that hasn't been updated to the MethodType shape) passes through unchanged, for backward compatibility."

	| rebuild |
	rebuild := [ :tau |
		           tau isMethodType
			           ifTrue: [ tau returnType ]
			           ifFalse: [ tau ] ].
	aTypeResult isTypeVariant ifFalse: [ ^ aTypeResult ].
	aTypeResult isSingle ifTrue: [
		^ HYITypeVariant tau: (rebuild value: aTypeResult entries first value) stability: aTypeResult entries first key ].
	^ HYITypeVariant
		  tau: (rebuild value: aTypeResult entries first value)
		  stability: aTypeResult entries first key
		  tau: (rebuild value: aTypeResult entries last value)
		  stability: aTypeResult entries last key
]

{ #category : 'instance creation' }
HYILookup class >> sigma: aSigma definerIndex: aDefinerIndex [
	"Constructor -- wires Lookup to the Sigma store it will query and the whole-image selector->definers index it needs for Case 3/self-send resolution."

	^ self new
		  setSigma: aSigma definerIndex: aDefinerIndex;
		  yourself
]

{ #category : 'substitution' }
HYILookup class >> substSelfResult: aTypeResult target: aClassName [
	"target = #Self is a genuine no-op: a self/super-send whose receiver is already Fixed-S(Self) leaves the fetched entry's own Self-references unresolved, propagating the not-yet-known dynamic class onward -- Sec 3.3.1's note that a super-send's substitution target stays Self."

	| newEntries |
	aClassName = #Self ifTrue: [ ^ aTypeResult ].
	aTypeResult isTypeVariant ifTrue: [
			newEntries := aTypeResult entries collect: [ :e | e key -> (self substSelfType: e value target: aClassName) ].
			newEntries size = 1 ifTrue: [ ^ HYITypeVariant tau: newEntries first value stability: newEntries first key ].
			^ HYITypeVariant
				  tau: newEntries first value
				  stability: newEntries first key
				  tau: newEntries last value
				  stability: newEntries last key ].
	aTypeResult isConflict ifTrue: [
			^ HYIConflict
				  left: (self substSelfType: aTypeResult left target: aClassName)
				  right: (self substSelfType: aTypeResult right target: aClassName) ].
	aTypeResult isCand ifTrue: [
		^ HYICand with: (aTypeResult hypotheses collect: [ :h | self substSelfResult: h target: aClassName ]) ].
	^ aTypeResult
]

{ #category : 'substitution' }
HYILookup class >> substSelfType: aType target: aClassName [
	"Sec 3.3.1: substSelf(R,target), recursively, incl. nested Method/BlockType. Operates on tau. #Self as target is deliberately not handled here -- callers short-circuit that case in substSelfResult:target: (a genuine no-op, Sec 3.3.1's note that a super-send's target STAYS Self)."

	aType isSelfRef ifTrue: [ ^ HYIStructNominal nominal: aClassName ].
	aType isSelfClassRef ifTrue: [ ^ HYIStructNominal nominal: aClassName , ' class' ].
	aType isUnion ifTrue: [
		^ HYIUnion left: (self substSelfType: aType left target: aClassName) right: (self substSelfType: aType right target: aClassName) ].
	aType isGeneric ifTrue: [
			^ HYIGeneric
				  base: (self substSelfType: aType base target: aClassName)
				  params: (aType params collect: [ :p | self substSelfType: p target: aClassName ]) ].
	aType isMethodType ifTrue: [
			^ HYIMethodType
				  argTypes: (aType argTypes collect: [ :a | self substSelfType: a target: aClassName ])
				  returnType: (self substSelfType: aType returnType target: aClassName) ].
	aType isBlockType ifTrue: [
			^ HYIBlockType
				  argTypes: (aType argTypes collect: [ :a | self substSelfType: a target: aClassName ])
				  returnType: (self substSelfType: aType returnType target: aClassName) ].
	aType isStructNominal ifTrue: [
			^ HYIStructNominal
				  selectors: (aType selectors collect: [ :mt | self substSelfType: mt target: aClassName ])
				  nominal: aType nominal ].
	^ aType
]

{ #category : 'private' }
HYILookup >> candidateClassesOf: aTau [
	"Flattens aTau into its nominal-bearing members (a single StructNominal, or the members of a union), silently dropping non-nominal members (e.g. Bottom mixed in from an earlier (+)) -- they name no class to look up against."

	| members |
	members := aTau isUnion
		           ifTrue: [ aTau members ]
		           ifFalse: [ Array with: aTau ].
	^ members select: [ :m | m isStructNominal and: [ m nominal notNil ] ]
]

{ #category : 'private' }
HYILookup >> collapseReceiver: aTypeVariant [
	"Reduces a (possibly double-tag) receiver TypeVariant to one canonical Stability->tau pair, reusing the exact rule Task 3's (+) already uses for the same purpose (min the stabilities, union the tau payloads)."

	^ HYITypeResult collapseToSinglePair: aTypeVariant
]

{ #category : 'lookup' }
HYILookup >> lookup: R_a selector: sel startClass: startClassOrNil [
	"Sec 3.3.1's four cases, dispatched by the shape of R_a. Two additions beyond the four documented cases: a bare Bottom receiver short-circuits per Sec 3.3.9's propagation table (the send never occurs); a Cand receiver (e.g. from an earlier ambiguous lookup feeding a chained send) distributes the same way Conflict does -- flagged extension, needed for totality."

	| pair stability tau candidates |
	R_a isBottom ifTrue: [ ^ HYIBottom value ].
	R_a isConflict ifTrue: [ ^ self lookupConflictReceiver: R_a selector: sel ].
	R_a isCand ifTrue: [ ^ HYICand with: (R_a hypotheses collect: [ :h | self lookup: h selector: sel startClass: startClassOrNil ]) ].
	(R_a isTypeVariant and: [ R_a isSingle and: [ R_a entries first key isUnknown ] ]) ifTrue: [ ^ self lookupUnknownReceiver: sel ].
	pair := self collapseReceiver: R_a.
	stability := pair key.
	tau := pair value.
	tau isSelfRef ifTrue: [
			startClassOrNil ifNil: [ ^ self error: 'lookup:selector:startClass: needs a startClass for a self/super receiver' ].
			^ self weaken: (self lookupFrom: startClassOrNil selector: sel substTarget: #Self) by: stability ].
	candidates := self candidateClassesOf: tau.
	candidates isEmpty ifTrue: [ ^ HYITypeVariant unknown ].
	candidates size = 1 ifTrue: [ ^ self weaken: (self lookupSingleClass: candidates first nominal selector: sel) by: stability ].
	^ HYICand with: (candidates collect: [ :c | self weaken: (self lookupSingleClass: c nominal selector: sel) by: stability ])
]

{ #category : 'lookup' }
HYILookup >> lookupConflictReceiver: aConflict selector: sel [
	"Case 4, Sec 3.3.1: a Conflict receiver is a union of its members -- each side's own class is looked up independently and the two hypotheses are collected (not merged with ~). Logs the dissolution to HYIDiagnostics (Task 11) -- once collected into a Cand, the fact that this started as a genuine contradiction is otherwise unrecoverable (Sec 3.3.1's own open question about this)."

	HYIDiagnostics log: 'Conflict receiver ' , aConflict printString , ' dissolved into a Cand for selector #' , sel.
	^ HYICand with: (Array
			   with: (self lookupSingleClass: aConflict left nominal selector: sel)
			   with: (self lookupSingleClass: aConflict right nominal selector: sel))
]

{ #category : 'lookup' }
HYILookup >> lookupFrom: startClassName selector: sel substTarget: targetNameOrSelfSymbol [
	"General per-candidate primitive: N' = nearest ancestor of startClassName (or itself) defining sel; R = Sigma(N',sel); substSelf(R, target). Search-start and substitution target are DIFFERENT quantities in general (only coincide when the receiver names a concrete class outright) -- see the self/super case in lookup:selector:startClass:, where the search starts at C or superclass(C) but the target stays the symbolic #Self."

	| definer key raw |
	definer := HYIExpander nearestDefinerOf: startClassName selector: sel.
	definer ifNil: [ ^ HYITypeVariant unknown ].
	key := HYISigmaKey class: definer selector: sel.
	raw := HYILookup extractReturnType: (sigma reconstruct: key).
	^ HYILookup substSelfResult: raw target: targetNameOrSelfSymbol
]

{ #category : 'lookup' }
HYILookup >> lookupSingleClass: aClassName selector: sel [
	"The common case: the receiver names a concrete class outright, so the search-start and the substitution target coincide (target(R_a) = N)."

	^ self lookupFrom: aClassName selector: sel substTarget: aClassName
]

{ #category : 'lookup' }
HYILookup >> lookupUnknownReceiver: sel [
	"Case 3, Sec 3.3.1: AllDefiners(sel) = every class in program+kernel defining sel. Width-capped at the same N=8 as Sigma's widening (pinned default, AGENT_BRIEF.md) -- otherwise this is the case that makes the inferencer unusable per Task 5's own warning."

	| definers |
	definers := definerIndex allDefiners: sel.
	definers isEmpty ifTrue: [ ^ HYITypeVariant unknown ].
	definers size > HYISigma widthCap ifTrue: [ ^ HYITypeVariant unknown ].
	definers size = 1 ifTrue: [
			^ HYILookup
				  substSelfResult: (HYILookup extractReturnType: (sigma reconstruct: (HYISigmaKey class: definers first selector: sel)))
				  target: definers first ].
	^ HYICand with: (definers collect: [ :n |
			   HYILookup
				   substSelfResult: (HYILookup extractReturnType: (sigma reconstruct: (HYISigmaKey class: n selector: sel)))
				   target: n ])
]

{ #category : 'private' }
HYILookup >> setSigma: aSigma definerIndex: aDefinerIndex [
	"Private initializer, called only from the class-side constructor."

	sigma := aSigma.
	definerIndex := aDefinerIndex
]

{ #category : 'weakening' }
HYILookup >> weaken: aTypeResult by: aReceiverStability [
	"A send's tag is never stronger than the weaker of the receiver's tag and the found entry's tag (Sec 3.3.1). Conflict/Cand/bare Top/Bottom pass through unweakened -- they carry no single scalar tag to weaken. Logs to HYIDiagnostics (Task 11) whenever a tag is actually lowered."

	| weakened survivors anyLowered |
	aTypeResult isTypeVariant ifFalse: [ ^ aTypeResult ].
	weakened := aTypeResult entries collect: [ :e | self weakenEntry: e by: aReceiverStability ].
	anyLowered := false.
	weakened with: aTypeResult entries do: [ :w :orig | w key = orig key ifFalse: [ anyLowered := true ] ].
	anyLowered ifTrue: [
		HYIDiagnostics log: 'tag lowered: ' , aTypeResult printString , ' by receiver stability ' , aReceiverStability printString ].
	survivors := weakened reject: [ :e | e key isUnknown ].
	survivors isEmpty ifTrue: [ ^ HYITypeVariant unknown ].
	survivors size = 1 ifTrue: [ ^ HYITypeVariant tau: survivors first value stability: survivors first key ].
	^ HYITypeVariant
		  tau: survivors first value
		  stability: survivors first key
		  tau: survivors last value
		  stability: survivors last key
]

{ #category : 'weakening' }
HYILookup >> weakenEntry: anAssociation by: aReceiverStability [
	"The min-tag rule (Sec 3.3.1) applied to one (Stability,tau) entry: a lookup path that was itself less certain than the tag it found lowers that tag to match -- e.g. a Fixed-S(a) answer found via an already-Observed receiver weakens to Observed(a). If the min collapses to Unknown, the tau is discarded too (Unknown only ever pairs with bare Top)."

	| newStability |
	newStability := HYIStability min: anAssociation key with: aReceiverStability.
	newStability isUnknown ifTrue: [ ^ HYIUnknown value -> HYITop value ].
	^ newStability -> anAssociation value
]
