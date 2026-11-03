"
What an inference tool answered for one method: nothing (the tool could not infer, types is nil), a single type or a set of types (a HyTypeExpression: Integer, or Integer | String), and optionally how confident the tool is (a number, nil if it gives none). Use resolvedFor: with the method so that r (self) becomes the class of the method before comparing or merging predictions.
"
Class {
	#name : 'HyToolPrediction',
	#superclass : 'Object',
	#instVars : [
		'toolName',
		'types',
		'confidence'
	],
	#category : 'Hyphe-Experiments-Tools',
	#package : 'Hyphe-Experiments',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
HyToolPrediction class >> nothingFrom: aToolName [
	"Create the prediction of a tool that could not answer"

	^ self tool: aToolName types: nil confidence: nil
]

{ #category : 'instance creation' }
HyToolPrediction class >> tool: aToolName type: aString [
	"Create a prediction from a type written in the notation of the ground truth ('Integer', 'Integer | String'); nil, '' and 'nil' are no answer"

	^ self tool: aToolName types: (HyTypeExpression parse: aString) confidence: nil
]

{ #category : 'instance creation' }
HyToolPrediction class >> tool: aToolName types: aTypeExpressionOrNil confidence: aNumberOrNil [
	"Create a prediction"

	^ self new
		  setTool: aToolName types: aTypeExpressionOrNil confidence: aNumberOrNil;
		  yourself
]

{ #category : 'accessing' }
HyToolPrediction >> confidence [
	"Answer the confidence of the tool (a number), nil if it gives none"

	^ confidence
]

{ #category : 'accessing' }
HyToolPrediction >> effectiveConfidence [
	"Answer the confidence, or 1 for a tool that does not give one"

	^ confidence ifNil: [ 1 ]
]

{ #category : 'testing' }
HyToolPrediction >> isNothing [
	"Answer true if the tool gave no answer"

	^ types isNil
]

{ #category : 'accessing' }
HyToolPrediction >> keys [
	"Answer the types as sorted strings: two predictions say the same thing when their keys are equal. Empty for no answer."

	^ types ifNil: [ #(  ) ] ifNotNil: [ :expression | expression keys ]
]

{ #category : 'printing' }
HyToolPrediction >> printOn: aStream [
	"Print as tool: types (confidence)"

	aStream
		nextPutAll: toolName asString;
		nextPutAll: ': '.
	types ifNil: [ aStream nextPutAll: 'nothing' ] ifNotNil: [ :expression | aStream print: expression ].
	confidence ifNotNil: [
			aStream
				nextPutAll: ' (';
				print: confidence;
				nextPut: $) ]
]

{ #category : 'accessing' }
HyToolPrediction >> resolvedFor: aMethodRef [
	"Answer the same prediction where r is replaced by the class of the method"

	^ self class tool: toolName types: (types ifNotNil: [ :expression | expression resolvedFor: aMethodRef ]) confidence: confidence
]

{ #category : 'initialization' }
HyToolPrediction >> setTool: aToolName types: aTypeExpressionOrNil confidence: aNumberOrNil [
	"Set the parts of the prediction"

	toolName := aToolName.
	types := aTypeExpressionOrNil.
	confidence := aNumberOrNil
]

{ #category : 'accessing' }
HyToolPrediction >> toolName [
	"Answer the name of the tool that answered"

	^ toolName
]

{ #category : 'accessing' }
HyToolPrediction >> types [
	"Answer the type(s) answered (a HyTypeExpression), nil if the tool gave no answer"

	^ types
]
