Class {
	#name : 'CapturedVariableCountersTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
CapturedVariableCountersTest >> testArgumentMethodNotCaptured [ 
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #argumentMethodNotCaptured:.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 0.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testBolckLocalNotCaptured [ 
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #blockLocalNotCaptured.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 0.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testCaptureVariable [ 
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #captureVariable.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testComplexCapture [ 
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #complexCapture.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 3.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testDuplicateUse [ 
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #duplicateUse.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testIfElseCapture [
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #ifElseCapture.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 2.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testIfTrueCapture [
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #ifTrueCapture.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testMixedVariables [
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #mixedVariables.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testMultipleBlocksDifferentVars [
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #multipleBlocksDifferentVars.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 2.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testMultipleBlocksSameVar [
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #multipleBlocksSameVar.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testNestedBlockCapture [
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #multipleBlocksSameVar.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
CapturedVariableCountersTest >> testNoCapture [
	| captureCounter method count|
	method := CapturedVariableCountersTestData >> #noCapture.
	captureCounter := CapturedVariableCounter new.
	count := captureCounter numberOfCapturedVariables: method.
	self assert: count equals: 0.
]
