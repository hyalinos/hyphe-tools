"
A node that stands for code of the method: it keeps the AST node (astNode) it was made from.
"
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

{ #category : 'accessin' }
HyCFGCodeNode >> astNode [
	"Answer the AST node this node stands for"

	^ astNode
]

{ #category : 'accessin' }
HyCFGCodeNode >> astNode: anObject [
	"Set the AST node this node stands for"

	astNode := anObject
]

{ #category : 'printing' }
HyCFGCodeNode >> printOn: aStream [
	"Print the node together with the source of its AST node, when there is one"

	super printOn: aStream.
	astNode ifNotNil: [
			aStream
				nextPut: $[;
				nextPutAll: (astNode formattedCode copyReplaceAll: String cr with: ' ');
				nextPut: $] ]
]
