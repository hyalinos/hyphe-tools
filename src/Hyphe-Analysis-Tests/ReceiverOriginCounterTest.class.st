"
Tests of ReceiverOriginCounter on the methods of MetricsTestData (category receivers).
"
Class {
	#name : 'ReceiverOriginCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'running' }
ReceiverOriginCounterTest >> countsOf: aSelector [
	"Answer the profile of a method of MetricsTestData"

	^ (ReceiverOriginCounter new
		   analyzeMethod: MetricsTestData >> aSelector;
		   yourself) profile
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testAnalysesDoNotAccumulate [
	"Analyzing another method starts from 0"

	| counter |
	counter := ReceiverOriginCounter new.
	counter receiverSelves: MetricsTestData >> #sendsToSelf.

	self assert: (counter receiverSelves: MetricsTestData >> #sendsToSuper) equals: 0
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testArguments [
	"Sends to the arguments of the method"

	self assert: (ReceiverOriginCounter new receiverArguments: MetricsTestData >> #sendsToArguments:and:) equals: 3
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testCascadeCountsEachMessage [
	"var1 foo; bar; baz is three sends to var1"

	self assert: (ReceiverOriginCounter new receiverInstanceVariables: MetricsTestData >> #cascadeSends) equals: 3
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testClassVariables [
	"Sends to class variables, counted with the instance variables by receiverInstanceOrClassVariables"

	| counter |
	counter := ReceiverOriginCounter new.
	self assert: (counter receiverClassVariables: MetricsTestData >> #sendsToClassVariables) equals: 1.
	self assert: (counter receiverInstanceOrClassVariables: MetricsTestData >> #sendsToClassVariables) equals: 1.
	self assert: (counter receiverInstanceOrClassVariables: MetricsTestData >> #sendsToInstanceVariables) equals: 2
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testGlobals [
	"Class names and other globals receive messages too"

	self assert: (ReceiverOriginCounter new receiverGlobals: MetricsTestData >> #sendsToGlobals) equals: 2
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testInstanceVariables [
	"Sends to instance variables"

	self assert: (ReceiverOriginCounter new receiverInstanceVariables: MetricsTestData >> #sendsToInstanceVariables) equals: 2
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testKinds [
	"All the kinds are in the profile"

	self assert: (self countsOf: #noSends) keys asSet equals: ReceiverOriginCounter kinds asSet
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testLiterals [
	"Sends to literals, nil included"

	self assert: (ReceiverOriginCounter new receiverLiterals: MetricsTestData >> #sendsToLiterals) equals: 5
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testLocalVariablesAndBlockArguments [
	"A temporary is a local variable, the argument of a block is an argument, a block is neither"

	| profile |
	profile := self countsOf: #sendsToLocals.

	self assert: (profile at: #localVariable) equals: 1.
	self assert: (profile at: #argument) equals: 1.
	self assert: (profile at: #global) equals: 1.
	self assert: (profile at: #other) equals: 1
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testMessageResults [
	"In self foo bar the receiver of bar is the result of foo"

	| counter |
	counter := ReceiverOriginCounter new.
	self assert: (counter receiverMessageResults: MetricsTestData >> #sendsToMessageResults) equals: 1.
	self assert: counter receiverSelves equals: 1
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testNoSends [
	"A method without send has a ratio of 0, not a division by zero"

	| counter |
	counter := ReceiverOriginCounter new.
	counter analyzeMethod: MetricsTestData >> #noSends.

	self assert: counter totalSends equals: 0.
	self assert: counter selfSendRatio equals: 0
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testSelfSendRatio [
	"One send out of three goes to self"

	self assert: (ReceiverOriginCounter new selfSendRatio: MetricsTestData >> #mixedSends) equals: 1 / 3
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testSelves [
	"Sends to self"

	self assert: (ReceiverOriginCounter new receiverSelves: MetricsTestData >> #sendsToSelf) equals: 2
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testSupers [
	"Sends to super"

	self assert: (ReceiverOriginCounter new receiverSupers: MetricsTestData >> #sendsToSuper) equals: 2
]

{ #category : 'tests' }
ReceiverOriginCounterTest >> testTotalSendsIsTheSumOfTheKinds [
	"The profile adds up to the number of sends"

	| counter |
	counter := ReceiverOriginCounter new.
	#( #sendsToArguments:and: #sendsToLiterals #sendsToLocals #mixedSends #sendsToMessageResults ) do: [ :selector |
			counter analyzeMethod: MetricsTestData >> selector.
			self assert: counter totalSends equals: counter profile values sum ]
]
