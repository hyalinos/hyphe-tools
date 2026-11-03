"
A directed edge between two nodes of a CFG: the control can go from its source to its target. Creating an edge with from:to: registers it in both nodes. The subclasses tell why the control goes there.
"
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
	"Create an edge between two nodes and register it in both"

	^ self new
		  source: sourceNode;
		  target: targetNode;
		  yourself
]

{ #category : 'private' }
HyCFGEdge >> connect [
	"Register the edge in its two nodes"

	source addOutgoingEdge: self.
	target addIncomingEdge: self
]

{ #category : 'copying' }
HyCFGEdge >> copyFrom: sourceNode to: targetNode [
	"Answer a new edge of the same kind between two other nodes, registered in both nodes like any edge created with #from:to:"

	^ (self detachedCopyFrom: sourceNode to: targetNode)
		  connect;
		  yourself
]

{ #category : 'copying' }
HyCFGEdge >> detachedCopyFrom: sourceNode to: targetNode [
	"Answer a new edge of the same kind between two other nodes, without registering it in the nodes (so the nodes of the original CFG are not modified). Used to draw filtered views of a CFG."

	^ self class new
		  setSource: sourceNode target: targetNode;
		  yourself
]

{ #category : 'printing' }
HyCFGEdge >> printOn: aStream [
	"Print the edge as: HyCFGTrueEdge(source -> target)"

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: source;
		nextPutAll: ' -> ';
		print: target;
		nextPut: $)
]

{ #category : 'private' }
HyCFGEdge >> setSource: sourceNode target: targetNode [
	"Set both ends without registering the edge in the nodes"

	source := sourceNode.
	target := targetNode
]

{ #category : 'accessin' }
HyCFGEdge >> source [
	"Answer the node the control comes from"

	^ source
]

{ #category : 'accessin' }
HyCFGEdge >> source: aNode [
	"Set the node the control comes from; the edge is registered as one of its outgoing edges"

	source := aNode.
	aNode addOutgoingEdge: self
]

{ #category : 'accessin' }
HyCFGEdge >> target [
	"Answer the node the control goes to"

	^ target
]

{ #category : 'accessin' }
HyCFGEdge >> target: aNode [
	"Set the node the control goes to; the edge is registered as one of its incoming edges"

	target := aNode.
	aNode addIncomingEdge: self
]
