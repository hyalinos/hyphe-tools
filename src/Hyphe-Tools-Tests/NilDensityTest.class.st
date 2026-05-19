Class {
	#name : 'NilDensityTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
NilDensityTest >> testMethodNil [
	| method nilDensity count|
	method := NilDensityTestData >> #methodNil .
	nilDensity := NilDensity new .
	count := nilDensity nilCountIn: method.
	self assert: count equals: (3/4).
	
	
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithEqualityNil [
	| method nilDensity count|
	method := NilDensityTestData >> #methodWithEqualityNil .
	nilDensity := NilDensity new .
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3).
	
	
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithIfNil [
	| method nilDensity count|
	method := NilDensityTestData >> #methodWithIfNil .
	nilDensity := NilDensity new .
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3).
	
	
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithMultipleNilChecks [
	| method nilDensity count|
	method := NilDensityTestData >> #methodWithMultipleNilChecks .
	nilDensity := NilDensity new .
	count := nilDensity nilCountIn: method.
	self assert: count equals: (2/7).
	
	
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithNestedNilChecks [
	| method nilDensity count|
	method := NilDensityTestData >> #methodWithNestedNilChecks .
	nilDensity := NilDensity new .
	count := nilDensity nilCountIn: method.
	self assert: count equals: (2/7).
	
	
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithSingleIsNil [
	| method nilDensity count|
	method := NilDensityTestData >> #methodWithSingleIsNil .
	nilDensity := NilDensity new .
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3).
	
	
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithoutNil [
	| method nilDensity count|
	method := NilDensityTestData >> #methodWithoutNil .
	nilDensity := NilDensity new .
	count := nilDensity nilCountIn: method.
	self assert: count equals: 0.
	
	
]
