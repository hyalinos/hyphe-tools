"
A statement that decides what runs next: a conditional, a loop, an exception handler. It has several outgoing edges. If the code of one of its blocks is unknown (the block is in a variable, for example) the node is incomplete (isComplete is false) and keeps the unknown AST nodes in unknownBlockReferences.
"
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

{ #category : 'addin' }
HyCFGControlFlowNode >> addUnknownBlockReference: aReference [
	"Remember an AST node standing where a block was expected; the node becomes incomplete"

	unknownBlockReferences add: aReference.
	isComplete := false
]

{ #category : 'initializatio' }
HyCFGControlFlowNode >> initialize [
	"A control flow node is complete until an unknown block is added"

	super initialize.
	isComplete := true.
	unknownBlockReferences := OrderedCollection new
]

{ #category : 'accessin' }
HyCFGControlFlowNode >> isComplete [
	"Answer false if the code of one of its blocks is unknown"

	^ isComplete
]

{ #category : 'accessin' }
HyCFGControlFlowNode >> isComplete: anObject [
	"Set whether all its blocks are known"

	isComplete := anObject
]

{ #category : 'accessin' }
HyCFGControlFlowNode >> unknownBlockReferences [
	"Answer the AST nodes that should have been blocks but were not (variables, messages...)"

	^ unknownBlockReferences
]
