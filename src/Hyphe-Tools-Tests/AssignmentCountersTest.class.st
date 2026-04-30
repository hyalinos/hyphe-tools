Class {
	#name : 'AssignmentCountersTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testAssignmentInBlock [
	| count method assignCount |
	method := AssignmentCountersTestData >> #assignmentInBlock.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 2.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testAssignmentInIf [
	| count method assignCount |
	method := AssignmentCountersTestData >> #assignmentInIf.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 2.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testAssignmentInLoop [
	| count method assignCount |
	method := AssignmentCountersTestData >> #assignmentInLoop.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 2.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testAssignmentWithReturn [
	| count method assignCount |
	method := AssignmentCountersTestData >> #assignmentWithReturn.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 2.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testChainedAssignment [
	| count method assignCount |
	method := AssignmentCountersTestData >> #chainedAssignment.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 2.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testComplexAssignments [
	| count method assignCount |
	method := AssignmentCountersTestData >> #complexAssignments.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 5.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testMultipleAssignments [
	| count method assignCount |
	method := AssignmentCountersTestData >> #multipleAssignments.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 3.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testNestedBlockAssignment [
	| count method assignCount |
	method := AssignmentCountersTestData >> #nestedBlockAssignment.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 2.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testNoAssignment [
	| count method assignCount |
	method := AssignmentCountersTestData >> #noAssignment.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 0.
	
]

{ #category : 'as yet unclassified' }
AssignmentCountersTest >> testReassignment [
	| count method assignCount |
	method := AssignmentCountersTestData >> #reassignment.
	assignCount := AssignmentCounter new.
	count := assignCount countAssignment: method.
	self assert: count equals: 3.
	
]
