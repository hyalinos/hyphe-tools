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
ImplementorsCounterTestData >> compiledMethod [
	|test|
	test := OrderedCollection new.
	test add: 'count'.
	^ test size
]
