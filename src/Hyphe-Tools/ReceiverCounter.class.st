Class {
	#name : 'ReceiverCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'argumentCount',
		'selfCount',
		'superCount',
		'literalCount',
		'localVarCount',
		'variableCount'
	],
	#category : 'Hyphe-Tools-StaticAnalysis',
	#package : 'Hyphe-Tools',
	#tag : 'StaticAnalysis'
}

{ #category : 'initialization' }
ReceiverCounter >> initialize [ 
	super initialize.
	argumentCount := 0.
	selfCount := 0.
	superCount := 0.
	literalCount := 0.
	localVarCount := 0.
	variableCount := Set new.
	
]

{ #category : 'as yet unclassified' }
ReceiverCounter >> receiverArguments: aMethod [
		aMethod ast acceptVisitor: self.
		^ argumentCount

]

{ #category : 'as yet unclassified' }
ReceiverCounter >> receiverLiteral: aMethod [
		aMethod ast acceptVisitor: self.
		^ literalCount
]

{ #category : 'as yet unclassified' }
ReceiverCounter >> receiverLocalVariable: aMethod [
		aMethod ast acceptVisitor: self.
		^ localVarCount 
]

{ #category : 'as yet unclassified' }
ReceiverCounter >> receiverSelves: aMethod [
	aMethod ast acceptVisitor: self.
	^ selfCount
]

{ #category : 'as yet unclassified' }
ReceiverCounter >> receiverSupers: aMethod [
		aMethod ast acceptVisitor: self.	
		^ superCount
]

{ #category : 'as yet unclassified' }
ReceiverCounter >> receiverVariable: aMethod [
		aMethod ast acceptVisitor: self.
		^ variableCount size
]

{ #category : 'visiting' }
ReceiverCounter >> visitArgumentNode: anArgumentNode [
	argumentCount := argumentCount + 1.
]

{ #category : 'visiting' }
ReceiverCounter >> visitLiteralNode: aLiteralNode [
	literalCount := literalCount + 1.
	super visitLiteralNode: aLiteralNode.
]

{ #category : 'visiting' }
ReceiverCounter >> visitLocalVariableNode: aLocalVariableNode [
	localVarCount := localVarCount + 1.
	super visitLocalVariableNode: aLocalVariableNode 
]

{ #category : 'visiting' }
ReceiverCounter >> visitMessageNode: aMessageNode [
   | receiver |
   receiver := aMessageNode receiver.
	receiver acceptVisitor: self.

]

{ #category : 'visiting' }
ReceiverCounter >> visitMessageNodes: aMessageNode [
   | receiver name|
   receiver := aMessageNode receiver.
	receiver isSelfVariable ifTrue: [ 
		selfCount := selfCount + 1 ].
	receiver isSuperVariable ifTrue: [ 
		superCount := superCount  + 1 ].
	receiver isLiteralNode  ifTrue: [ 
		literalCount := literalCount + 1 ].
	receiver isArgumentVariable ifTrue: [ 
		argumentCount := argumentCount + 1 ].
	receiver isVariable ifTrue: [ 
		
		 ].
	super visitMessageNode: aMessageNode 
]

{ #category : 'visiting' }
ReceiverCounter >> visitSelfNode: aSelfNode [
	selfCount := selfCount + 1.
	super visitSelfNode: aSelfNode 
]

{ #category : 'visiting' }
ReceiverCounter >> visitSequenceNode: aSequenceNode [
	localVarCount := localVarCount + aSequenceNode temporaries size.
	super visitSequenceNode: aSequenceNode
]

{ #category : 'visiting' }
ReceiverCounter >> visitSuperNode: aSuperNode [
	superCount := superCount + 1.
	super visitSuperNode: aSuperNode 
]

{ #category : 'visiting' }
ReceiverCounter >> visitTemporaryVariableNode: aTemporaryVariableNode [
	"localVarCount := localVarCount + 1."
]

{ #category : 'visiting' }
ReceiverCounter >> visitVariableNode: aVariableNode [
	variableCount add: aVariableNode name.
	super visitVariableNode: aVariableNode 
]
