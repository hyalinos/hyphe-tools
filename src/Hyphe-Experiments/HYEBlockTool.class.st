"
A tool defined by a block that takes a method reference and answers its type: a string in the notation of the ground truth ('Integer | String'), a HYETypeExpression, a HYEToolPrediction, or nil for no answer. It lets any piece of code be used as a tool: HYEBlockTool name: 'always Object' block: [ :ref | 'Object' ].
"
Class {
	#name : 'HYEBlockTool',
	#superclass : 'HYEExpInferenceTool',
	#instVars : [
		'block'
	],
	#category : 'Hyphe-Experiments-Tools',
	#package : 'Hyphe-Experiments',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
HYEBlockTool class >> name: aToolName block: aBlock [
	"Create a tool from a block"

	^ self new
		  name: aToolName;
		  setBlock: aBlock;
		  yourself
]

{ #category : 'inferring' }
HYEBlockTool >> predictionFor: aMethodRef [
	"Evaluate the block on the method and make a prediction of its answer"

	| answer |
	answer := block value: aMethodRef.
	answer isNil ifTrue: [ ^ self nothing ].
	(answer isKindOf: HYEToolPrediction) ifTrue: [ ^ answer ].
	(answer isKindOf: HYETypeExpression) ifTrue: [ ^ HYEToolPrediction tool: name types: answer confidence: nil ].
	^ HYEToolPrediction tool: name type: answer
]

{ #category : 'initialization' }
HYEBlockTool >> setBlock: aBlock [
	"Set the block that infers"

	block := aBlock
]
