"
I represent a visitor that traverses the AST of a method and collects all message nodes it encounters.
"
Class {
	#name : 'MessageNodesCollector',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'messageNodes'
	],
	#category : 'Hyphe-Tools-TestProfiler',
	#package : 'Hyphe-Tools',
	#tag : 'TestProfiler'
}

{ #category : 'visiting' }
MessageNodesCollector >> initialize [ 

	super initialize.
	messageNodes := OrderedCollection new. 
]

{ #category : 'accessing' }
MessageNodesCollector >> messageNodes [

	^ messageNodes
]

{ #category : 'visiting' }
MessageNodesCollector >> visitMessageNode: aMessageNode [

	super visitMessageNode: aMessageNode.
	messageNodes add: aMessageNode. 
]
