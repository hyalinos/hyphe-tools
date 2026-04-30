Class {
	#name : 'SelectorAnalysisResultsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
SelectorAnalysisResultsTest >> testAnalyzMethod [
	| analyz result |
	analyz := SelectorAnalysisResults new.
	result := analyz analyzMethod: (SelectorAnalysisResultsTestData >> #method).
	self assert: (result at: #name) equals: 'method'.
	self assert: (result at: #size) equals: 2.
	"self assert: ( result at: #implementors) isDictionary."


	
	
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
