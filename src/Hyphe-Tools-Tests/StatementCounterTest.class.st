Class {
	#name : 'StatementCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
StatementCounterTest >> testAssignmentStatement [
    | method count |
    method := StatementCounterTestsData >> #methodWithAssignment .  
    count := StatementCounter countStatementsIn: method.
    self assert: count equals: 1 
]

{ #category : 'tests' }
StatementCounterTest >> testMethodEmpty [

	| method count |
	method := StatementCounterTestsData >> #methodEmpty.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 0
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithBinaryMessage [

	| method count |
	method := StatementCounterTestsData >> #methodWithBinaryMessage.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 1
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithBlock [

	| method count |
	method := StatementCounterTestsData >> #methodWithBlock.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 4
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithCascade [

	| method count |
	method := StatementCounterTestsData >> #methodWithCascade.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 4
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithComment [

	| method count |
	method := StatementCounterTestsData >> #methodWithComment.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 0
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithKeywordMessage [

	| method count |
	method := StatementCounterTestsData >> #methodWithKeywordMessage.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 1
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithPragma [

	| method count |
	method := StatementCounterTestsData >> #methodWithPragma.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 0
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithReturn [

	| method count |
	method := StatementCounterTestsData >> #methodWithReturn.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 1
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithUnaryMessage [

	| method count |
	method := StatementCounterTestsData >> #methodWithUnaryMessage.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 1
]

{ #category : 'tests' }
StatementCounterTest >> testMethodWithVariableDeclaration [

	| method count |
	method := StatementCounterTestsData >> #methodWithVariableDeclaration.
	count := StatementCounter countStatementsIn: method.
	self assert: count equals: 0
]
