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
	#category : 'Hyphe-Tools-StaticAnalysis',
	#package : 'Hyphe-Tools',
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

{ #category : 'as yet unclassified' }
SelectorAnalysisResults >> analyzMethod: aCompiledMethod [
	method := aCompiledMethod.
	method ast acceptVisitor: self.
	
	^ result 
	

]

{ #category : 'instance creation' }
SelectorAnalysisResults >> implementorsOf: aSelector [
	|allSelectors|
	allSelectors := SystemNavigation default allImplementorsOf: aSelector.
	allSelectors do: [:each |
        | class |
        class := each methodClass.
        implementors
            at: class
            put: (SelectorAnalysisResults new override: class with: aSelector)
    ].
   ^ implementors 
]

{ #category : 'initialization' }
SelectorAnalysisResults >> initialize [ 
	super initialize.
	size := 0.
	implementors := Dictionary new.
	selectors := Dictionary new.
	result := OrderedCollection new.
	
]

{ #category : 'as yet unclassified' }
SelectorAnalysisResults >> override: aClass with: aSelector [
    |override current allSuperClasses |
    override := false.
    allSuperClasses := OrderedCollection new.
    current := aClass superclass.

    [ current notNil ] whileTrue: [
        allSuperClasses add: current.
        current := current superclass.
    ].
		allSuperClasses do: [ :each| 
			override := (each includesSelector:aSelector) .
			override ifTrue: [^ override] ].
    ^ override
	
	
  
]

{ #category : 'visiting' }
SelectorAnalysisResults >> visitMessageNode: aMessageNode [
	| selector |
	selector := aMessageNode selector.	
	"selectors at: selector put: (SelectorAnalysisResults new implementorsOf: selector)."
	selectors at: 'name' put: selector.
	selectors at: 'size' put: (SelectorAnalysisResults new implementorsOf: selector)size.
	selectors at: 'implemementors' put: (SelectorAnalysisResults new implementorsOf: selector).
	result add: selectors.
	super visitMessageNode: aMessageNode .
	
]
