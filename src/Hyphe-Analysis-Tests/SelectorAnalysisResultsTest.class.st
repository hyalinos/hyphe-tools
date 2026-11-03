Class {
	#name : 'SelectorAnalysisResultsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
SelectorAnalysisResultsTest >> testAnalyzMethod [
	"The analysis of a method answers a dictionary method -> one SelectorAnalysisResult per distinct selector sent (the method sends new and at:put:)"

	| method results |
	method := SelectorAnalysisResultsTestData >> #method.
	results := (SelectorAnalysisResults new analyzMethod: method) at: method.

	self assert: (results collect: [ :result | result name ]) asArray equals: #( #new #at:put: ).
	self assert: (results allSatisfy: [ :result | result size > 0 ])
]

{ #category : 'tests' }
SelectorAnalysisResultsTest >> testOverride [
	| analyz|
	analyz := SelectorAnalysisResults new.
	self assert: ( analyz override: FirdClass with: #classOverrideFalse) equals: false
]

{ #category : 'tests' }
SelectorAnalysisResultsTest >> testOverrideFalse [
	| analyz|
	analyz := SelectorAnalysisResults new.
	self assert: ( analyz override: FirdClass with: #classOverrideFalse) equals: false
]

{ #category : 'tests' }
SelectorAnalysisResultsTest >> testOverrideTrue [
	| analyz|
	analyz := SelectorAnalysisResults new.
	self assert: ( analyz override: FirdClass with: #classOverrideTrue) equals: true
]

{ #category : 'tests' }
SelectorAnalysisResultsTest >> testOverrideTrueFirst [
	| analyz|
	analyz := SelectorAnalysisResults new.
	self assert: ( analyz override: FirdClass with: #classOverrideTrueFirst) equals: true
]
