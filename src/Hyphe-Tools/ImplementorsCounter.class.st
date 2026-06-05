"
For a method (can be both class or  instance side) in Pharo ImplmentorsCounter calculate all message sends, for each of this message send it counts how many classes in the image implement that selector.
To use this code take a compiled method as argument.
   implementors := ImplementorsCounter new.
	implementorrs analyseMethod: aCompiledMethod.
"
Class {
	#name : 'ImplementorsCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'selectors',
		'method',
		'result'
	],
	#category : 'Hyphe-Tools-StaticAnalysis',
	#package : 'Hyphe-Tools',
	#tag : 'StaticAnalysis'
}

{ #category : 'as yet unclassified' }
ImplementorsCounter class >> exampleImplementorCounter [
  <script>
   | method count| 
	"Compiled method to analyze, as an argument"
	method := ImplementorsCounterTestData >> #compiledMethod.
   "Return a dictionary with all meesages sent in the method, and for each message sent , it counts the number of implementors"
	count := self new implementorsInMethod: method.
	count inspect.
]

{ #category : 'as yet unclassified' }
ImplementorsCounter >> implementorsInMethod: aCompiledMethod [
	method := aCompiledMethod.
	aCompiledMethod ast acceptVisitor: self.
	result at: method put: selectors.
	^ result
]

{ #category : 'initialization' }
ImplementorsCounter >> initialize [ 
	super initialize.
	selectors := Dictionary new.
	result := Dictionary new
]

{ #category : 'visiting' }
ImplementorsCounter >> visitMessageNode: aMessageNode [
	| selector implementorsCount|
	selector := aMessageNode selector.
	implementorsCount := (SystemNavigation default allImplementorsOf: selector ) size.
	selectors at: selector put: implementorsCount .
	super visitMessageNode: aMessageNode 
	
]
