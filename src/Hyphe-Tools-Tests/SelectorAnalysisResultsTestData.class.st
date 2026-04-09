Class {
	#name : 'SelectorAnalysisResultsTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
SelectorAnalysisResultsTestData >> classOverrideTrueFirst [
	^ 1 asCharacter
	
]

{ #category : 'accessing' }
SelectorAnalysisResultsTestData >> method [
	| result |
	result := Dictionary new.
	result at: #first put: 'FirstTest'.
	^ result
]
