"
Tests of HyCFGBuilder on statements and conditionals. Loops, exception handling and unusual code are tested in HyCFGBuilderLoopTest, HyCFGBuilderExceptionTest and HyCFGBuilderRobustnessTest.
"
Class {
	#name : 'HyCFGBuilderTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-CFG-Tests-Builder',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Builder'
}

{ #category : 'test' }
HyCFGBuilderTest >> testAssignmentStatement [
	"An assignment is a statement node: entry -> statement -> exit"

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

{ #category : 'test' }
HyCFGBuilderTest >> testCascade [
	"Each message of a cascade is a statement node"

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

{ #category : 'test' }
HyCFGBuilderTest >> testCommentOnly [
	"A method with only a comment has no statement"

	| method cfg statementNodes |
	method := OCParser parseMethod: 'messageStatement
		"hello "'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].

	self assert: statementNodes size equals: 0
]

{ #category : 'test' }
HyCFGBuilderTest >> testEmptyMethod [
	"An empty method is entry -> exit"

	| method cfg |
	method := OCParser parseMethod: 'emptyMethod'.
	cfg := HyCFGBuilder buildFrom: method.

	self assert: cfg nodes size equals: 2.
	self assert: cfg edges size equals: 1.
	self assert: cfg nodes first class equals: HyCFGEntryNode.
	self assert: cfg nodes last class equals: HyCFGExitNode
]

{ #category : 'test' }
HyCFGBuilderTest >> testIfEmpty [
	"ifEmpty: runs its block on the true edge, the false edge goes to the exit"

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

{ #category : 'test' }
HyCFGBuilderTest >> testIfEmptyIfNotEmpty [
	"ifEmpty:ifNotEmpty: has two branches"

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

{ #category : 'test' }
HyCFGBuilderTest >> testIfFalse [
	"ifFalse: runs its block on the false edge, the true edge goes to the exit"

	| method cfg cfNodes conditionalEdges falseEdge trueEdge |
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

{ #category : 'test' }
HyCFGBuilderTest >> testIfIfFalseIfTrue [
	"ifFalse:ifTrue: has two branches, the first block is the false one"

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

{ #category : 'test' }
HyCFGBuilderTest >> testIfNilIfNotNil [
	"ifNil:ifNotNil: has two branches"

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

{ #category : 'test' }
HyCFGBuilderTest >> testIfNotEmpty [
	"ifNotEmpty: runs its block on the false edge, the true edge goes to the exit"

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

{ #category : 'test' }
HyCFGBuilderTest >> testIfNotEmptyIfEmpty [
	"ifNotEmpty:ifEmpty: has two branches"

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

{ #category : 'test' }
HyCFGBuilderTest >> testIfNotNilIfNil [
	"ifNotNil:ifNil: has two branches"

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

{ #category : 'test' }
HyCFGBuilderTest >> testIfTrueIfFalse [
	"ifTrue:ifFalse: has a true branch and a false branch, both blocks of code"

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

{ #category : 'test' }
HyCFGBuilderTest >> testMessageStatement [
	"A message send is a statement node"

	| method cfg statementNodes |
	method := OCParser parseMethod: 'messageStatement
		1 isInteger'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].

	self assert: statementNodes size equals: 1.
	self assert: statementNodes first astNode isMessage.
	self assert: statementNodes first nestingDepth equals: 0
]

{ #category : 'test' }
HyCFGBuilderTest >> testPragmaOnly [
	"A pragma is not a statement: entry -> exit"

	| method cfg statementNodes |
	method := OCParser parseMethod: 'messageStatement
		<primitive: 1>'.
	cfg := HyCFGBuilder buildFrom: method.

	statementNodes := cfg nodes select: [ :n | n isKindOf: HyCFGStatementNode ].

	self assert: cfg nodes size equals: 2.
	self assert: cfg edges size equals: 1.
	self assert: statementNodes size equals: 0
]

{ #category : 'test' }
HyCFGBuilderTest >> testReturnStatement [
	"A return is a statement node"

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
