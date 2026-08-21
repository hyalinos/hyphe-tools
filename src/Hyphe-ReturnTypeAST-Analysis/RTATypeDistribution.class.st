"
Counts and percentages of ARTIMethodResult types by their top-level Type grammar category
(ClassRef, Metaclass, Self, Self class, Bottom, TypeVar, Unknown, Union -- see ASTReturnTypeInferrer
section 3). A method whose type is a Union is counted once under the Union category, not once per
member -- use #resultsInCategory: #Union to drill into what those unions actually contain.
"
Class {
	#name : 'RTATypeDistribution',
	#superclass : 'Object',
	#instVars : [
		'results',
		'counts'
	],
	#category : 'Hyphe-ReturnTypeAST-Analysis-Statistics',
	#package : 'Hyphe-ReturnTypeAST-Analysis',
	#tag : 'Statistics'
}

{ #category : 'accessing' }
RTATypeDistribution class >> categories [
	"The 8 top-level Type grammar categories (ASTReturnTypeInferrer section 3), in a fixed,
	meaningful order: concrete/self-ish results first, then the two 'gave up' kinds."

	^ #( #ClassRef #Metaclass #Self #SelfClass #Bottom #TypeVar #Union
	     #Unknown )
]

{ #category : 'classifying' }
RTATypeDistribution class >> categoryFor: aType [
	"Maps an HTMType instance to the Symbol naming its top-level grammar category. A Union is
	counted once as #Union, not once per member -- see class comment."

	aType class = HTMClassRef ifTrue: [ ^ #ClassRef ].
	aType class = HTMMetaclass ifTrue: [ ^ #Metaclass ].
	aType class = HTMSelf ifTrue: [ ^ #Self ].
	aType class = HTMSelfClass ifTrue: [ ^ #SelfClass ].
	aType class = HTMBottom ifTrue: [ ^ #Bottom ].
	aType class = HTMTypeVar ifTrue: [ ^ #TypeVar ].
	aType class = HTMUnion ifTrue: [ ^ #Union ].
	aType class = HTMUnknown ifTrue: [ ^ #Unknown ].
	^ self error: 'Unrecognized HTMType: ' , aType class name
]

{ #category : 'instance creation' }
RTATypeDistribution class >> onReport: anARTIInferenceReport [

	^ self onResults: anARTIInferenceReport results
]

{ #category : 'instance creation' }
RTATypeDistribution class >> onResults: aCollectionOfARTIMethodResult [

	^ self new
		  setResults: aCollectionOfARTIMethodResult;
		  yourself
]

{ #category : 'accessing' }
RTATypeDistribution >> countFor: aCategorySymbol [

	^ counts occurrencesOf: aCategorySymbol
]

{ #category : 'private' }
RTATypeDistribution >> paddedLeftOf: aString to: aWidth [

	^ (String
		   new: (aWidth - aString size max: 0)
		   withAll: Character space) , aString
]

{ #category : 'private' }
RTATypeDistribution >> paddedRightOf: aString to: aWidth [

	^ aString
	  ,
	  (String
		   new: (aWidth - aString size max: 0)
		   withAll: Character space)
]

{ #category : 'accessing' }
RTATypeDistribution >> percentageFor: aCategorySymbol [

	self total = 0 ifTrue: [ ^ 0.0 ].
	^ (self countFor: aCategorySymbol) / self total asFloat * 100
]

{ #category : 'printing' }
RTATypeDistribution >> printCSVTo: aFileReference [
	"One row per category, in the fixed category order, plus count and percentage."

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream |
			ZnBufferedWriteStream
				on: stream
				do: [ :out |
						| writer |
						writer := NeoCSVWriter on: out.
						writer writeHeader: { #Category. #Count. #Percentage }.
						self class categories do: [ :category |
								writer nextPut: {
										category.
										(self countFor: category).
										((self percentageFor: category) printShowingDecimalPlaces: 2) } ] ] ]
]

{ #category : 'printing' }
RTATypeDistribution >> printReport [

	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Total methods: ';
		print: self total;
		nextPut: Character lf.
	self class categories do: [ :category |
			stream
				nextPutAll: (self paddedRightOf: category asString to: 10);
				nextPutAll: ': ';
				nextPutAll:
					(self paddedLeftOf: (self countFor: category) printString to: 7);
				nextPutAll: ' (';
				nextPutAll:
					((self percentageFor: category) printShowingDecimalPlaces: 2);
				nextPutAll: '%)';
				nextPut: Character lf ].
	^ stream contents
]

{ #category : 'accessing' }
RTATypeDistribution >> results [

	^ results
]

{ #category : 'accessing' }
RTATypeDistribution >> resultsInCategory: aCategorySymbol [
	"Drill-down: the actual ARTIMethodResult instances behind a category's count, e.g. to inspect
	what a tool's Unknown results look like, or to compare them against another tool's output."

	^ results select: [ :each |
		  (self class categoryFor: each type) = aCategorySymbol ]
]

{ #category : 'private' }
RTATypeDistribution >> setResults: aCollectionOfARTIMethodResult [

	results := aCollectionOfARTIMethodResult asOrderedCollection.
	counts := Bag new.
	results do: [ :each |
		counts add: (self class categoryFor: each type) ]
]

{ #category : 'accessing' }
RTATypeDistribution >> total [

	^ results size
]
