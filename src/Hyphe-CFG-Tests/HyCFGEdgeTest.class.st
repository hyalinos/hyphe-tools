"
Tests of the edges of a CFG: registration in the nodes, true/false branches, back edges, copies.
"
Class {
	#name : 'HyCFGEdgeTest',
	#superclass : 'HyCFGAbstractTest',
	#category : 'Hyphe-CFG-Tests-Structure',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Structure'
}

{ #category : 'tests' }
HyCFGEdgeTest >> testBackEdges [
	"A loop edge is not a back edge unless told so, backEdgeFrom:to: creates one"

	| header body |
	header := HyCFGControlFlowNode new.
	body := HyCFGStatementNode new.

	self deny: HyCFGLoopEdge new isBackEdge.
	self assert: (HyCFGLoopEdge backEdgeFrom: body to: header) isBackEdge.
	self assert: header incomingEdges size equals: 1
]

{ #category : 'tests' }
HyCFGEdgeTest >> testBranchEdges [
	"The true edge is the true branch, the false edge is not, and a plain conditional edge is a true branch until told otherwise"

	self assert: HyCFGTrueEdge new isTrueBranch.
	self deny: HyCFGFalseEdge new isTrueBranch.
	self assert: HyCFGConditionalEdge new isTrueBranch.
	self deny: (HyCFGConditionalEdge new
			 isTrueBranch: false;
			 yourself) isTrueBranch
]

{ #category : 'tests' }
HyCFGEdgeTest >> testCopyFromToKeepsTheKindAndRegisters [
	"A copy is of the same class and keeps the flags, and is registered in its nodes"

	| a b c copy |
	a := HyCFGControlFlowNode new.
	b := HyCFGStatementNode new.
	c := HyCFGStatementNode new.

	copy := (HyCFGFalseEdge from: a to: b) copyFrom: a to: c.
	self assert: copy class equals: HyCFGFalseEdge.
	self deny: copy isTrueBranch.
	self assert: copy target equals: c.
	self assert: (c incomingEdges includes: copy).

	copy := (HyCFGLoopEdge backEdgeFrom: b to: a) copyFrom: c to: a.
	self assert: copy class equals: HyCFGLoopEdge.
	self assert: copy isBackEdge
]

{ #category : 'tests' }
HyCFGEdgeTest >> testDetachedCopyDoesNotRegister [
	"A detached copy leaves the nodes untouched, so a filtered view of a CFG does not modify the CFG"

	| a b copy |
	a := HyCFGControlFlowNode new.
	b := HyCFGStatementNode new.

	copy := HyCFGTrueEdge new detachedCopyFrom: a to: b.

	self assert: copy class equals: HyCFGTrueEdge.
	self assert: copy source equals: a.
	self assert: copy target equals: b.
	self assert: a outgoingEdges isEmpty.
	self assert: b incomingEdges isEmpty
]

{ #category : 'tests' }
HyCFGEdgeTest >> testFromToRegistersTheEdgeInBothNodes [
	"An edge is an outgoing edge of its source and an incoming edge of its target"

	| a b edge |
	a := HyCFGStatementNode new.
	b := HyCFGStatementNode new.
	edge := HyCFGSequentialEdge from: a to: b.

	self assert: edge source equals: a.
	self assert: edge target equals: b.
	self assert: a outgoingEdges asArray equals: { edge }.
	self assert: b incomingEdges asArray equals: { edge }
]

{ #category : 'tests' }
HyCFGEdgeTest >> testPrintString [
	"An edge prints its class and its ends"

	| edge |
	edge := HyCFGSequentialEdge from: HyCFGEntryNode new to: HyCFGExitNode new.

	self assert: (edge printString includesSubstring: 'HyCFGSequentialEdge').
	self assert: (edge printString includesSubstring: 'HyCFGEntryNode').
	self assert: (edge printString includesSubstring: 'HyCFGExitNode')
]
