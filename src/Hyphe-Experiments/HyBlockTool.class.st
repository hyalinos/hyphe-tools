"
A tool defined by a block that takes a method reference and answers its type: a string in the notation of the ground truth ('Integer | String'), a HyTypeExpression, a HyToolPrediction, or nil for no answer. It lets any piece of code be used as a tool: HyBlockTool name: 'always Object' block: [ :ref | 'Object' ].
"
Class {
	#name : 'HyBlockTool',
	#superclass : 'HyExpInferenceTool',
	#instVars : [
		'block'
	],
	#category : 'Hyphe-Experiments-Tools',
	#package : 'Hyphe-Experiments',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
HyBlockTool class >> name: aToolName block: aBlock [
	"Create a tool from a block"

	^ self new
		  name: aToolName;
		  setBlock: aBlock;
		  yourself
]

{ #category : 'inferring' }
HyBlockTool >> predictionFor: aMethodRef [
	"Evaluate the block on the method and make a prediction of its answer"

	| answer |
	answer := block value: aMethodRef.
	answer isNil ifTrue: [ ^ self nothing ].
	(answer isKindOf: HyToolPrediction) ifTrue: [ ^ answer ].
	(answer isKindOf: HyTypeExpression) ifTrue: [ ^ HyToolPrediction tool: name types: answer confidence: nil ].
	^ HyToolPrediction tool: name type: answer
]

{ #category : 'initialization' }
HyBlockTool >> setBlock: aBlock [
	"Set the block that infers"

	block := aBlock
]
