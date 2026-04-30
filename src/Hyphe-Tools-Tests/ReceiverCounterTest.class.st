Class {
	#name : 'ReceiverCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
ReceiverCounterTest class >> testVariableCounter [
	| compiledMethod counter superReceiver|
	compiledMethod := ReceiverCounterTestData>>#testVariableClass .
	counter := ReceiverCounter new.
	superReceiver := (counter receiverVariable: compiledMethod).
	self assert: superReceiver equals: 2.
]

{ #category : 'tests' }
ReceiverCounterTest >> testArgumentCounter [
	| compiledMethod counter superReceiver|
	compiledMethod := ReceiverCounterTestData>>#testArgument:and:and:.
	counter := ReceiverCounter new.
	superReceiver := (counter receiverArguments: compiledMethod).
	self assert: superReceiver equals: 3.
]

{ #category : 'tests' }
ReceiverCounterTest >> testLiteralCounter [
	| compiledMethod counter literal|
	compiledMethod := ReceiverCounterTestData>>#testLiteral.
	counter := ReceiverCounter new.
	literal := (counter receiverLiteral: compiledMethod).
	self assert: literal equals: 4.
]

{ #category : 'tests' }
ReceiverCounterTest >> testLocalVariableCounter [
	| compiledMethod counter superReceiver|
	compiledMethod := ReceiverCounterTestData>>#testLocalVariable .
	counter := ReceiverCounter new.
	superReceiver := (counter receiverLocalVariable: compiledMethod).
	self assert: superReceiver equals: 4.
]

{ #category : 'tests' }
ReceiverCounterTest >> testMethodVariableCounter [
	| compiledMethod counter superReceiver|
	compiledMethod := ReceiverCounterTestData>>#testMethod:and:.
	counter := ReceiverCounter new.
	superReceiver := (counter receiverVariable: compiledMethod).
	self assert: superReceiver equals: 2.
]

{ #category : 'tests' }
ReceiverCounterTest >> testSelfCounter [
	| compiledMethod counter selfReceiver|
	compiledMethod := ReceiverCounterTestData>>#testSelf.
	counter := ReceiverCounter new.
	selfReceiver := (counter receiverSelves: compiledMethod).
	self assert: selfReceiver equals: 2.
]

{ #category : 'tests' }
ReceiverCounterTest >> testSupersfCounter [
	| compiledMethod counter superReceiver|
	compiledMethod := ReceiverCounterTestData>>#testSuper.
	counter := ReceiverCounter new.
	superReceiver := (counter receiverSupers: compiledMethod).
	self assert: superReceiver equals: 3.
]

{ #category : 'tests' }
ReceiverCounterTest >> testVariableCounter [
	| compiledMethod counter superReceiver|
	compiledMethod := ReceiverCounterTestData>>#testVariable .
	counter := ReceiverCounter new.
	superReceiver := (counter receiverVariable: compiledMethod).
	self assert: superReceiver equals: 2.
]
