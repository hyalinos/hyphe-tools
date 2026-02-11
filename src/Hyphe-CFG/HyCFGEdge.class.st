Class {
	#name : 'HyCFGEdge',
	#superclass : 'Object',
	#instVars : [
		'source',
		'target'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'instance creation' }
HyCFGEdge class >> from: sourceNode to: targetNode [ 

	^ self new
		source: sourceNode;
		target: targetNode;
		yourself
]

{ #category : 'accessing' }
HyCFGEdge >> source [

	^ source
]

{ #category : 'accessing' }
HyCFGEdge >> source: aNode [ 

	source := aNode.
	aNode addOutgoingEdge: self
]

{ #category : 'accessing' }
HyCFGEdge >> target [

	^ target
]

{ #category : 'accessing' }
HyCFGEdge >> target: aNode [ 

	target := aNode.
	aNode addIncomingEdge: self
]
