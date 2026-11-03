"
Tests of the nodes of a CFG: kinds, neighbours, nesting.
"
Class {
	#name : 'HyCFGNodeTest',
	#superclass : 'HyCFGAbstractTest',
	#category : 'Hyphe-CFG-Tests-Structure',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Structure'
}

{ #category : 'tests' }
HyCFGNodeTest >> testControlFlowNodeRemembersUnknownBlocks [
	"Each unknown block reference makes the node incomplete and is kept"

	| node reference |
	node := HyCFGControlFlowNode new.
	reference := OCParser parseExpression: 'aBlock'.
	node addUnknownBlockReference: reference.

	self deny: node isComplete.
	self assert: node unknownBlockReferences asArray equals: { reference }
]

{ #category : 'tests' }
HyCFGNodeTest >> testCreateWithNesting [
	"The nesting depth is 0 unless given"

	self assert: HyCFGStatementNode new nestingDepth equals: 0.
	self assert: (HyCFGBlockScopeNode createWithNesting: 2) nestingDepth equals: 2
]

{ #category : 'tests' }
HyCFGNodeTest >> testNodesAreCompleteExceptFlaggedControlFlowNodes [
	"isComplete is understood by every node, only a control flow node can be incomplete"

	self assert: HyCFGStatementNode new isComplete.
	self assert: HyCFGEntryNode new isComplete.
	self assert: HyCFGControlFlowNode new isComplete.
	self deny: (HyCFGControlFlowNode new
			 addUnknownBlockReference: (OCParser parseExpression: 'aBlock');
			 yourself) isComplete
]

{ #category : 'tests' }
HyCFGNodeTest >> testOnlyTheExitNodeIsTerminal [
	"Nothing follows the exit node"

	self assert: HyCFGExitNode new isTerminal.
	self deny: HyCFGEntryNode new isTerminal.
	self deny: HyCFGStatementNode new isTerminal.
	self deny: HyCFGControlFlowNode new isTerminal
]

{ #category : 'tests' }
HyCFGNodeTest >> testPredecessorsAndSuccessors [
	"Creating an edge registers it in both nodes"

	| a b c |
	a := HyCFGStatementNode new.
	b := HyCFGStatementNode new.
	c := HyCFGStatementNode new.
	HyCFGSequentialEdge from: a to: b.
	HyCFGSequentialEdge from: a to: c.

	self assert: a successors asArray equals: {
			b.
			c }.
	self assert: b predecessors asArray equals: { a }.
	self assert: a predecessors isEmpty
]

{ #category : 'tests' }
HyCFGNodeTest >> testPrintStringShowsTheCode [
	"A code node prints the source of its AST node, which helps reading test failures and the debugger"

	| node |
	node := HyCFGStatementNode new.
	node astNode: (OCParser parseExpression: 'x := 1').

	self assert: (node printString includesSubstring: 'HyCFGStatementNode').
	self assert: (node printString includesSubstring: 'x := 1')
]

{ #category : 'tests' }
HyCFGNodeTest >> testRemovingAnUnknownEdgeDoesNothing [
	"Forgetting an edge the node does not know is harmless"

	| node edge |
	node := HyCFGStatementNode new.
	edge := HyCFGEdge new.

	node removeIncomingEdge: edge.
	node removeOutgoingEdge: edge.

	self assert: node incomingEdges isEmpty.
	self assert: node outgoingEdges isEmpty
]
