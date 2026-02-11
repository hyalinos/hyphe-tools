Class {
	#name : 'HyCFGBlockScopeNode',
	#superclass : 'HyCFGNode',
	#instVars : [
		'blockContext'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'accessing' }
HyCFGBlockScopeNode >> blockContext [

	^ blockContext
]

{ #category : 'accessing' }
HyCFGBlockScopeNode >> blockContext: anObject [

	blockContext := anObject
]
