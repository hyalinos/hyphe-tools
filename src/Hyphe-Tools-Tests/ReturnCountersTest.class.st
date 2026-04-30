Class {
	#name : 'ReturnCountersTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
ReturnCountersTest >> testIfReturns [
	| method count returnCounter|
	method := ReturnCountersTestData >> #ifReturns.
	returnCounter := ReturnCounter new.
	count := returnCounter returnInMethod: method.
	self assert: count equals: 3.
]

{ #category : 'tests' }
ReturnCountersTest >> testMultipleReturns [
	| returnCounter method count|
	method := ReturnCountersTestData >> #multipleReturns.
	returnCounter := ReturnCounter new.
	count := returnCounter returnInMethod: method.
	self assert: count equals: 2.
]

{ #category : 'tests' }
ReturnCountersTest >> testNoReturn [
	| returnCounter method count|
	method := ReturnCountersTestData >> #noReturn.
	returnCounter := ReturnCounter new.
	count := returnCounter returnInMethod: method.
	self assert: count equals: 0.
]

{ #category : 'tests' }
ReturnCountersTest >> testOneReturn [
	| method count returnCounter|
	method := ReturnCountersTestData >> #oneReturn.
	returnCounter := ReturnCounter new.
	count := returnCounter returnInMethod: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
ReturnCountersTest >> testReturnInCollect [
	| method count returnCounter|
	method := ReturnCountersTestData >> #returnInCollect.
	returnCounter := ReturnCounter new.
	count := returnCounter returnInMethod: method.
	self assert: count equals: 2.
]

{ #category : 'tests' }
ReturnCountersTest >> testTrickyReturns [
	| method count returnCounter|
	method := ReturnCountersTestData >> #trickyReturns.
	returnCounter := ReturnCounter new.
	count := returnCounter returnInMethod: method.
	self assert: count equals: 3.
]
