Class {
	#name : 'ImplementorsCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
ImplementorsCounterTest >> testAnalyzeMethodStructure [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #compiledMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	self assert: result isDictionary.
	self assert: (result includesKey: compiledMethod ).
	self assert: ((result at: compiledMethod ) isDictionary )
]

{ #category : 'tests' }
ImplementorsCounterTest >> testAssignedMethod [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #assignementMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	self assert: (result at: compiledMethod) size equals: 0.
	
]

{ #category : 'tests' }
ImplementorsCounterTest >> testBlocMethod [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #blocMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	self assert: (result at: compiledMethod) size equals: 4.
	(result at: compiledMethod) keys do: [ :selector | self assert: ((result at: compiledMethod ) at: selector) equals: 	((SystemNavigation default allImplementorsOf: selector) size) ]
	
]

{ #category : 'tests' }
ImplementorsCounterTest >> testEmptyMethod [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #emptyMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	self assert: (result at: compiledMethod) size equals: 0.
	
]

{ #category : 'tests' }
ImplementorsCounterTest >> testImplementorsCounterTests [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #compiledMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	self assert: (result at: compiledMethod) size equals: 3.
	(result at: compiledMethod) keys do: [ :selector | self assert: ((result at: compiledMethod ) at: selector) equals: 	((SystemNavigation default allImplementorsOf: selector) size) ]
]

{ #category : 'tests' }
ImplementorsCounterTest >> testReturnMethod [
	| compiledMethod counter result |
	compiledMethod := ImplementorsCounterTestData >> #returnMethod.
	counter := ImplementorsCounter new.
	result := counter analyzeMethod: compiledMethod.
	self assert: (result at: compiledMethod) size equals: 0.
	
]
