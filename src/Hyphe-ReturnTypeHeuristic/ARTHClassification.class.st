"
Result of classifying one selector: either a match (matchedPattern is the winning ARTHPattern, expectedType/confidenceTier copied from it for convenient access) or no match at all (matchedPattern nil, expectedType #NoMatch, confidenceTier nil). Mirrors the shape of ARTIMethodResult from Hyphe-ReturnTypeAST but deliberately does not share a class with it -- see [[ast-return-type-inferrer-vs-octypingvisitor]] for why the two tools are compared, not merged.
"
Class {
	#name : 'ARTHClassification',
	#superclass : 'Object',
	#instVars : [
		'selector',
		'matchedPattern',
		'expectedType',
		'confidenceTier'
	],
	#category : 'Hyphe-ReturnTypeHeuristic',
	#package : 'Hyphe-ReturnTypeHeuristic'
}

{ #category : 'instance creation' }
ARTHClassification class >> matched: aPattern selector: aSelector [

	^ self new
		  setSelector: aSelector
		  matchedPattern: aPattern
		  expectedType: aPattern expectedType
		  confidenceTier: aPattern confidenceTier
]

{ #category : 'instance creation' }
ARTHClassification class >> noMatchFor: aSelector [

	^ self new
		  setSelector: aSelector
		  matchedPattern: nil
		  expectedType: #NoMatch
		  confidenceTier: nil
]

{ #category : 'accessing' }
ARTHClassification >> confidenceTier [

	^ confidenceTier
]

{ #category : 'accessing' }
ARTHClassification >> expectedType [

	^ expectedType
]

{ #category : 'testing' }
ARTHClassification >> hasMatch [

	^ matchedPattern notNil
]

{ #category : 'accessing' }
ARTHClassification >> matchedPattern [

	^ matchedPattern
]

{ #category : 'printing' }
ARTHClassification >> printOn: aStream [

	aStream
		nextPutAll: selector asString;
		nextPutAll: ' -> '.
	self hasMatch
		ifTrue: [
				aStream
					nextPutAll: expectedType asString;
					nextPutAll: ' via ';
					print: matchedPattern identifier ]
		ifFalse: [ aStream nextPutAll: 'NoMatch' ]
]

{ #category : 'accessing' }
ARTHClassification >> selector [

	^ selector
]

{ #category : 'private' }
ARTHClassification >> setSelector: aSelector matchedPattern: aPattern expectedType: aType confidenceTier: aTier [

	selector := aSelector.
	matchedPattern := aPattern.
	expectedType := aType.
	confidenceTier := aTier
]
