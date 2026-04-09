Class {
	#name : 'ImplementorsCounterTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
ImplementorsCounterTestData class >> testClass [
	|class|
	class := 1+2.
	^ class
]

{ #category : 'as yet unclassified' }
ImplementorsCounterTestData >> assignementMethod [
	| a |
	a := 3.
]

{ #category : 'as yet unclassified' }
ImplementorsCounterTestData >> blocMethod [
	| n x|
	n := 4.
	x := 0.
	n > 0 ifTrue: [ 
		x := x + 1.
		n := n - 1
		 ].
	^ x
	
]

{ #category : 'as yet unclassified' }
ImplementorsCounterTestData >> compiledMethod [
	|test|
	test := OrderedCollection new.
	test add: 'count'.
	^ test size
]

{ #category : 'as yet unclassified' }
ImplementorsCounterTestData >> emptyMethod [
]

{ #category : 'as yet unclassified' }
ImplementorsCounterTestData >> returnMethod [
	^ self
]
