"
Tests for HyMpMethodProfile: recording, percentages, monomorphic/dominant-type detection.
"
Class {
	#name : 'HyMpMethodProfileTest',
	#superclass : 'TestCase',
	#category : 'HyMpReturnTypeProfiler-Tests',
	#package : 'HyMpReturnTypeProfiler-Tests'
}

{ #category : 'tests' }
HyMpMethodProfileTest >> testInitialStateIsEmpty [

	| profile |
	profile := HyMpMethodProfile definingClass: Point selector: #x.
	self assert: profile definingClass equals: Point.
	self assert: profile selector equals: #x.
	self assert: profile totalCount equals: 0.
	self assert: profile typeCounts isEmpty.
	self deny: profile isMonomorphic.
	self assert: profile dominantType isNil
]

{ #category : 'tests' }
HyMpMethodProfileTest >> testPrintOnIncludesClassAndSelectorAndCounts [

	| profile printed |
	profile := HyMpMethodProfile definingClass: Point selector: #y.
	profile recordReturnClass: SmallInteger.
	printed := profile printString.
	self assert: (printed includesSubstring: 'Point').
	self assert: (printed includesSubstring: 'y').
	self assert: (printed includesSubstring: 'SmallInteger').
	self assert: (printed includesSubstring: '100%')
]

{ #category : 'tests' }
HyMpMethodProfileTest >> testRecordMultipleTypesIsPolymorphic [

	| profile |
	profile := HyMpMethodProfile definingClass: Point selector: #asString.
	3 timesRepeat: [ profile recordReturnClass: String ].
	1 timesRepeat: [ profile recordReturnClass: Symbol ].
	self assert: profile totalCount equals: 4.
	self deny: profile isMonomorphic.
	self assert: profile dominantType equals: String.
	self assert: (profile percentageFor: String) equals: 75.0.
	self assert: (profile percentageFor: Symbol) equals: 25.0.
	self assert: (profile percentageFor: Float) equals: 0.0
]

{ #category : 'tests' }
HyMpMethodProfileTest >> testRecordSingleTypeIsMonomorphic [

	| profile |
	profile := HyMpMethodProfile definingClass: Point selector: #x.
	profile recordReturnClass: SmallInteger.
	profile recordReturnClass: SmallInteger.
	profile recordReturnClass: SmallInteger.
	self assert: profile totalCount equals: 3.
	self assert: (profile countFor: SmallInteger) equals: 3.
	self assert: profile isMonomorphic.
	self assert: profile dominantType equals: SmallInteger.
	self assert: (profile percentageFor: SmallInteger) equals: 100.0
]
