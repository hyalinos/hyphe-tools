"
A statement inside a block (nesting depth 1 or more). It keeps the block that contains it (blockContext).
"
Class {
	#name : 'HyCFGBlockScopeNode',
	#superclass : 'HyCFGCodeNode',
	#instVars : [
		'blockContext'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'accessin' }
HyCFGBlockScopeNode >> blockContext [
	"Answer the block (OCBlockNode) this statement is in"

	^ blockContext
]

{ #category : 'accessin' }
HyCFGBlockScopeNode >> blockContext: anObject [
	"Set the block this statement is in"

	blockContext := anObject
]
