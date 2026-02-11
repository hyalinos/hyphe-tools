Class {
	#name : 'HyCFGNode',
	#superclass : 'Object',
	#instVars : [
		'astNode',
		'nestingDepth',
		'incomingEdges',
		'outgoingEdges'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'initialization' }
HyCFGNode >> addIncomingEdge: anEdge [ 

	incomingEdges add: anEdge
]

{ #category : 'adding' }
HyCFGNode >> addOutgoingEdge: anEdge [ 

	outgoingEdges add: anEdge
]

{ #category : 'accessing' }
HyCFGNode >> astNode [

	^ astNode
]

{ #category : 'accessing' }
HyCFGNode >> astNode: anObject [

	astNode := anObject
]

{ #category : 'accessing' }
HyCFGNode >> incomingEdges [

	^ incomingEdges
]

{ #category : 'initialization' }
HyCFGNode >> initialize [ 

	super initialize.
	nestingDepth := 0.
	incomingEdges := OrderedCollection new.
	outgoingEdges := OrderedCollection new
]

{ #category : 'accessing' }
HyCFGNode >> nestingDepth [

	^ nestingDepth
]

{ #category : 'accessing' }
HyCFGNode >> nestingDepth: anObject [

	nestingDepth := anObject
]

{ #category : 'accessing' }
HyCFGNode >> outgoingEdges [

	^ outgoingEdges
]

{ #category : 'adding' }
HyCFGNode >> predecessors [ 
	"nodes that have edges pointing to this node"
	
	^ incomingEdges collect: [ :edge | edge source ]
]

{ #category : 'adding' }
HyCFGNode >> successors [ 
	"nodes reachable from this node"
	
	^ outgoingEdges collect: [ :edge | edge target ]
]
