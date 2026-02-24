Class {
	#name : 'ImplementorsCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
ImplementorsCounterTest >> testAnalyzeMethodStructure [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #compliledMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	self assert: result isDictionary.
	self assert: (result includesKey: compiledMethod ).
	self assert: ((result at: compiledMethod ) isDictionary )
]

{ #category : 'tests' }
ImplementorsCounterTest >> testImplementorsCounterTests [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #compiledMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	(result at: compiledMethod) keys do: [ :selector | self assert: ((result at: compiledMethod ) at: selector) equals: 	((SystemNavigation default allImplementorsOf: selector) size) ]
]
