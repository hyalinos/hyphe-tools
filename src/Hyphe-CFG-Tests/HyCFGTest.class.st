"
Tests of HyCFG: nodes, edges, removing nodes, completeness, depth, queries.
"
Class {
	#name : 'HyCFGTest',
	#superclass : 'TestCase',
	#instVars : [
		'cfg'
	],
	#category : 'Hyphe-CFG-Tests-Structure',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Structure'
}

{ #category : 'runnin' }
HyCFGTest >> setUp [
	"A new empty CFG"

	super setUp.
	cfg := HyCFG new
]

{ #category : 'runnin' }
HyCFGTest >> testAddEdge [
	"addEdge: adds an edge to the CFG"

	| edge source target |
	source := HyCFGStatementNode new.
	target := HyCFGStatementNode new.
	edge := HyCFGEdge from: source to: target.
	cfg addEdge: edge.

	self assert: cfg edges size equals: 1.
	self assert: (cfg edges includes: edge)
]

{ #category : 'runnin' }
HyCFGTest >> testAddNode [
	"addNode: adds a node to the CFG"

	| node |
	node := HyCFGStatementNode new.
	cfg addNode: node.

	self assert: cfg nodes size equals: 1.
	self assert: (cfg nodes includes: node)
]

{ #category : 'running' }
HyCFGTest >> testFindRootsOfAChain [
	"findRootsOf: walks the graph backwards up to the nodes without predecessor (it used to stop in a halt)"

	| a b c |
	a := HyCFGStatementNode new.
	b := HyCFGStatementNode new.
	c := HyCFGStatementNode new.
	HyCFGEdge from: a to: b.
	HyCFGEdge from: b to: c.

	self assert: (c findRootsOf: c) asArray equals: { a }
]

{ #category : 'running' }
HyCFGTest >> testFindRootsOfSurvivesACycle [
	"A loop must not make findRootsOf: run forever"

	| header body |
	header := HyCFGControlFlowNode new.
	body := HyCFGStatementNode new.
	HyCFGEdge from: header to: body.
	HyCFGEdge from: body to: header.

	self assert: (body findRootsOf: body) isEmpty
]

{ #category : 'running' }
HyCFGTest >> testIncompleteNodes [
	"A control flow node that has a block of unknown code makes the CFG incomplete"

	| incomplete |
	incomplete := HyCFGControlFlowNode new.
	incomplete addUnknownBlockReference: (OCParser parseExpression: 'aBlock').
	cfg addNode: HyCFGControlFlowNode new.
	cfg addNode: incomplete.

	self deny: cfg isComplete.
	self assert: cfg incompleteNodes asArray equals: { incomplete }
]

{ #category : 'runnin' }
HyCFGTest >> testInitialization [
	"A new CFG is empty"

	self assert: cfg nodes isEmpty.
	self assert: cfg edges isEmpty.
	self assert: cfg entryNode isNil.
	self assert: cfg exitNode isNil
]

{ #category : 'running' }
HyCFGTest >> testIsCompleteByDefault [
	"A CFG without control flow node that has unknown code is complete"

	cfg addNode: HyCFGStatementNode new.
	cfg addNode: HyCFGControlFlowNode new.

	self assert: cfg isComplete.
	self assert: cfg incompleteNodes isEmpty
]

{ #category : 'running' }
HyCFGTest >> testMaxNestingDepth [
	"The max nesting depth is the deepest node, 0 for an empty CFG"

	self assert: cfg maxNestingDepth equals: 0.

	cfg addNode: (HyCFGStatementNode createWithNesting: 0).
	cfg addNode: (HyCFGBlockScopeNode createWithNesting: 3).
	cfg addNode: (HyCFGBlockScopeNode createWithNesting: 1).

	self assert: cfg maxNestingDepth equals: 3
]

{ #category : 'running' }
HyCFGTest >> testMethodNodeIsNilForAHandMadeCFG [
	"Only the builder knows the method a CFG comes from"

	self assert: cfg methodNode isNil
]

{ #category : 'running' }
HyCFGTest >> testNodesAndEdgesOfKind [
	"nodesOfKind: and edgesOfKind: select instances of a class and of its subclasses"

	| entry statement block edge |
	entry := HyCFGEntryNode new.
	statement := HyCFGStatementNode new.
	block := HyCFGBlockScopeNode new.
	{
		entry.
		statement.
		block } do: [ :node | cfg addNode: node ].
	edge := HyCFGTrueEdge from: entry to: statement.
	cfg addEdge: edge.
	cfg addEdge: (HyCFGSequentialEdge from: statement to: block).

	self assert: (cfg nodesOfKind: HyCFGEntryNode) asArray equals: { entry }.
	self assert: (cfg nodesOfKind: HyCFGCodeNode) size equals: 2.
	self assert: (cfg edgesOfKind: HyCFGConditionalEdge) asArray equals: { edge }.
	self assert: (cfg edgesOfKind: HyCFGEdge) size equals: 2
]

{ #category : 'running' }
HyCFGTest >> testRemoveNodeForgetsEdgesInNeighbours [
	"Removing a node must also remove its edges from the nodes at their other end"

	| a b c |
	a := HyCFGStatementNode new.
	b := HyCFGStatementNode new.
	c := HyCFGStatementNode new.
	{
		a.
		b.
		c } do: [ :node | cfg addNode: node ].
	cfg addEdge: (HyCFGEdge from: a to: b).
	cfg addEdge: (HyCFGEdge from: b to: c).

	cfg removeNode: b.

	self assert: cfg nodes asArray equals: {
			a.
			c }.
	self assert: cfg edges isEmpty.
	self assert: a outgoingEdges isEmpty.
	self assert: c incomingEdges isEmpty.
	self assert: a successors isEmpty
]

{ #category : 'running' }
HyCFGTest >> testRemoveNodeToleratesEdgesNotAddedToTheCFG [
	"An edge created between two nodes but never added to the CFG does not make removeNode: fail"

	| a b |
	a := HyCFGStatementNode new.
	b := HyCFGStatementNode new.
	cfg addNode: a.
	cfg addNode: b.
	HyCFGEdge from: a to: b.

	cfg removeNode: a.

	self assert: cfg nodes asArray equals: { b }.
	self assert: b incomingEdges isEmpty
]

{ #category : 'running' }
HyCFGTest >> testRemoveNodeWithSelfLoop [
	"A self loop is both an incoming and an outgoing edge of its node, it must be removed only once"

	| node |
	node := HyCFGControlFlowNode new.
	cfg addNode: node.
	cfg addEdge: (HyCFGLoopEdge backEdgeFrom: node to: node).

	cfg removeNode: node.

	self assert: cfg nodes isEmpty.
	self assert: cfg edges isEmpty
]

{ #category : 'runnin' }
HyCFGTest >> testSetEntryNode [
	"The entry node can be set"

	| entry |
	entry := HyCFGEntryNode new.
	cfg entryNode: entry.

	self assert: cfg entryNode equals: entry
]

{ #category : 'runnin' }
HyCFGTest >> testSetExitNode [
	"The exit node can be set"

	| exit |
	exit := HyCFGExitNode new.
	cfg exitNode: exit.

	self assert: cfg exitNode equals: exit
]

{ #category : 'running' }
HyCFGTest >> testVisualizeAnswersACanvas [
	"HyCFG>>visualize delegates to the visualizer"

	| canvas |
	cfg entryNode: HyCFGEntryNode new.
	cfg exitNode: HyCFGExitNode new.
	cfg addNode: cfg entryNode.
	cfg addNode: cfg exitNode.

	canvas := cfg visualize.

	self assert: (canvas isKindOf: RSCanvas).
	self assert: canvas numberOfShapes >= 2
]
