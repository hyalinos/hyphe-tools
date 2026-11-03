"
For each distinct selector sent by a method I build a SelectorAnalysisResult: the classes of the image that implement it, each with the flag that tells if its implementation overrides the base one. Use: SelectorAnalyzer new analyzeMethod: aCompiledMethod, which answers a dictionary method -> ordered collection of SelectorAnalysisResult, in the order the selectors are first sent. The implementors are sorted by class name.
"
Class {
	#name : 'SelectorAnalyzer',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'results'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'analysis' }
SelectorAnalyzer >> analyzeMethod: aCompiledMethod [
	"Answer a dictionary: the method -> the SelectorAnalysisResult of each distinct selector it sends"

	results := OrderedCollection new.
	aCompiledMethod ast acceptVisitor: self.
	^ Dictionary new
		  at: aCompiledMethod put: results copy;
		  yourself
]

{ #category : 'initialization' }
SelectorAnalyzer >> initialize [
	"Start with no result"

	super initialize.
	results := OrderedCollection new
]

{ #category : 'analysis' }
SelectorAnalyzer >> resultFor: aSelector [
	"Answer the SelectorAnalysisResult of a selector: who implements it in the image, and who overrides"

	| implementors |
	implementors := (SystemNavigation default allImplementorsOf: aSelector) collect: [ :implementor |
		                implementor methodClass name -> (SelectorAnalysisResult does: implementor methodClass override: aSelector) ].
	^ SelectorAnalysisResult name: aSelector implementors: (implementors asSortedCollection: [ :a :b | a key <= b key ])
]

{ #category : 'visiting' }
SelectorAnalyzer >> visitMessageNode: aMessageNode [
	"Analyze the selector, unless it was already met, then look inside"

	(results anySatisfy: [ :result | result name = aMessageNode selector ]) ifFalse: [
		results add: (self resultFor: aMessageNode selector) ].
	super visitMessageNode: aMessageNode
]
