Class {
	#name : 'CascadeCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
CascadeCounterTest >> testCascadeDifferentReceiver [
	| count method cascade|
	method := CascadeCounterTestData >> #cascadeDifferentReceiver.
	cascade := CascadeCounter new.
	count := cascade counterCascade: method.
	self assert: count equals:1
]

{ #category : 'tests' }
CascadeCounterTest >> testCascadeWithYourself [
	| count method cascade|
	method := CascadeCounterTestData >> #cascadeWithYourself.
	cascade := CascadeCounter new.
	count := cascade counterCascade: method.
	self assert: count equals:1
]

{ #category : 'tests' }
CascadeCounterTest >> testNoCascade [
	| count method cascade|
	method := CascadeCounterTestData >> #noCascade.
	cascade := CascadeCounter new.
	count := cascade counterCascade: method.
	self assert: count equals:0
]

{ #category : 'tests' }
CascadeCounterTest >> testSeparateCascades [
	| count method cascade|
	method := CascadeCounterTestData >> #separateCascades.
	cascade := CascadeCounter new.
	count := cascade counterCascade: method.
	self assert: count equals:2
]
