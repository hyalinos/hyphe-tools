"
Holds every ARTHMethodResult produced by one ARTHClassifier run (over a class, a package, or the whole image), matched and unmatched alike -- unlike ARTIInferenceReport this does not separate out an 'excluded' bucket, since there is no primitive-exclusion concept here; every selector considered gets exactly one row, with hasMatch false when no pattern applied. #printCSVTo: writes the same column shape as ARTIInferenceReport's CSV (Package, Class, ClassSide, Selector, Type) plus MatchedPattern/ConfidenceTier, specifically so the two CSVs can be joined on (Package, Class, ClassSide, Selector) when recalibrating.
"
Class {
	#name : 'ARTHInferenceReport',
	#superclass : 'Object',
	#instVars : [
		'results'
	],
	#category : 'Hyphe-ReturnTypeHeuristic',
	#package : 'Hyphe-ReturnTypeHeuristic'
}

{ #category : 'accessing' }
ARTHInferenceReport >> addResult: aMethodResult [

	results add: aMethodResult
]

{ #category : 'accessing' }
ARTHInferenceReport >> coveragePercent [

	results isEmpty ifTrue: [ ^ 0 ].
	^ self matchedCount * 100.0 / results size
]

{ #category : 'initialization' }
ARTHInferenceReport >> initialize [

	results := OrderedCollection new
]

{ #category : 'accessing' }
ARTHInferenceReport >> matchedCount [

	^ self matchedResults size
]

{ #category : 'accessing' }
ARTHInferenceReport >> matchedResults [

	^ results select: [ :r | r hasMatch ]
]

{ #category : 'csv' }
ARTHInferenceReport >> printCSVTo: aFileReference [

	aFileReference writeStreamDo: [ :stream |
			stream
				nextPutAll:
					'Package,Class,ClassSide,Selector,MatchedPattern,Type,ConfidenceTier';
				nextPut: Character lf.
			results do: [ :r |
					stream
						nextPutAll: r csvRow;
						nextPut: Character lf ] ]
]

{ #category : 'printing' }
ARTHInferenceReport >> printReport [

	| byType |
	byType := Dictionary new.
	self matchedResults do: [ :r |
			byType at: r expectedType ifAbsentPut: [ 0 ].
			byType at: r expectedType put: (byType at: r expectedType) + 1 ].
	^ String streamContents: [ :s |
			  s
				  nextPutAll: 'ARTHInferenceReport: ';
				  print: results size;
				  nextPutAll: ' selectors considered, ';
				  print: self matchedCount;
				  nextPutAll: ' matched (';
				  print: self coveragePercent rounded;
				  nextPutAll: '%)';
				  nextPut: Character lf.
			  byType keysAndValuesDo: [ :type :count |
					  s
						  nextPutAll: '  ';
						  nextPutAll: type asString;
						  nextPutAll: ': ';
						  print: count;
						  nextPut: Character lf ] ]
]

{ #category : 'accessing' }
ARTHInferenceReport >> results [

	^ results
]

{ #category : 'accessing' }
ARTHInferenceReport >> size [

	^ results size
]
