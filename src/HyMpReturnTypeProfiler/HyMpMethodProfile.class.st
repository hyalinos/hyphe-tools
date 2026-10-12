"
Phase 4 of the methodology: the aggregated return-type distribution for one method, keyed by (definingClass, selector) rather than receiver class -- a method's return-type signature is a property of where it's defined, and an inherited method called on many different receiver subclasses should get ONE profile covering all of them, not one profile per receiver class. (Receiver class is still recorded per-observation on HyMpObservation, for anyone who wants to slice that way instead.)
"
Class {
	#name : 'HyMpMethodProfile',
	#superclass : 'Object',
	#instVars : [
		'definingClass',
		'selector',
		'typeCounts',
		'totalCount'
	],
	#category : 'HyMpReturnTypeProfiler',
	#package : 'HyMpReturnTypeProfiler'
}

{ #category : 'instance creation' }
HyMpMethodProfile class >> definingClass: dClass selector: aSelector [

	^ self new
		  definingClass: dClass selector: aSelector;
		  yourself
]

{ #category : 'hyphe-typemodel' }
HyMpMethodProfile class >> hypheTypeForObservedClass: aClass [
	"Wraps one raw Class/Metaclass as observed at runtime into the shared Hyphe-TypeModel vocabulary (see Hyphe-TypeModel). A method that returned a class itself (e.g. ^ self class) shows up here as a real Metaclass -- that must become HTMMetaclass, not a bogus HTMClassRef named #\'Foo class\'."

	(aClass isKindOf: Metaclass)
		ifTrue: [ ^ HTMType metaclass: aClass instanceSide name ]
		ifFalse: [ ^ HTMType classRef: aClass name ]
]

{ #category : 'hyphe-typemodel' }
HyMpMethodProfile >> countFor: aClass [

	^ typeCounts at: aClass ifAbsent: [ 0 ]
]

{ #category : 'accessing' }
HyMpMethodProfile >> definingClass [

	^ definingClass
]

{ #category : 'initialization' }
HyMpMethodProfile >> definingClass: dClass selector: aSelector [

	definingClass := dClass.
	selector := aSelector.
	typeCounts := Dictionary new.
	totalCount := 0
]

{ #category : 'hyphe-typemodel' }
HyMpMethodProfile >> dominantType [
	"The most frequently observed return class -- nil if there are no observations at all."

	typeCounts isEmpty ifTrue: [ ^ nil ].
	^ (typeCounts associations inject: typeCounts associations anyOne into: [ :best :each |
			   each value > best value
				   ifTrue: [ each ]
				   ifFalse: [ best ] ]) key
]

{ #category : 'hyphe-typemodel' }
HyMpMethodProfile >> hypheType [
	"This method's result in the shared Hyphe-TypeModel vocabulary (see Hyphe-TypeModel), built on demand from the raw, intermediate statistics in typeCounts: a single HTMClassRef/HTMMetaclass when monomorphic, an HTMUnion of all observed classes when polymorphic (HTMType class>>union: already de-duplicates and collapses a single-member union on its own), or HTMUnknown when this method was never actually called during profiling. typeCounts itself is never touched by this -- it stays the raw per-run statistics (counts, percentages, dominant type) that the rest of this class works with."

	typeCounts isEmpty ifTrue: [ ^ HTMType unknown ].
	^ HTMType union: (typeCounts keys collect: [ :aClass | self class hypheTypeForObservedClass: aClass ])
]

{ #category : 'querying' }
HyMpMethodProfile >> isMonomorphic [
	"True if every single observed call returned the exact same class."

	^ typeCounts size = 1
]

{ #category : 'hyphe-typemodel' }
HyMpMethodProfile >> percentageFor: aClass [
	"What fraction of observed calls returned aClass, as 0.0-100.0."

	totalCount = 0 ifTrue: [ ^ 0.0 ].
	^ (self countFor: aClass) / totalCount asFloat * 100
]

{ #category : 'hyphe-typemodel' }
HyMpMethodProfile >> printOn: aStream [

	aStream
		nextPutAll: definingClass name asString;
		nextPutAll: '>>';
		print: selector;
		nextPutAll: ' ('.
	(typeCounts associations asSortedCollection: [ :a :b | a value > b value ])
		do: [ :assoc |
				aStream
					nextPutAll: assoc key name asString;
					nextPutAll: ': ';
					print: assoc value;
					nextPutAll: ' (';
					print: (self percentageFor: assoc key) rounded;
					nextPutAll: '%)' ]
		separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPutAll: ')'
]

{ #category : 'recording' }
HyMpMethodProfile >> recordReturnClass: aClass [

	typeCounts at: aClass put: (typeCounts at: aClass ifAbsent: [ 0 ]) + 1.
	totalCount := totalCount + 1
]

{ #category : 'accessing' }
HyMpMethodProfile >> selector [

	^ selector
]

{ #category : 'accessing' }
HyMpMethodProfile >> totalCount [

	^ totalCount
]

{ #category : 'accessing' }
HyMpMethodProfile >> typeCounts [

	^ typeCounts
]
