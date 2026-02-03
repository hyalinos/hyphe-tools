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
StatementCounterTest >> testReturnStatement [
    | method count |
    method := StatementCounterTestsData >> #methodWithReturn.  
    count := StatementCounter countStatementsIn: method.
    self assert: count equals: 1 
]
