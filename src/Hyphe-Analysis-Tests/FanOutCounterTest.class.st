"
Tests of FanOutCounter: the classes of the receivers that static analysis can resolve.
"
Class {
	#name : 'FanOutCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
FanOutCounterTest >> testClassSide [
	"On the class side self is the metaclass"

	self
		assert: (FanOutCounter new receiverClassesIn: MetricsTestData class >> #fanOutClassSide)
		equals: #( #'MetricsTestData class' ) asSet
]

{ #category : 'tests' }
FanOutCounterTest >> testFanOutIn [
	"fanOutIn: answers the number of classes"

	self assert: (FanOutCounter new fanOutIn: MetricsTestData >> #fanOutOfResolvedReceivers) equals: 4
]

{ #category : 'tests' }
FanOutCounterTest >> testResolvedReceivers [
	"self is the class of the method, a class name is received as its metaclass, a literal as its class"

	| counter |
	counter := FanOutCounter new.
	counter analyzeMethod: MetricsTestData >> #fanOutOfResolvedReceivers.

	self assert: counter receiverClasses equals: #( #MetricsTestData #'OrderedCollection class' #SmallInteger #ByteString ) asSet.
	self assert: counter fanOut equals: 4.
	self assert: counter unresolvedReceivers equals: 0
]

{ #category : 'tests' }
FanOutCounterTest >> testResultOfNewIsAnInstance [
	"OrderedCollection new add: 3: add: is sent to an OrderedCollection, new to its metaclass"

	self
		assert: (FanOutCounter new receiverClassesIn: MetricsTestData >> #fanOutOfNewInstance)
		equals: #( #OrderedCollection #'OrderedCollection class' ) asSet
]

{ #category : 'tests' }
FanOutCounterTest >> testSuperIsTheSuperclass [
	"super initialize is a send to an instance of the superclass"

	self assert: (FanOutCounter new receiverClassesIn: MetricsTestData >> #fanOutOfSuper) equals: #( #Object ) asSet
]

{ #category : 'tests' }
FanOutCounterTest >> testUnresolvedReceivers [
	"A temporary variable needs type inference: it is counted as unresolved"

	| counter |
	counter := FanOutCounter new.
	counter analyzeMethod: MetricsTestData >> #fanOutWithUnresolvedReceivers.

	self assert: counter fanOut equals: 1.
	self assert: counter unresolvedReceivers equals: 2
]
