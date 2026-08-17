"
The result of one ARTIReturnTypeInferrer invocation: a collection of ARTIMethodResult
(#results, unordered -- sort via #resultsSortedByPackageClassSelector) plus the methods that were
excluded because they carry a <primitive: N> pragma (#excludedPrimitiveMethods, REQ-G1 -- kept visible
rather than silently dropped, unlike REQ-G2's empty-body exclusions). #printCSVTo: writes the sorted
CSV form of #results.
"
Class {
	#name : 'ARTIInferenceReport',
	#superclass : 'Object',
	#instVars : [
		'results',
		'excludedPrimitiveMethods'
	],
	#category : 'Hyphe-ReturnTypeAST-Pipeline',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Pipeline'
}

{ #category : 'instance creation' }
ARTIInferenceReport class >> results: aResultsCollection excludedPrimitive: anExcludedCollection [

	^ self new
		  setResults: aResultsCollection
		  excludedPrimitive: anExcludedCollection;
		  yourself
]

{ #category : 'accessing' }
ARTIInferenceReport >> excludedPrimitiveMethods [
	"REQ-G1: methods excluded because they carry a <primitive: N> pragma, kept visible to the caller
	rather than silently dropped (unlike the REQ-G2 empty-body exclusions)."

	^ excludedPrimitiveMethods
]

{ #category : 'printing' }
ARTIInferenceReport >> printCSVTo: aFileReference [
	"REQ §5: writes one row per result, sorted by package/class/selector, to aFileReference."

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream |
			ZnBufferedWriteStream
				on: stream
				do: [ :out |
						| writer |
						writer := NeoCSVWriter on: out.
						writer writeHeader:
							{ #Package. #Class. #ClassSide. #Selector. #Type }.
						self resultsSortedByPackageClassSelector do: [ :result |
								writer nextPut: {
										result packageName.
										result className.
										result classSide.
										result selector.
										result type printString } ] ] ]
]

{ #category : 'accessing' }
ARTIInferenceReport >> results [
	"One record per processed method (REQ output §5); no ordering is guaranteed."

	^ results
]

{ #category : 'sorting' }
ARTIInferenceReport >> resultsSortedByPackageClassSelector [

	^ results asSortedCollection: [ :a :b |
			  a packageName = b packageName
				  ifTrue: [
						  a className = b className
							  ifTrue: [ a selector <= b selector ]
							  ifFalse: [ a className < b className ] ]
				  ifFalse: [ a packageName < b packageName ] ]
]

{ #category : 'private' }
ARTIInferenceReport >> setResults: aResultsCollection excludedPrimitive: anExcludedCollection [

	results := aResultsCollection asOrderedCollection.
	excludedPrimitiveMethods := anExcludedCollection asOrderedCollection
]
