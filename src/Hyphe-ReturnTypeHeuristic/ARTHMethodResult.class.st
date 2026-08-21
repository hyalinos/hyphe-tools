"
One row of an ARTHInferenceReport: which pattern (if any) classified one concrete Class>>selector / Class class>>selector pair, and what type it predicted. Column shape mirrors ARTIMethodResult (Package, Class, ClassSide, Selector, Type) plus the two extra columns this tool needs (MatchedPattern, ConfidenceTier) so its CSV export can be joined with an ARTIInferenceReport CSV on (Package, Class, ClassSide, Selector) for recalibration.
"
Class {
	#name : 'ARTHMethodResult',
	#superclass : 'Object',
	#instVars : [
		'packageName',
		'className',
		'classSide',
		'selector',
		'matchedPatternIdentifier',
		'expectedType',
		'confidenceTier'
	],
	#category : 'Hyphe-ReturnTypeHeuristic',
	#package : 'Hyphe-ReturnTypeHeuristic'
}

{ #category : 'instance creation' }
ARTHMethodResult class >> package: aPackageName class: aClassName classSide: isClassSide classification: aClassification [

	^ self new
		  setPackageName: aPackageName
		  className: aClassName
		  classSide: isClassSide
		  selector: aClassification selector
		  matchedPatternIdentifier: (aClassification hasMatch
				   ifTrue: [ aClassification matchedPattern identifier ]
				   ifFalse: [ nil ])
		  expectedType: aClassification expectedType
		  confidenceTier: aClassification confidenceTier
]

{ #category : 'accessing' }
ARTHMethodResult >> className [

	^ className
]

{ #category : 'accessing' }
ARTHMethodResult >> classSide [

	^ classSide
]

{ #category : 'accessing' }
ARTHMethodResult >> confidenceTier [

	^ confidenceTier
]

{ #category : 'accessing' }
ARTHMethodResult >> expectedType [

	^ expectedType
]

{ #category : 'testing' }
ARTHMethodResult >> hasMatch [

	^ matchedPatternIdentifier notNil
]

{ #category : 'accessing' }
ARTHMethodResult >> matchedPatternIdentifier [

	^ matchedPatternIdentifier
]

{ #category : 'accessing' }
ARTHMethodResult >> packageName [

	^ packageName
]

{ #category : 'printing' }
ARTHMethodResult >> printOn: aStream [

	aStream
		nextPutAll: className;
		nextPutAll: (classSide
				 ifTrue: [ ' class>>' ]
				 ifFalse: [ '>>' ]);
		nextPutAll: selector asString;
		nextPutAll: ' -> ';
		nextPutAll: expectedType asString
]

{ #category : 'accessing' }
ARTHMethodResult >> selector [

	^ selector
]

{ #category : 'private' }
ARTHMethodResult >> setPackageName: aPackageName className: aClassName classSide: isClassSide selector: aSelector matchedPatternIdentifier: aPatternId expectedType: aType confidenceTier: aTier [

	packageName := aPackageName.
	className := aClassName.
	classSide := isClassSide.
	selector := aSelector.
	matchedPatternIdentifier := aPatternId.
	expectedType := aType.
	confidenceTier := aTier
]
