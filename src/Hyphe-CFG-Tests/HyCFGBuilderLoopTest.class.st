"
Tests of the CFG of loops: the header is a control flow node, true edge into the body, back edge from the end of the body to the header, false edge to the code after the loop.
"
Class {
	#name : 'HyCFGBuilderLoopTest',
	#superclass : 'HyCFGAbstractTest',
	#category : 'Hyphe-CFG-Tests-Builder',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Builder'
}

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testBlockInAVariableMakesTheLoopIncomplete [
	"The body of items do: aBlock is unknown: the header is flagged, and drawn as a self loop"

	| cfg header |
	cfg := self cfgForBody: 'items do: aBlock'.
	header := self nodeSending: #do: in: cfg.

	self deny: cfg isComplete.
	self assert: cfg incompleteNodes asArray equals: { header }.
	self assert: header unknownBlockReferences size equals: 1.
	self assert: (self edgeFrom: header to: header in: cfg) isBackEdge
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testCodeAfterALoopIsReachedByTheFalseEdge [
	"The statement that follows a loop is where the false edge goes"

	| cfg header done |
	cfg := self cfgForBody: 'items do: [ :e | self use ]. self done'.
	header := self nodeSending: #do: in: cfg.
	done := self nodeSending: #done in: cfg.

	self assert: (self edgeFrom: header to: done in: cfg) class equals: HyCFGFalseEdge.
	self assert: done nestingDepth equals: 0.
	self assertEveryNodeIsReachable: cfg
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testConditionalAtTheEndOfTheBodyKeepsTheBackEdge [
	"When the last statement of a body is a conditional, both its branches come back to the header"

	| cfg header conditional |
	cfg := self cfgForBody: 'items do: [ :e | e ifTrue: [ self use ] ]'.
	header := self nodeSending: #do: in: cfg.
	conditional := self nodeSending: #ifTrue: in: cfg.

	self assert: (self edgeFrom: (self nodeSending: #use in: cfg) to: header in: cfg) isBackEdge.
	self assert: (self edgeFrom: conditional to: header in: cfg) isBackEdge.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testDetectIfNoneRunsTheIfNoneBlockWhenNothingMatches [
	"The false edge of detect:ifNone: goes through the ifNone block"

	| cfg header ok fail |
	cfg := self cfgForBody: 'items detect: [ :e | self ok ] ifNone: [ self fail ]'.
	header := self nodeSending: #detect:ifNone: in: cfg.
	ok := self nodeSending: #ok in: cfg.
	fail := self nodeSending: #fail in: cfg.

	self assert: cfg nodes size equals: 5.
	self assert: (self edgeFrom: header to: ok in: cfg) class equals: HyCFGTrueEdge.
	self assert: (self edgeFrom: ok to: header in: cfg) isBackEdge.
	self assert: (self edgeFrom: header to: fail in: cfg) class equals: HyCFGFalseEdge.
	self assert: (self edgeFrom: fail to: cfg exitNode in: cfg) class equals: HyCFGSequentialEdge
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testEmptyBodyIsASelfLoop [
	"A loop whose body has no statement goes from its header back to itself"

	| cfg header loop |
	cfg := self cfgForBody: '[ self more ] whileTrue: [ ]'.
	header := self nodeSending: #whileTrue: in: cfg.
	loop := self edgeFrom: header to: header in: cfg.

	self assert: cfg nodes size equals: 3.
	self assert: cfg edges size equals: 3.
	self assert: loop class equals: HyCFGLoopEdge.
	self assert: loop isBackEdge.
	self assert: cfg isComplete.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testIterationMessagesBuildALoop [
	"All the iteration messages have the same shape: header -true-> body -back-> header, header -false-> after"

	#( 'items do: [ :e | self use ]' 'items collect: [ :e | self use ]' 'items select: [ :e | self use ]'
	   'items reject: [ :e | self use ]' 'items detect: [ :e | self use ]' 'items with: others do: [ :a :b | self use ]'
	   'items withIndexDo: [ :e :i | self use ]' 'items inject: 0 into: [ :acc :e | self use ]'
	   '3 timesRepeat: [ self use ]' '1 to: 10 do: [ :i | self use ]' '1 to: 10 by: 2 do: [ :i | self use ]' ) do: [ :body |
			| cfg header use |
			cfg := self cfgForBody: body.
			header := cfg nodes detect: [ :n | n isKindOf: HyCFGControlFlowNode ].
			use := self nodeSending: #use in: cfg.
			self assert: cfg nodes size equals: 4 description: body.
			self assert: (self edgeFrom: header to: use in: cfg) class equals: HyCFGTrueEdge description: body.
			self assert: (self edgeFrom: use to: header in: cfg) isBackEdge description: body.
			self assert: (self edgeFrom: header to: cfg exitNode in: cfg) class equals: HyCFGFalseEdge description: body.
			self assert: cfg isComplete description: body.
			self assertGraphIsConsistent: cfg ]
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testNestedLoops [
	"Nesting depth grows with each block, and the end of the inner loop goes back to the outer header"

	| cfg outer inner use |
	cfg := self cfgForBody: 'items do: [ :a | others do: [ :b | self use ] ]'.
	outer := cfg nodes detect: [ :n | (n isKindOf: HyCFGControlFlowNode) and: [ n nestingDepth = 0 ] ].
	inner := cfg nodes detect: [ :n | (n isKindOf: HyCFGControlFlowNode) and: [ n nestingDepth = 1 ] ].
	use := self nodeSending: #use in: cfg.

	self assert: use nestingDepth equals: 2.
	self assert: cfg maxNestingDepth equals: 2.
	self assert: (self edgeFrom: use to: inner in: cfg) isBackEdge.
	self assert: (self edgeFrom: inner to: outer in: cfg) isBackEdge.
	self assert: (cfg edgesOfKind: HyCFGLoopEdge) size equals: 2.
	self assertEveryNodeIsReachable: cfg.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testReturnInLoopBodyHasNoBackEdge [
	"A body that ends with a return never comes back to the header"

	| cfg |
	cfg := self cfgForBody: 'items do: [ :e | ^ e ]'.

	self assert: (cfg edgesOfKind: HyCFGLoopEdge) isEmpty.
	self assert: (cfg edgesOfKind: HyCFGReturnEdge) size equals: 1.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testWhileFalseSwapsTheBranches [
	"whileFalse: enters the body on the false edge and leaves on the true edge"

	| cfg header step |
	cfg := self cfgForBody: '[ self done ] whileFalse: [ self step ]'.
	header := self nodeSending: #whileFalse: in: cfg.
	step := self nodeSending: #step in: cfg.

	self assert: (self edgeFrom: header to: step in: cfg) class equals: HyCFGFalseEdge.
	self assert: (self edgeFrom: header to: cfg exitNode in: cfg) class equals: HyCFGTrueEdge.
	self assert: (self edgeFrom: step to: header in: cfg) isBackEdge
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testWhileFalseWithoutArgument [
	"[ body and condition ] whileFalse"

	| cfg header step |
	cfg := self cfgForBody: '[ self step ] whileFalse'.
	header := self nodeSending: #whileFalse in: cfg.
	step := self nodeSending: #step in: cfg.

	self assert: (self edgeFrom: header to: step in: cfg) class equals: HyCFGFalseEdge.
	self assert: (self edgeFrom: header to: cfg exitNode in: cfg) class equals: HyCFGTrueEdge
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testWhileTrue [
	"[ cond ] whileTrue: [ body ]: entry -> header, header -true-> body, body -back-> header, header -false-> exit"

	| cfg header step back |
	cfg := self cfgForBody: '[ self more ] whileTrue: [ self step ]'.
	header := self nodeSending: #whileTrue: in: cfg.
	step := self nodeSending: #step in: cfg.

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: (header isKindOf: HyCFGControlFlowNode).
	self assert: (self edgeFrom: cfg entryNode to: header in: cfg) class equals: HyCFGSequentialEdge.
	self assert: (self edgeFrom: header to: step in: cfg) class equals: HyCFGTrueEdge.
	self assert: (self edgeFrom: header to: cfg exitNode in: cfg) class equals: HyCFGFalseEdge.
	back := self edgeFrom: step to: header in: cfg.
	self assert: back class equals: HyCFGLoopEdge.
	self assert: back isBackEdge.
	self assert: step nestingDepth equals: 1.
	self assert: (step isKindOf: HyCFGBlockScopeNode).
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderLoopTest >> testWhileTrueWithoutArgumentLoopsOverTheReceiver [
	"[ body and condition ] whileTrue: the receiver block is the body"

	| cfg header step |
	cfg := self cfgForBody: '[ self step ] whileTrue'.
	header := self nodeSending: #whileTrue in: cfg.
	step := self nodeSending: #step in: cfg.

	self assert: cfg nodes size equals: 4.
	self assert: (self edgeFrom: header to: step in: cfg) class equals: HyCFGTrueEdge.
	self assert: (self edgeFrom: step to: header in: cfg) isBackEdge.
	self assert: (self edgeFrom: header to: cfg exitNode in: cfg) class equals: HyCFGFalseEdge
]
