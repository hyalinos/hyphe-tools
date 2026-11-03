"
Superclass of the tests of Hyphe-CFG: helpers to parse a method body, build its CFG and look for nodes and edges in it.
"
Class {
	#name : 'HyCFGAbstractTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-CFG-Tests-Support',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Support'
}

{ #category : 'testing' }
HyCFGAbstractTest class >> isAbstract [
	"This class only holds helpers, it has no test of its own"

	^ self == HyCFGAbstractTest
]

{ #category : 'tmp' }
HyCFGAbstractTest >> a: x [ ^ x > 0 ifTrue: [1] ifFalse: [2]
]

{ #category : 'helpers' }
HyCFGAbstractTest >> assert: actual equals: expected description: aString [
	"Like assert:equals: with a message, used by the tests that check a table of cases"

	self assert: actual = expected description: aString , ': expected ' , expected printString , ' but got ' , actual printString
]

{ #category : 'helpers' }
HyCFGAbstractTest >> assertEveryNodeIsReachable: aCFG [
	"Assert there is no node left floating, disconnected from the entry"

	| reached |
	reached := self reachableNodesOf: aCFG.
	aCFG nodes do: [ :node |
		self assert: (reached includes: node) description: node printString , ' is not reachable from the entry' ]
]

{ #category : 'helpers' }
HyCFGAbstractTest >> assertGraphIsConsistent: aCFG [
	"Assert the invariants of a CFG: edges join nodes of the CFG and are registered in both nodes, nodes only know edges of the CFG, no temporal node is left, the entry has no predecessor and the exit no successor"

	aCFG edges do: [ :edge |
			self assert: (aCFG nodes includes: edge source) description: 'source of ' , edge printString.
			self assert: (aCFG nodes includes: edge target) description: 'target of ' , edge printString.
			self assert: (edge source outgoingEdges includes: edge) description: 'not in outgoing edges: ' , edge printString.
			self assert: (edge target incomingEdges includes: edge) description: 'not in incoming edges: ' , edge printString ].
	aCFG nodes do: [ :node |
			self
				assert: (node incomingEdges allSatisfy: [ :edge | aCFG edges includes: edge ])
				description: 'stale incoming edge of ' , node printString.
			self
				assert: (node outgoingEdges allSatisfy: [ :edge | aCFG edges includes: edge ])
				description: 'stale outgoing edge of ' , node printString.
			self deny: (node isKindOf: HyCFGTemporalNode) description: 'temporal node left in the CFG' ].
	self assert: aCFG entryNode incomingEdges isEmpty description: 'the entry has predecessors'.
	self assert: aCFG exitNode outgoingEdges isEmpty description: 'the exit has successors'
]

{ #category : 'helpers' }
HyCFGAbstractTest >> cfgForBody: aBodyString [
	"Build the CFG of a method named #test whose body is the argument"

	^ HyCFGBuilder buildFrom: (OCParser parseMethod: 'test ' , aBodyString)
]

{ #category : 'helpers' }
HyCFGAbstractTest >> cfgForFaultyBody: aBodyString [
	"Build the CFG of a method whose body has code the parser rejects in a valid method (for example statements after a return)"

	^ HyCFGBuilder buildFrom: (OCParser parseFaultyMethod: 'test ' , aBodyString)
]

{ #category : 'helpers' }
HyCFGAbstractTest >> countOf: aSubstring in: aString [
	"Answer how many times aSubstring occurs in aString"

	| count index |
	count := 0.
	index := 1.
	[ (index := aString indexOfSubCollection: aSubstring startingAt: index) > 0 ] whileTrue: [
			count := count + 1.
			index := index + aSubstring size ].
	^ count
]

{ #category : 'helpers' }
HyCFGAbstractTest >> edgeFrom: aSourceNode to: aTargetNode in: aCFG [
	"Answer the edge of aCFG that goes from a node to another one"

	^ aCFG edges detect: [ :edge | edge source == aSourceNode and: [ edge target == aTargetNode ] ]
]

{ #category : 'helpers' }
HyCFGAbstractTest >> nodeSending: aSelector in: aCFG [
	"Answer the node of aCFG whose AST node is a send of aSelector"

	^ aCFG nodes detect: [ :node |
		  (node isKindOf: HyCFGCodeNode) and: [ node astNode isMessage and: [ node astNode selector = aSelector ] ] ]
]

{ #category : 'helpers' }
HyCFGAbstractTest >> reachableNodesOf: aCFG [
	"Answer the nodes that can be reached from the entry node by following edges"

	| reached toVisit |
	reached := Set new.
	toVisit := OrderedCollection with: aCFG entryNode.
	[ toVisit isEmpty ] whileFalse: [
			| node |
			node := toVisit removeFirst.
			(reached includes: node) ifFalse: [
					reached add: node.
					toVisit addAll: node successors ] ].
	^ reached
]

{ #category : 'helpers' }
HyCFGAbstractTest >> simpleCFG [
	"Answer a hand-made CFG: entry -> statement -> exit. The statement node has an AST node that belongs to no method."

	| cfg entry exit statement |
	cfg := HyCFG new.
	entry := HyCFGEntryNode new.
	exit := HyCFGExitNode new.
	statement := HyCFGStatementNode new.
	statement astNode: (OCVariableNode named: 'x').

	cfg entryNode: entry.
	cfg exitNode: exit.
	cfg addNode: entry.
	cfg addNode: exit.
	cfg addNode: statement.
	cfg addEdge: (HyCFGSequentialEdge from: entry to: statement).
	cfg addEdge: (HyCFGSequentialEdge from: statement to: exit).
	^ cfg
]
