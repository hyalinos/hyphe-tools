Class {
	#name : 'NilDensityTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
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
NilDensityTest >> testMethodWithEqualsNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithEqualsNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3)
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
NilDensityTest >> testMethodWithIfNilIfNotNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithIfNilIfNotNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/2)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithIfNotNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithIfNotNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithIfNotNilIfNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithIfNotNilIfNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/2)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithIsNotNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithIsNotNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithMultipleNilChecks [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithMultipleNilChecks.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: 3 / 7
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
NilDensityTest >> testMethodWithNilOnTheLeft [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithNilOnTheLeft.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithNilValuesOnly [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithNilValuesOnly.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (0)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithNotEqualNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithNotEqualNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithNotIdenticalNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithNotIdenticalNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3)
]

{ #category : 'tests' }
NilDensityTest >> testMethodWithNotNil [
	| method nilDensity count |
	method := NilDensityTestData >> #methodWithNotNil.
	nilDensity := NilDensity new.
	count := nilDensity nilCountIn: method.
	self assert: count equals: (1/3)
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
