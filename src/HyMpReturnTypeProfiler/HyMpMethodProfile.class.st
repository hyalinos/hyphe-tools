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

{ #category : 'accessing' }
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

{ #category : 'querying' }
HyMpMethodProfile >> dominantType [
	"The most frequently observed return class -- nil if there are no observations at all."

	typeCounts isEmpty ifTrue: [ ^ nil ].
	^ (typeCounts associations inject: typeCounts associations anyOne into: [ :best :each |
			   each value > best value
				   ifTrue: [ each ]
				   ifFalse: [ best ] ]) key
]

{ #category : 'querying' }
HyMpMethodProfile >> isMonomorphic [
	"True if every single observed call returned the exact same class."

	^ typeCounts size = 1
]

{ #category : 'accessing' }
HyMpMethodProfile >> percentageFor: aClass [
	"What fraction of observed calls returned aClass, as 0.0-100.0."

	totalCount = 0 ifTrue: [ ^ 0.0 ].
	^ (self countFor: aClass) / totalCount asFloat * 100
]

{ #category : 'printing' }
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
