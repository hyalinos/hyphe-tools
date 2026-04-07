Class {
	#name : 'ReceiverCounterTestData',
	#superclass : 'Object',
	#instVars : [
		'var1',
		'var2'
	],
	#classInstVars : [
		'varClass1',
		'varClass2'
	],
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
ReceiverCounterTestData class >> testVariableClass [
	varClass1 := 'Hello'.
	varClass2 := 5.
]

{ #category : 'tests' }
ReceiverCounterTestData >> testArgument: aNumber and: aString [
    aNumber printString.
    aString size.
	 aNumber size.
	 var1 := 3.
 
]

{ #category : 'tests' }
ReceiverCounterTestData >> testArgument: aNumber and: aString and: aClass [
    aNumber printString.
    aString size.
	 aNumber size.
	 aClass class.
	 var1 := 3.
 
]

{ #category : 'tests' }
ReceiverCounterTestData >> testLiteral [
    5 printString.
	 6 printString.
	 7 printString.
    'hello' size.
 
]

{ #category : 'tests' }
ReceiverCounterTestData >> testLocalVariable [
	| a b c d|
	a := 1.
	b := 2.
	d:= 5.
	c := a + b.
	^ c
	
 
]

{ #category : 'tests' }
ReceiverCounterTestData >> testMethod: arg1 and: arg2 [
   | local test|
	arg1 printString.
	arg2 size.
	self class.
	super initialize.
	test := 5.
	local := 0.
	local >10 ifTrue: [ 
		test := test + local.
		local := local + 1 ].
	var1 := test.
	'Hello' printString .
	'Pharo' class.
	
 
]

{ #category : 'tests' }
ReceiverCounterTestData >> testSelf [
    self class.
	
	
 
]

{ #category : 'tests' }
ReceiverCounterTestData >> testSuper [
    self class.
    super initialize.
	 super class.
	 super class.
	
	
 
]

{ #category : 'tests' }
ReceiverCounterTestData >> testVariable [
	|test|
	var1 := 1.
   var2 := 2.
	test := var1 + var2.
	
	
 
]
