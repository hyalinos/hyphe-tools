"
Entry point of the first version of the analysis of the implementors of the selectors of a method, kept for compatibility. It now delegates to SelectorAnalyzer, which answers one SelectorAnalysisResult per selector sent (name, number of implementors, and for each implementor whether it overrides the base implementation).
"
Class {
	#name : 'SelectorAnalysisResults',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'method',
		'selectors',
		'result',
		'size',
		'implementors'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'as yet unclassified' }
SelectorAnalysisResults class >> exampleSelectorAnalyisMethod [
  <script>
   | count method | 
	" a method to analyze"
	method := SelectorAnalysisResultsTestData >> #method.
	"It returns a dictionary for each selector: its name, the number of its implementors, and another dictionary containing the implementors with a boolean indicating whether they override the base method or not."
	count := self new analyzMethod: method .
	count inspect.
]

{ #category : 'analysis' }
SelectorAnalysisResults >> analyzMethod: aCompiledMethod [
	"Answer a dictionary: the method -> a SelectorAnalysisResult for each distinct selector it sends (see SelectorAnalyzer). The previous version answered the same dictionary for every selector, so all the results were those of the last selector."

	^ SelectorAnalyzer new analyzeMethod: aCompiledMethod
]

{ #category : 'analysis' }
SelectorAnalysisResults >> implementorsOf: aSelector [
	"Answer a dictionary: the classes that implement the selector -> true if their implementation overrides the one of a superclass"

	| dictionary |
	dictionary := Dictionary new.
	(SelectorAnalyzer new resultFor: aSelector) implementors do: [ :association |
		dictionary at: association key put: association value ].
	^ dictionary
]

{ #category : 'initialization' }
SelectorAnalysisResults >> initialize [ 
	super initialize.
	size := 0.
	implementors := Dictionary new.
	selectors := Dictionary new.
	result := OrderedCollection new.
	
]

{ #category : 'analysis' }
SelectorAnalysisResults >> override: aClass with: aSelector [
	"Answer true if a superclass of aClass also implements aSelector"

	^ SelectorAnalysisResult does: aClass override: aSelector
]
