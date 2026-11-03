"
Tests of the CFG of exception handling (on:do:, ifCurtailed:, ensure:): the protected code is followed in sequence, the handler is reached through an exception edge.
"
Class {
	#name : 'HyCFGBuilderExceptionTest',
	#superclass : 'HyCFGAbstractTest',
	#category : 'Hyphe-CFG-Tests-Builder',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Builder'
}

{ #category : 'tests' }
HyCFGBuilderExceptionTest >> testCodeAfterOnDoIsReachedFromBothPaths [
	"Both the protected code and the handler continue with the next statement"

	| cfg after |
	cfg := self cfgForBody: '[ self risky ] on: Error do: [ :ex | self handle ]. self after'.
	after := self nodeSending: #after in: cfg.

	self assert: after incomingEdges size equals: 2.
	self assertEveryNodeIsReachable: cfg
]

{ #category : 'tests' }
HyCFGBuilderExceptionTest >> testEmptyHandlerGoesStraightToTheNextStatement [
	"An empty handler is an exception edge from the header to what follows"

	| cfg header |
	cfg := self cfgForBody: '[ self risky ] on: Error do: [ :ex | ]'.
	header := self nodeSending: #on:do: in: cfg.

	self assert: cfg nodes size equals: 4.
	self assert: (self edgeFrom: header to: cfg exitNode in: cfg) class equals: HyCFGExceptionEdge
]

{ #category : 'tests' }
HyCFGBuilderExceptionTest >> testEnsureRunsTheEnsureBlockAfterTheProtectedCode [
	"[ protected ] ensure: [ cleanup ]: the cleanup follows the protected code, in sequence"

	| cfg header body cleanup |
	cfg := self cfgForBody: '[ self body ] ensure: [ self cleanup ]'.
	header := self nodeSending: #ensure: in: cfg.
	body := self nodeSending: #body in: cfg.
	cleanup := self nodeSending: #cleanup in: cfg.

	self assert: cfg nodes size equals: 5.
	self assert: (self edgeFrom: header to: body in: cfg) class equals: HyCFGSequentialEdge.
	self assert: (self edgeFrom: body to: cleanup in: cfg) class equals: HyCFGSequentialEdge.
	self assert: (self edgeFrom: cleanup to: cfg exitNode in: cfg) class equals: HyCFGSequentialEdge.
	self assert: cleanup nestingDepth equals: 1.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderExceptionTest >> testIfCurtailed [
	"The curtail block is reached through an exception edge"

	| cfg header body abort |
	cfg := self cfgForBody: '[ self body ] ifCurtailed: [ self abort ]'.
	header := self nodeSending: #ifCurtailed: in: cfg.
	body := self nodeSending: #body in: cfg.
	abort := self nodeSending: #abort in: cfg.

	self assert: (self edgeFrom: header to: body in: cfg) class equals: HyCFGSequentialEdge.
	self assert: (self edgeFrom: header to: abort in: cfg) class equals: HyCFGExceptionEdge
]

{ #category : 'tests' }
HyCFGBuilderExceptionTest >> testOnDo [
	"[ protected ] on: Error do: [ handler ]: sequential edge to the protected code, exception edge to the handler, both go to the exit"

	| cfg header risky handle |
	cfg := self cfgForBody: '[ self risky ] on: Error do: [ :ex | self handle ]'.
	header := self nodeSending: #on:do: in: cfg.
	risky := self nodeSending: #risky in: cfg.
	handle := self nodeSending: #handle in: cfg.

	self assert: cfg nodes size equals: 5.
	self assert: cfg edges size equals: 5.
	self assert: (header isKindOf: HyCFGControlFlowNode).
	self assert: (self edgeFrom: header to: risky in: cfg) class equals: HyCFGSequentialEdge.
	self assert: (self edgeFrom: header to: handle in: cfg) class equals: HyCFGExceptionEdge.
	self assert: (self edgeFrom: risky to: cfg exitNode in: cfg) class equals: HyCFGSequentialEdge.
	self assert: (self edgeFrom: handle to: cfg exitNode in: cfg) class equals: HyCFGSequentialEdge.
	self assert: risky nestingDepth equals: 1.
	self assertGraphIsConsistent: cfg
]

{ #category : 'tests' }
HyCFGBuilderExceptionTest >> testProtectedBlockInAVariableMakesTheNodeIncomplete [
	"aBlock on: Error do: [ ... ]: the protected code is unknown"

	| cfg header |
	cfg := self cfgForBody: 'aBlock on: Error do: [ :ex | self handle ]'.
	header := self nodeSending: #on:do: in: cfg.

	self deny: cfg isComplete.
	self assert: header unknownBlockReferences size equals: 1.
	self assertEveryNodeIsReachable: cfg
]

{ #category : 'tests' }
HyCFGBuilderExceptionTest >> testReturnInTheHandler [
	"A handler that returns leaves for the exit with a return edge, not with a sequential one"

	| cfg handlerReturn |
	cfg := self cfgForBody: '[ self risky ] on: Error do: [ :ex | ^ nil ]'.
	handlerReturn := cfg nodes detect: [ :n | (n isKindOf: HyCFGCodeNode) and: [ n astNode isReturn ] ].

	self assert: (self edgeFrom: handlerReturn to: cfg exitNode in: cfg) class equals: HyCFGReturnEdge.
	self assert: handlerReturn outgoingEdges size equals: 1.
	self assertGraphIsConsistent: cfg
]
