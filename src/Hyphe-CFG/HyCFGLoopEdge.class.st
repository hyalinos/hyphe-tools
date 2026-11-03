"
An edge that belongs to a loop. A back edge (isBackEdge = true) goes from the end of the loop body back to the loop header.
"
Class {
	#name : 'HyCFGLoopEdge',
	#superclass : 'HyCFGEdge',
	#instVars : [
		'isBackEdge'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'instance creation' }
HyCFGLoopEdge class >> backEdgeFrom: sourceNode to: headerNode [
	"Create a loop edge that goes back from the end of a loop body to its header"

	^ (self from: sourceNode to: headerNode)
		  isBackEdge: true;
		  yourself
]

{ #category : 'copying' }
HyCFGLoopEdge >> copyFrom: sourceNode to: targetNode [
	"Answer a new loop edge between two other nodes that is a back edge if the receiver is one"

	^ (super copyFrom: sourceNode to: targetNode)
		  isBackEdge: isBackEdge;
		  yourself
]

{ #category : 'copying' }
HyCFGLoopEdge >> detachedCopyFrom: sourceNode to: targetNode [
	"Answer a new unregistered loop edge that is a back edge if the receiver is one"

	^ (super detachedCopyFrom: sourceNode to: targetNode)
		  isBackEdge: isBackEdge;
		  yourself
]

{ #category : 'initialization' }
HyCFGLoopEdge >> initialize [
	"A loop edge is not a back edge until told otherwise"

	super initialize.
	isBackEdge := false
]

{ #category : 'accessing' }
HyCFGLoopEdge >> isBackEdge [
	"Answer true if this edge closes a loop, i.e. goes back to the loop header"

	^ isBackEdge
]

{ #category : 'accessing' }
HyCFGLoopEdge >> isBackEdge: aBoolean [
	"Set whether this edge goes back to the loop header"

	isBackEdge := aBoolean
]
