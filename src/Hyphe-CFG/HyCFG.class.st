Class {
	#name : 'HyCFG',
	#superclass : 'Object',
	#instVars : [
		'entryNode',
		'exitNode',
		'nodes',
		'edges'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'initialization' }
HyCFG >> addEdge: anEdge [ 

	edges add: anEdge.
	^ anEdge
]

{ #category : 'initialization' }
HyCFG >> addNode: aNode [
	
	nodes add: aNode.
	^ aNode
]

{ #category : 'accessing' }
HyCFG >> edges [

	^ edges
]

{ #category : 'accessing' }
HyCFG >> entryNode [

	^ entryNode
]

{ #category : 'accessing' }
HyCFG >> entryNode: anObject [

	entryNode := anObject
]

{ #category : 'accessing' }
HyCFG >> exitNode [

	^ exitNode
]

{ #category : 'accessing' }
HyCFG >> exitNode: anObject [

	exitNode := anObject
]

{ #category : 'initialization' }
HyCFG >> initialize [ 

	super initialize.
	nodes := OrderedCollection new.
	edges := OrderedCollection new
]

{ #category : 'accessing' }
HyCFG >> nodes [

	^ nodes
]

{ #category : 'initialization' }
HyCFG >> removeNode: aNode [

	nodes remove: aNode.
	aNode incomingEdges do: [ :e | edges remove: e ].
	aNode outgoingEdges do: [ :e | edges remove: e ].

	
]
