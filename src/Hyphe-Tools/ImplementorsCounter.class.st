Class {
	#name : 'ImplementorsCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'selectors',
		'method',
		'result'
	],
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'as yet unclassified' }
ImplementorsCounter >> analyzeMethod: aCompiledMethod [
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
