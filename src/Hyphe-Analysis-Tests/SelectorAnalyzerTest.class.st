"
Tests of SelectorAnalyzer, SelectorAnalysisResult and of the new SelectorAnalysisResults API, with SelectorBaseData (implements), SelectorChildData (overrides) and SelectorOtherData (implements, unrelated).
"
Class {
	#name : 'SelectorAnalyzerTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
SelectorAnalyzerTest >> resultOf: aSelector in: aMethod [
	"Answer the result for a selector in the analysis of a method"

	^ ((SelectorAnalyzer new analyzeMethod: aMethod) at: aMethod) detect: [ :result | result name = aSelector ]
]

{ #category : 'tests' }
SelectorAnalyzerTest >> testImplementorsAndOverrides [
	"Three classes implement the selector, the child overrides the base, the other class is not related"

	| result |
	result := self resultOf: #hypheUniqueSelectorX in: SelectorUserData >> #use.

	self assert: result size equals: 3.
	self assert: result implementorNames asArray equals: #( #SelectorBaseData #SelectorChildData #SelectorOtherData ).
	self assert: (result overrides: #SelectorBaseData) equals: false.
	self assert: (result overrides: #SelectorChildData) equals: true.
	self assert: (result overrides: #SelectorOtherData) equals: false.
	self assert: result overridingImplementors asArray equals: #( #SelectorChildData ).
	self assert: result baseImplementors asArray equals: #( #SelectorBaseData #SelectorOtherData )
]

{ #category : 'tests' }
SelectorAnalyzerTest >> testMetaclassImplementorsOverride [
	"The class side counts: Object class >> new and Behavior >> new, a class overrides when a superclass implements the selector"

	self assert: (SelectorAnalysisResult does: SelectorChildData override: #hypheUniqueSelectorX).
	self deny: (SelectorAnalysisResult does: SelectorBaseData override: #hypheUniqueSelectorX).
	self assert: ((SelectorAnalyzer new resultFor: #new) overrides: #'MetricsTestData class') isNil.
	self assert: ((SelectorAnalyzer new resultFor: #new) overrides: #'OrderedCollection class')
]

{ #category : 'tests' }
SelectorAnalyzerTest >> testOneResultPerDistinctSelector [
	"The method sends two selectors, in the order they appear (the cascade sends the second one last)"

	| results |
	results := (SelectorAnalyzer new analyzeMethod: SelectorUserData >> #use) at: SelectorUserData >> #use.

	self assert: (results collect: [ :result | result name ]) asArray equals: #( #hypheUniqueSelectorX #hypheUniqueSelectorY )
]

{ #category : 'tests' }
SelectorAnalyzerTest >> testPrintString [
	"SelectorAnalysisResult(name: ..., size: ..., implementors: [Class -> overrides, ...])"

	| text |
	text := (self resultOf: #hypheUniqueSelectorX in: SelectorUserData >> #use) printString.

	self
		assert: text
		equals:
		'SelectorAnalysisResult(name: hypheUniqueSelectorX, size: 3, implementors: [SelectorBaseData -> false, SelectorChildData -> true, SelectorOtherData -> false])'
]

{ #category : 'tests' }
SelectorAnalyzerTest >> testSelectorAnalysisResultsAnswersTheNewResults [
	"The old class SelectorAnalysisResults now answers the same dictionary, and keeps override:with: and implementorsOf:"

	| analysis results |
	analysis := SelectorAnalysisResults new.
	results := (analysis analyzMethod: SelectorUserData >> #use) at: SelectorUserData >> #use.

	self assert: results size equals: 2.
	self assert: (results first isKindOf: SelectorAnalysisResult).
	self assert: (analysis override: SelectorChildData with: #hypheUniqueSelectorX).
	self assert: (analysis implementorsOf: #hypheUniqueSelectorX) size equals: 3.
	self assert: ((analysis implementorsOf: #hypheUniqueSelectorX) at: #SelectorChildData) equals: true
]

{ #category : 'tests' }
SelectorAnalyzerTest >> testSelectorSentTwiceIsAnalyzedOnce [
	"No duplicated result"

	self
		assert: ((SelectorAnalyzer new analyzeMethod: SelectorUserData >> #useTwice) at: SelectorUserData >> #useTwice) size
		equals: 1
]

{ #category : 'tests' }
SelectorAnalyzerTest >> testSelectorWithoutImplementor [
	"A selector that nobody implements has size 0"

	| result |
	result := self resultOf: #hypheUniqueSelectorY in: SelectorUserData >> #use.

	self assert: result size equals: 0.
	self assert: result implementors isEmpty.
	self assert: (result overrides: #Object) isNil
]
