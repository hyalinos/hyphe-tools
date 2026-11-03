"
Tests of ClassReferencesCounter (CBO at method level).
"
Class {
	#name : 'ClassReferencesCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
ClassReferencesCounterTest >> testLiteralsAreInstancesOfClasses [
	"3, 'abc' and #(1 2) refer to SmallInteger, String and Array"

	| counter |
	counter := ClassReferencesCounter new.
	counter analyzeMethod: MetricsTestData >> #referencesLiterals.

	self assert: counter explicitClasses isEmpty.
	self assert: (counter literalClasses includes: #SmallInteger).
	self assert: (counter literalClasses includes: #Array).
	self assert: counter count equals: counter literalClasses size
]

{ #category : 'tests' }
ClassReferencesCounterTest >> testNamedClass [
	"OrderedCollection new refers to one class"

	self assert: (ClassReferencesCounter new classesIn: MetricsTestData >> #referencesOneClass) equals: #( #OrderedCollection ) asSet
]

{ #category : 'tests' }
ClassReferencesCounterTest >> testNilTrueAndFalseAreNotClasses [
	"Constants of the language are not counted as references to UndefinedObject, True or False"

	self assert: (ClassReferencesCounter new countIn: MetricsTestData >> #referencesConstants) equals: 0
]

{ #category : 'tests' }
ClassReferencesCounterTest >> testNoReference [
	"A method that returns self refers to no class"

	self assert: (ClassReferencesCounter new countIn: MetricsTestData >> #referencesNoClass) equals: 0
]

{ #category : 'tests' }
ClassReferencesCounterTest >> testSelfClassNewIsNotKnown [
	"self class new is the send of new to the result of a send: not resolved"

	self assert: (ClassReferencesCounter new countIn: MetricsTestData >> #instantiatesFromTheInstanceSide) equals: 0
]

{ #category : 'tests' }
ClassReferencesCounterTest >> testSelfNewIsTheClassOfTheMethod [
	"self new on the class side instantiates the class, also through super new"

	| counter |
	counter := ClassReferencesCounter new.
	counter analyzeMethod: MetricsTestData class >> #instantiatesItself.
	self assert: counter implicitClasses equals: #( #MetricsTestData ) asSet.

	counter analyzeMethod: MetricsTestData class >> #instantiatesThroughSuper.
	self assert: counter implicitClasses equals: #( #MetricsTestData ) asSet
]

{ #category : 'tests' }
ClassReferencesCounterTest >> testTheSameClassTwiceCountsOnce [
	"Distinct classes"

	self assert: (ClassReferencesCounter new countIn: MetricsTestData >> #referencesTheSameClassTwice) equals: 2.
	self
		assert: (ClassReferencesCounter new classesIn: MetricsTestData >> #referencesTheSameClassTwice)
		equals: #( #OrderedCollection #SmallInteger ) asSet
]

{ #category : 'tests' }
ClassReferencesCounterTest >> testTwoClasses [
	"The array of two instances refers to OrderedCollection and Dictionary (and its literal elements are none)"

	| counter |
	counter := ClassReferencesCounter new.
	counter analyzeMethod: MetricsTestData >> #referencesTwoClasses.

	self assert: counter explicitClasses equals: #( #OrderedCollection #Dictionary ) asSet
]
