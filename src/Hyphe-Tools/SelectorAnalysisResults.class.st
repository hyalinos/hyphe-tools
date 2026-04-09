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
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'as yet unclassified' }
SelectorAnalysisResults >> analyzMethod: aCompiledMethod [
	method := aCompiledMethod.
	method ast acceptVisitor: self.
	result at:#name put: method selector.
	result at:#size put: selectors size.
	result at:#selectors put: selectors .
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
	result := Dictionary new.
	
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
	selectors at: selector put: (SelectorAnalysisResults new implementorsOf: selector).
	super visitMessageNode: aMessageNode .
	
]
