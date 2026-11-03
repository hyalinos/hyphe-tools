"
Tests of the builder on unusual code (blocks in variables, case of, returns with expressions), of the nesting depth and block contexts, and of the invariants of the CFG on many real methods.
"
Class {
	#name : 'HyCFGBuilderRobustnessTest',
	#superclass : 'HyCFGAbstractTest',
	#category : 'Hyphe-CFG-Tests-Builder',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Builder'
}

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testBlockArgumentOfAnUnknownMessageIsNested [
	"A block given to an ordinary message is analysed in place, one level deeper"

	| cfg inner |
	cfg := self cfgForBody: 'self foo: [ self bar ]'.
	inner := self nodeSending: #bar in: cfg.

	self assert: (self nodeSending: #foo: in: cfg) nestingDepth equals: 0.
	self assert: inner nestingDepth equals: 1.
	self assert: (inner isKindOf: HyCFGBlockScopeNode).
	self assert: cfg maxNestingDepth equals: 1
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testBlockContext [
	"A block scope node knows the block it belongs to, a statement of the method has none"

	| cfg inner |
	cfg := self cfgForBody: 'x ifTrue: [ self inner ]. self outer'.
	inner := self nodeSending: #inner in: cfg.

	self assert: inner blockContext isBlock.
	self assert: inner blockContext statements first == inner astNode.
	self assert: ((self nodeSending: #outer in: cfg) isKindOf: HyCFGStatementNode)
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testBlockInAVariableMakesAConditionalIncomplete [
	"x ifTrue: aBlock: the code of the branch is unknown, the node is flagged and the CFG stays well formed"

	| cfg conditional |
	cfg := self cfgForBody: 'x ifTrue: aBlock'.
	conditional := self nodeSending: #ifTrue: in: cfg.

	self deny: cfg isComplete.
	self assert: cfg incompleteNodes asArray equals: { conditional }.
	self assert: (self edgeFrom: conditional to: cfg exitNode in: cfg) class equals: HyCFGTrueEdge.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testBuildFromACompiledMethod [
	"A CompiledMethod is accepted, its AST is used"

	| cfg |
	cfg := HyCFGBuilder buildFrom: HyCFGNode >> #isTerminal.

	self assert: cfg methodNode selector equals: #isTerminal.
	self assert: cfg nodes size equals: 3
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testBuildFromAReflectiveMethod [
	"A method with a MetaLink (what happens when measuring the coverage) is a ReflectiveMethod, not a CompiledMethod: its AST is used just the same"

	| cfg |
	cfg := HyCFGBuilder buildFrom: (ReflectiveMethod on: HyCFGNode >> #isTerminal).

	self assert: cfg methodNode selector equals: #isTerminal.
	self assert: cfg nodes size equals: 3
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testCaseOf [
	"x caseOf: { [ a ] -> [ ... ] ... }: a true edge per case, a false edge to the code after when no case matches"

	| cfg header |
	cfg := self cfgForBody: 'x caseOf: { [ 1 ] -> [ self one ]. [ 2 ] -> [ self two ] }'.
	header := self nodeSending: #caseOf: in: cfg.

	self assert: cfg nodes size equals: 5.
	self assert: (self edgeFrom: header to: (self nodeSending: #one in: cfg) in: cfg) class equals: HyCFGTrueEdge.
	self assert: (self edgeFrom: header to: (self nodeSending: #two in: cfg) in: cfg) class equals: HyCFGTrueEdge.
	self assert: (self edgeFrom: header to: cfg exitNode in: cfg) class equals: HyCFGFalseEdge.
	self assert: cfg isComplete.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testCaseOfOtherwise [
	"The otherwise block is the false branch"

	| cfg header |
	cfg := self cfgForBody: 'x caseOf: { [ 1 ] -> [ self one ] } otherwise: [ self other ]'.
	header := self nodeSending: #caseOf:otherwise: in: cfg.

	self assert: (self edgeFrom: header to: (self nodeSending: #other in: cfg) in: cfg) class equals: HyCFGFalseEdge.
	self assert: (self edgeFrom: header to: (self nodeSending: #one in: cfg) in: cfg) class equals: HyCFGTrueEdge
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testCaseOfWithCasesInAVariableIsIncomplete [
	"The cases are unknown when they are not a literal { } array"

	| cfg |
	cfg := self cfgForBody: 'x caseOf: cases'.

	self deny: cfg isComplete
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testCaseOfWithSomethingThatIsNotACase [
	"An element of the cases that is not block -> block is unknown code"

	| cfg |
	cfg := self cfgForBody: 'x caseOf: { self foo }'.

	self deny: cfg isComplete
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testCodeAfterAReturnIsNotConnected [
	"Nothing follows a return: the statement after it gets no edge from the exit"

	| cfg |
	cfg := self cfgForFaultyBody: '^ 1. self dead'.

	self assert: cfg exitNode outgoingEdges isEmpty.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testConditionalAfterAReturnIsNotConnectedToTheExit [
	"A conditional after a return does not get an edge from the exit node"

	| cfg |
	cfg := self cfgForFaultyBody: '^ 1. x ifTrue: [ self dead ]'.

	self assert: cfg exitNode outgoingEdges isEmpty.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testEnsureBlockInAVariableMakesTheNodeIncomplete [
	"[ ... ] ensure: aBlock: what runs at the end is unknown"

	| cfg |
	cfg := self cfgForBody: '[ self a ] ensure: aBlock'.

	self deny: cfg isComplete.
	self assertEveryNodeIsReachable: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testEveryRegisteredPatternHasAHandler [
	"Each selector of the registry is mapped to an instance method of the builder that takes one argument (the message node)"

	| builder |
	builder := HyCFGBuilder new.
	HyCFGBuilder patternRegistry keysAndValuesDo: [ :selector :handler |
			self assert: handler numArgs equals: 1 description: selector , ' handler ' , handler.
			self assert: (builder respondsTo: handler) description: selector , ' has no handler ' , handler ]
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testInvariantsOnRealMethods [
	"Build the CFG of every method of a few classes of the image (sequences, dictionaries, the builder itself...): no error, and the invariants of a CFG hold"

	| methods |
	methods := OrderedCollection new.
	{
		HyCFGBuilder.
		HyCFGInspector.
		OrderedCollection.
		SequenceableCollection.
		Dictionary.
		Interval.
		BlockClosure.
		Exception } do: [ :class |
			methods addAll: class methods.
			methods addAll: class class methods ].

	methods do: [ :method | self assertGraphIsConsistent: (HyCFGBuilder buildFrom: method) ].

	self assert: methods size > 500
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testLiteralBlocksAreComplete [
	"A conditional whose branches are literal blocks is complete"

	self assert: (self cfgForBody: 'x ifTrue: [ self a ] ifFalse: [ self b ]') isComplete
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testMethodNodeIsRemembered [
	"The CFG knows the AST it was built from"

	| method cfg |
	method := OCParser parseMethod: 'test ^ 1'.
	cfg := HyCFGBuilder buildFrom: method.

	self assert: cfg methodNode == method
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testNestingDepthIsRestoredAfterABlock [
	"The statement after a block is back at depth 0, even after nested blocks"

	| cfg |
	cfg := self cfgForBody: 'items do: [ :a | others do: [ :b | self use ] ]. self after'.

	self assert: (self nodeSending: #after in: cfg) nestingDepth equals: 0
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testNoTemporalNodeIsLeft [
	"The local entry and exit nodes only help building, whatever the structure"

	#( 'x ifTrue: [ self a ] ifFalse: [ self b ]' 'items do: [ :e | e ifNil: [ ^ 1 ] ]' '[ self a ] on: Error do: [ :e | [ self b ] ensure: [ self c ] ]'
	   '[ self more ] whileTrue: [ x ifTrue: [ self a ] ]' ) do: [ :body | self assertGraphIsConsistent: (self cfgForBody: body) ]
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testPatternRegistryCanBeExtendedAndReset [
	"A new control flow selector can be registered with the selector of its handler; initializePatternRegistry restores the defaults"

	HyCFGBuilder registerPattern: #myLoop: handler: #handleDo:.
	[
		self assert: (HyCFGBuilder isRecognizedPattern: #myLoop:).
		self assert: (HyCFGBuilder handlerFor: #myLoop:) equals: #handleDo:.
		self assert: (self cfgForBody: 'items myLoop: [ :e | self use ]') nodes size equals: 4 ] ensure: [
		HyCFGBuilder initializePatternRegistry ].

	self deny: (HyCFGBuilder isRecognizedPattern: #myLoop:).
	self assert: (HyCFGBuilder isRecognizedPattern: #ifTrue:)
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testPatternRegistryIsCreatedWhenNeeded [
	"The registry is filled the first time it is used, and by the class-side initialize"

	HyCFGBuilder instVarNamed: 'PatternRegistry' put: nil.
	self assert: (HyCFGBuilder isRecognizedPattern: #whileTrue:).

	HyCFGBuilder instVarNamed: 'PatternRegistry' put: nil.
	HyCFGBuilder initialize.
	self assert: (HyCFGBuilder isRecognizedPattern: #on:do:)
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testReadmeExample [
	"The complex example of the inspector documentation: a loop, a conditional, a nested conditional, and an exception handler"

	| cfg |
	cfg := HyCFGBuilder buildFrom: (OCParser parseMethod: 'process: items
	| result |
	result := OrderedCollection new.
	items do: [ :item |
		item isValid ifTrue: [
			result add: item.
			item needsProcessing ifTrue: [
				[ item process ]
					on: Error
					do: [ :ex |
						self logError: ex.
						item markFailed ] ] ] ].
	^ result').

	self assert: cfg isComplete.
	self assert: cfg maxNestingDepth equals: 4.
	self assert: (cfg edgesOfKind: HyCFGExceptionEdge) size equals: 1.
	self assert: (cfg edgesOfKind: HyCFGReturnEdge) size equals: 1.
	self assert: (cfg nodesOfKind: HyCFGControlFlowNode) size equals: 4.
	self assertEveryNodeIsReachable: cfg.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testRecognizedPatterns [
	"Control flow selectors are recognized, ordinary ones are not"

	#( #ifTrue: #whileTrue: #whileTrue #do: #on:do: #ensure: #caseOf: ) do: [ :selector |
		self assert: (HyCFGBuilder isRecognizedPattern: selector) description: selector ].
	self deny: (HyCFGBuilder isRecognizedPattern: #foo:).
	self assert: (HyCFGBuilder handlerFor: #foo:) isNil
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testReturnOfAConditionalValueIsConnected [
	"^ cond ifTrue: [ 1 ] ifFalse: [ 2 ]: the conditional comes first, both branches reach the return"

	| cfg return |
	cfg := self cfgForBody: '^ x ifTrue: [ 1 ] ifFalse: [ 2 ]'.
	return := cfg nodes detect: [ :n | (n isKindOf: HyCFGCodeNode) and: [ n astNode isReturn ] ].

	self assert: return incomingEdges size equals: 2.
	self assertEveryNodeIsReachable: cfg.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testReturnOfAnExpressionIsConnected [
	"^ self foo bar: the sends of the expression come before the return, and nothing is left floating"

	| cfg return |
	cfg := self cfgForBody: '^ self foo bar: 1'.
	return := cfg nodes detect: [ :n | (n isKindOf: HyCFGCodeNode) and: [ n astNode isReturn ] ].

	self assert: cfg nodes size equals: 5.
	self assert: (self edgeFrom: return to: cfg exitNode in: cfg) class equals: HyCFGReturnEdge.
	self assertEveryNodeIsReachable: cfg.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderRobustnessTest >> testTwoUnknownBranches [
	"ifTrue:ifFalse: with two non-block arguments flags both"

	| cfg conditional |
	cfg := self cfgForBody: 'x ifTrue: ''yes'' ifFalse: ''no'''.
	conditional := self nodeSending: #ifTrue:ifFalse: in: cfg.

	self assert: conditional unknownBlockReferences size equals: 2.
	self deny: cfg isComplete
]
