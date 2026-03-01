"
A HyCFGBuilderTest is a test class for testing the behavior of HyCFGBuilder
"
Class {
	#name : 'HyCFGBuilderTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-CFG-Tests-Builder',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Builder'
}

{ #category : 'tests' }
HyCFGBuilderTest >> testAssignmentStatement [

	| method cfg statementNodes |
	method := OCParser parseMethod: 'singleStatement
		x := 42'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].
	
	self assert: cfg nodes size equals: 3.
	self assert: cfg edges size equals: 2.
	self assert: statementNodes size equals: 1.
	self assert: statementNodes first astNode isAssignment.
	self assert: statementNodes first nestingDepth equals: 0
]

{ #category : 'tests' }
HyCFGBuilderTest >> testCascade [
	"Test building CFG from method with sequential statements"
	
	| method cfg statementNodes |
	method := OCParser parseMethod: 'cascade
		OrderedCollection new
			add: 2;
			yourself'.
	cfg := HyCFGBuilder buildFrom: method.
	
	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].
	
	self assert: statementNodes size equals: 3.
	self assert: (cfg edges select: [ :e | e isKindOf: HyCFGSequentialEdge ]) size equals: 4
]

{ #category : 'tests' }
HyCFGBuilderTest >> testCommentOnly [

	| method cfg statementNodes |
	method := OCParser parseMethod: 'messageStatement
		"hello "'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].

	self assert: statementNodes size equals: 0.
]

{ #category : 'tests' }
HyCFGBuilderTest >> testEmptyMethod [

	| method cfg edge|
	method := OCParser parseMethod: 'emptyMethod'.
	cfg := HyCFGBuilder buildFrom: method.

	self assert: cfg notNil.
	self assert: cfg entryNode notNil.
	self assert: cfg exitNode notNil.
	self assert: (cfg nodes includes: cfg entryNode).
	self assert: (cfg nodes includes: cfg exitNode).
	self assert: (cfg edges size) equals: 1.
	
	edge := cfg edges first.
	self assert: (edge class) equals: HyCFGSequentialEdge.
	self assert: (edge source) equals: cfg entryNode.
	self assert: (edge target) equals: cfg exitNode. 
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfTrue [
	"Test building CFG with ifTrue:"

	| method cfg cfNodes conditionalEdges |
	method := OCParser parseMethod: 'ifTrueTest
		x > 0 ifTrue: [ y := 1 ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].

	self assert: cfg nodes size equals: 6.
	self assert: cfg edges size equals: 6.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfTrueEmptyBlock [
	"Test building CFG with ifTrue:"

	| method cfg cfNodes conditionalEdges |
	method := OCParser parseMethod: 'ifTrueTest
		x > 0 ifTrue: [ ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: conditionalEdges size equals: 2.
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfTrueWithReturn [
	"Test building CFG with ifTrue:"

	| method cfg cfNodes conditionalEdges |
	method := OCParser parseMethod: 'ifTrueTest
		x > 0 ifTrue: [ ^ self ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].

	self assert: cfg nodes size equals: 6.
	self assert: cfg edges size equals: 6.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2
]

{ #category : 'tests' }
HyCFGBuilderTest >> testMessageStatement [
	
	| method cfg statementNodes |
	method := OCParser parseMethod: 'messageStatement
		1 isInteger'.
	cfg := HyCFGBuilder buildFrom: method.
	
	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].
	
	self assert: statementNodes size equals: 1.
	self assert: statementNodes first astNode isMessage.
	self assert: statementNodes first nestingDepth equals: 0
]

{ #category : 'tests' }
HyCFGBuilderTest >> testPragmaOnly [

	| method cfg statementNodes |
	method := OCParser parseMethod: 'messageStatement
		<primitive: 1>'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].

	self assert: statementNodes size equals: 0
]

{ #category : 'tests' }
HyCFGBuilderTest >> testReturnStatement [

	| method cfg statementNodes |
	method := OCParser parseMethod: 'returnStatement
		^ x'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].
	
	self assert: cfg nodes size equals: 3.
	self assert: statementNodes size equals: 1.
	self assert: statementNodes first astNode isReturn.
	self assert: statementNodes first nestingDepth equals: 0
]

{ #category : 'tests' }
HyCFGBuilderTest >> testSequentialStatements [
	"Test building CFG from method with sequential statements"
	
	| method cfg statementNodes |
	method := OCParser parseMethod: 'sequential
		x := 1.
		y := 2.
		z := 3'.
	cfg := HyCFGBuilder buildFrom: method.
	
	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].
	
	self assert: statementNodes size equals: 3.
	self assert: (cfg edges select: [ :e | e isKindOf: HyCFGSequentialEdge ]) size equals: 4
]
