Class {
	#name : 'HyCFGCodeNode',
	#superclass : 'HyCFGNode',
	#instVars : [
		'astNode'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'accessing' }
HyCFGCodeNode >> astNode [

	^ astNode
]

{ #category : 'accessing' }
HyCFGCodeNode >> astNode: anObject [

	astNode := anObject
]
