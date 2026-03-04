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

	| method cfg statementNodes |
	method := OCParser parseMethod: 'cascade
		OrderedCollection new
			add: 2;
			yourself'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].

	self assert: cfg nodes size equals: 5.
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

	| method cfg |
	method := OCParser parseMethod: 'emptyMethod'.
	cfg := HyCFGBuilder buildFrom: method.

	self assert: cfg nodes size equals: 2.
	self assert: cfg edges size equals: 1.
	self assert: cfg nodes first class equals: HyCFGEntryNode.
	self assert: cfg nodes last class equals: HyCFGExitNode
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfEmpty [

	| method cfg cfNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifEmptyTest
		col ifEmpty: [ ^ ''hello'' ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGExitNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode)
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfEmptyIfNotEmpty [

	| method cfg cfgNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifEmptyIfNotempty
		col ifEmpty: [ y := 1 ] ifNotEmpty: [ ^ 2]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfgNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 5.
	self assert: cfg edges size equals: 5.
	self assert: cfgNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: trueEdge target astNode isAssignment.
	self assert: falseEdge target astNode isReturn
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfFalse [

	| method cfg cfNodes conditionalEdges falseEdge trueEdge|
	method := OCParser parseMethod: 'ifFalseTest
		x > 0 ifFalse: [ y := 1 ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGExitNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode)
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfIfFalseIfTrue [

	| method cfg cfgNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifTrueIfFalseTest
		x > 0 ifFalse: [ y := 1 ] ifTrue: [ ^ 2]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfgNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 5.
	self assert: cfg edges size equals: 5.
	self assert: cfgNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: falseEdge target astNode isAssignment.
	self assert: trueEdge target astNode isReturn
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfNilFalse [
	"ifNotNil with not nil receiver"

	| method cfg cfNodes conditionalEdges |
	method := OCParser parseMethod: 'ifNotNilTest
		nil ifNil: [ ^ true ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfNilIfNotNil [

	| method cfg cfgNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifNilIfNotNil
		x ifNil: [ y := 1 ] ifNotNil: [ ^ 2]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfgNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 5.
	self assert: cfg edges size equals: 5.
	self assert: cfgNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: trueEdge target astNode isAssignment.
	self assert: falseEdge target astNode isReturn
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfNotEmpty [

	| method cfg cfNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifEmptyTest
		col ifNotEmpty: [ ^ ''hello'' ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGExitNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode)
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfNotEmptyIfEmpty [

	| method cfg cfgNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifNotEmptyIfEmpty
		col ifNotEmpty: [ y := 1 ] ifEmpty: [ ^ 2]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfgNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 5.
	self assert: cfg edges size equals: 5.
	self assert: cfgNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: trueEdge target astNode isAssignment.
	self assert: falseEdge target astNode isReturn
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfNotNil [
	"ifNotNil with not nil receiver"

	| method cfg cfNodes conditionalEdges |
	method := OCParser parseMethod: 'ifNotNilTest
		1 ifNotNil: [ ^ true ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfNotNilFalse [
	"ifNotNil with not nil receiver"

	| method cfg cfNodes conditionalEdges |
	method := OCParser parseMethod: 'ifNotNilTest
		nil ifNotNil: [ ^ true ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfNotNilIfNil [

	| method cfg cfgNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifNotNilIfNil
		x ifNotNil: [ y := 1 ] ifNil: [ ^ 2]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfgNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 5.
	self assert: cfg edges size equals: 5.
	self assert: cfgNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: trueEdge target astNode isAssignment.
	self assert: falseEdge target astNode isReturn
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfTrue [
	"Test building CFG with ifTrue:"

	| method cfg cfNodes conditionalEdges falseEdge trueEdge|
	method := OCParser parseMethod: 'ifTrueTest
		x > 0 ifTrue: [ y := 1 ]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge :=  (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
	self assert: cfNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGExitNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode ).
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

	self assert: cfg nodes size equals: 3.
	self assert: cfg edges size equals: 3.
	self assert: conditionalEdges size equals: 2.
]

{ #category : 'tests' }
HyCFGBuilderTest >> testIfTrueIfFalse [

	| method cfg cfgNodes conditionalEdges falseEdge trueEdge |
	method := OCParser parseMethod: 'ifTrueIfFalseTest
		x > 0 ifTrue: [ y := 1 ] ifFalse: [ ^ 2]'.
	cfg := HyCFGBuilder buildFrom: method.

	cfgNodes := cfg nodes select: [ :n | n isKindOf: HyCFGControlFlowNode ].
	conditionalEdges := cfg edges select: [ :e | e isKindOf: HyCFGConditionalEdge ].
	falseEdge := (cfg edges select: [ :e | e isKindOf: HyCFGFalseEdge ]) first.
	trueEdge := (cfg edges select: [ :e | e isKindOf: HyCFGTrueEdge ]) first.

	self assert: cfg nodes size equals: 5.
	self assert: cfg edges size equals: 5.
	self assert: cfgNodes size equals: 1.
	self assert: conditionalEdges size equals: 2.
	self assert: (falseEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (falseEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: (trueEdge source isKindOf: HyCFGControlFlowNode).
	self assert: (trueEdge target isKindOf: HyCFGBlockScopeNode).
	self assert: trueEdge target astNode isAssignment.
	self assert: falseEdge target astNode isReturn
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

	self assert: cfg nodes size equals: 4.
	self assert: cfg edges size equals: 4.
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

	self assert: cfg nodes size equals: 2.
	self assert: cfg edges size equals: 1.
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

	self assert: cfg nodes size equals: 5.
	self assert: statementNodes size equals: 3.
	self assert: (cfg edges select: [ :e | e isKindOf: HyCFGSequentialEdge ]) size equals: 4
]
