Class {
	#name : 'BlocCountersTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
BlocCountersTest >> testBlockInBlockInMessage [ 
	| blocCounter method count deph maxDeph|
	method := BlocCountersTestData >> #blockInBlockInMessage.
	blocCounter := BlocsCounter new.
	count := blocCounter numberOfBlocIn: method.
	deph := blocCounter dephBlocInMethod: method .
	maxDeph := blocCounter maxDephBlocInMethod: method.
	self assert: count equals: 2.
	self assert: deph size equals: 1.
   self assert: maxDeph  equals: 2.

]

{ #category : 'tests' }
BlocCountersTest >> testBlockWithReturn [
   | blocCounter method count deph|
	method := BlocCountersTestData >> #blockWithReturn .
	blocCounter := BlocsCounter new.
	count := blocCounter numberOfBlocIn: method.
	deph := blocCounter dephBlocInMethod: method .
	self assert: count equals: 1.
	self assert: deph size equals: 1.

	
]

{ #category : 'tests' }
BlocCountersTest >> testComplexcBloc [
	| blocCounter method count maxDeph|
	method := BlocCountersTestData >> #complexBlocks .
	blocCounter := BlocsCounter new.
	count := blocCounter numberOfBlocIn: method.
	maxDeph := blocCounter maxDephBlocInMethod: method.
	self assert: count equals: 6.
	self assert: maxDeph equals: 5.
]

{ #category : 'tests' }
BlocCountersTest >> testMethodTwoBloc [
	| blocCounter method count maxDeph|
	method := BlocCountersTestData >> #twoBloc .
	blocCounter := BlocsCounter new.
	count := blocCounter numberOfBlocIn: method.
	maxDeph := blocCounter maxDephBlocInMethod: method.
	self assert: count equals: 2.
	self assert: maxDeph equals: 1.
]

{ #category : 'tests' }
BlocCountersTest >> testMethodwithBloc [
	| blocCounter method count|
	method := BlocCountersTestData >> #methodWithBloc .
	blocCounter := BlocsCounter new.
	count := blocCounter numberOfBlocIn: method.
	self assert: count equals: 1.
]

{ #category : 'tests' }
BlocCountersTest >> testMethodwithoutBloc [
	| blocCounter method count|
	method := BlocCountersTestData >> #methodWithoutBloc .
	blocCounter := BlocsCounter new.
	count := blocCounter numberOfBlocIn: method.
	self assert: count equals: 0.
]
