"
Abstract node of a control flow graph. A node knows its incoming and outgoing edges and its nesting depth, the number of blocks that enclose it in the method.
"
Class {
	#name : 'HyCFGNode',
	#superclass : 'Object',
	#instVars : [
		'nestingDepth',
		'incomingEdges',
		'outgoingEdges'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'as yet unclassified' }
HyCFGNode class >> createWithNesting: nestingDepth [
	"Create a node with its nesting depth"

	^ self new
		  nestingDepth: nestingDepth;
		  yourself
]

{ #category : 'initializatio' }
HyCFGNode >> addIncomingEdge: anEdge [
	"Register an edge that arrives at this node (see HyCFGEdge>>target:)"

	incomingEdges add: anEdge
]

{ #category : 'addin' }
HyCFGNode >> addOutgoingEdge: anEdge [
	"Register an edge that leaves this node (see HyCFGEdge>>source:)"

	outgoingEdges add: anEdge
]

{ #category : 'private' }
HyCFGNode >> findRootsOf: aNode [
	"Answer the nodes without predecessors that can reach aNode (walking the graph backwards)"

	| visited toVisit earliestNodes |
	visited := Set new.
	toVisit := OrderedCollection with: aNode.
	earliestNodes := Set new.

	[ toVisit isEmpty ] whileFalse: [
			| current predecessors |
			current := toVisit removeFirst.

			(visited includes: current) ifFalse: [
					visited add: current.
					predecessors := current predecessors.

					predecessors isEmpty
						ifTrue: [ earliestNodes add: current ]
						ifFalse: [ toVisit addAll: predecessors ] ] ].

	^ earliestNodes
]

{ #category : 'accessin' }
HyCFGNode >> incomingEdges [
	"Answer the edges that arrive at this node"

	^ incomingEdges
]

{ #category : 'initializatio' }
HyCFGNode >> initialize [
	"A node starts at depth 0, with no edge"

	super initialize.
	nestingDepth := 0.
	incomingEdges := OrderedCollection new.
	outgoingEdges := OrderedCollection new
]

{ #category : 'testing' }
HyCFGNode >> isComplete [
	"Only control flow nodes can be incomplete (see HyCFGControlFlowNode), every other node is complete"

	^ true
]

{ #category : 'testin' }
HyCFGNode >> isTerminal [
	"Answer true if nothing can follow this node, only the exit node"

	^ false
]

{ #category : 'accessin' }
HyCFGNode >> nestingDepth [
	"Answer the number of blocks that enclose the node in the method"

	^ nestingDepth
]

{ #category : 'accessin' }
HyCFGNode >> nestingDepth: anObject [
	"Set the number of blocks that enclose the node"

	nestingDepth := anObject
]

{ #category : 'accessin' }
HyCFGNode >> outgoingEdges [
	"Answer the edges that leave this node"

	^ outgoingEdges
]

{ #category : 'adding' }
HyCFGNode >> predecessors [ 
	"nodes that have edges pointing to this node"
	
	^ incomingEdges collect: [ :edge | edge source ]
]

{ #category : 'printing' }
HyCFGNode >> printOn: aStream [
	"Print the node as: HyCFGStatementNode(depth 1)"

	super printOn: aStream.
	aStream
		nextPutAll: '(depth ';
		print: nestingDepth;
		nextPut: $)
]

{ #category : 'private' }
HyCFGNode >> removeIncomingEdge: anEdge [
	"Forget an incoming edge, used when the edge is removed from its CFG"

	incomingEdges remove: anEdge ifAbsent: [ nil ]
]

{ #category : 'private' }
HyCFGNode >> removeOutgoingEdge: anEdge [
	"Forget an outgoing edge, used when the edge is removed from its CFG"

	outgoingEdges remove: anEdge ifAbsent: [ nil ]
]

{ #category : 'adding' }
HyCFGNode >> successors [ 
	"nodes reachable from this node"
	
	^ outgoingEdges collect: [ :edge | edge target ]
]
