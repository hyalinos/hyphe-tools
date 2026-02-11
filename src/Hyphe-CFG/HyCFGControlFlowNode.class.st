Class {
	#name : 'HyCFGControlFlowNode',
	#superclass : 'HyCFGCodeNode',
	#instVars : [
		'isComplete',
		'unknownBlockReferences'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'adding' }
HyCFGControlFlowNode >> addUnknownBlockReference: aReference [ 

	unknownBlockReferences add: aReference.
	isComplete := false
]

{ #category : 'initialization' }
HyCFGControlFlowNode >> initialize [ 

	super initialize.
	isComplete := true.
	unknownBlockReferences := OrderedCollection new
]

{ #category : 'accessing' }
HyCFGControlFlowNode >> isComplete [

	^ isComplete
]

{ #category : 'accessing' }
HyCFGControlFlowNode >> isComplete: anObject [

	isComplete := anObject
]

{ #category : 'accessing' }
HyCFGControlFlowNode >> unknownBlockReferences [

	^ unknownBlockReferences
]
