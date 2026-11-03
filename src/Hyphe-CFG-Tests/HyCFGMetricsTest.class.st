"
Tests of the metrics a HyCFG answers, mainly the cyclomatic complexity, on hand-made graphs and on the graphs the builder makes for real control structures.
"
Class {
	#name : 'HyCFGMetricsTest',
	#superclass : 'HyCFGAbstractTest',
	#category : 'Hyphe-CFG-Tests-Structure',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Structure'
}

{ #category : 'helpers' }
HyCFGMetricsTest >> complexityOf: aBodyString [
	"The cyclomatic complexity of the CFG of a method whose body is the argument"

	^ (self cfgForBody: aBodyString) cyclomaticComplexity
]

{ #category : 'tests' }
HyCFGMetricsTest >> testBooleanOperatorsAreNotBranches [
	"and: and or: are not control flow nodes in the CFG, so they add nothing, unlike in the textbook count of conditions"

	self assert: (self complexityOf: '^ self a and: [ self b ]') equals: 1
]

{ #category : 'tests' }
HyCFGMetricsTest >> testConditionals [
	"Each conditional adds 1, with or without else branch"

	self assert: (self complexityOf: '^ self a ifTrue: [ 1 ] ifFalse: [ 2 ]') equals: 2.
	self assert: (self complexityOf: 'self a ifTrue: [ ^ 1 ]. ^ 2') equals: 2.
	self assert: (self complexityOf: 'self a ifTrue: [ self b ]. self c ifTrue: [ self d ]. ^ 1') equals: 3
]

{ #category : 'tests' }
HyCFGMetricsTest >> testDocumentationExamples [
	"The complexities that the documentation of the metric quotes"

	| expected |
	expected := {
		            (#straightLine -> 1).
		            (#oneConditional: -> 2).
		            (#loopWithConditional: -> 3).
		            (#withHandler -> 2).
		            (#booleanOperators: -> 1).
		            (#everything: -> 4) }.
	expected do: [ :each |
		self assert: (HyCFGBuilder buildFrom: (HyCFGDocExamples >> each key) ast) cyclomaticComplexity equals: each value ]
]

{ #category : 'tests' }
HyCFGMetricsTest >> testExceptionHandler [
	"A handler is one more way through the method"

	self assert: (self complexityOf: '^ [ self a ] on: Error do: [ :ex | 0 ]') equals: 2
]

{ #category : 'tests' }
HyCFGMetricsTest >> testHandMadeBranch [
	"A diamond (one condition) adds one to the straight line"

	| cfg entry exit cond left right |
	cfg := HyCFG new.
	entry := HyCFGEntryNode new.
	exit := HyCFGExitNode new.
	cond := HyCFGStatementNode new.
	left := HyCFGStatementNode new.
	right := HyCFGStatementNode new.
	cfg entryNode: entry.
	cfg exitNode: exit.
	{
		entry.
		exit.
		cond.
		left.
		right } do: [ :n | cfg addNode: n ].
	cfg addEdge: (HyCFGSequentialEdge from: entry to: cond).
	cfg addEdge: (HyCFGTrueEdge from: cond to: left).
	cfg addEdge: (HyCFGFalseEdge from: cond to: right).
	cfg addEdge: (HyCFGSequentialEdge from: left to: exit).
	cfg addEdge: (HyCFGSequentialEdge from: right to: exit).

	self assert: cfg cyclomaticComplexity equals: 2
]

{ #category : 'tests' }
HyCFGMetricsTest >> testHandMadeStraightLine [
	"entry -> statement -> exit: 2 edges, 3 nodes, so 1"

	| cfg |
	cfg := self simpleCFG.

	self assert: cfg cyclomaticComplexity equals: 1.
	self assert: cfg reachableNodes size equals: 3
]

{ #category : 'tests' }
HyCFGMetricsTest >> testLoops [
	"Every loop adds 1, a conditional inside adds another"

	self assert: (self complexityOf: '[ self a ] whileTrue: [ self b ]. ^ 1') equals: 2.
	self assert: (self complexityOf: '1 to: 3 do: [ :i | self b ]') equals: 2.
	self assert: (self complexityOf: 'self items do: [ :e | e isNil ifTrue: [ ^ e ] ]') equals: 3
]

{ #category : 'tests' }
HyCFGMetricsTest >> testMetricsDictionary [
	"The dictionary agrees with the individual measures"

	| cfg metrics |
	cfg := self cfgForBody: 'self items do: [ :e | e isNil ifTrue: [ ^ e ] ]. ^ 2'.
	metrics := cfg metrics.

	self assert: (metrics at: #cyclomaticComplexity) equals: cfg cyclomaticComplexity.
	self assert: (metrics at: #nodes) equals: cfg nodes size.
	self assert: (metrics at: #edges) equals: cfg edges size.
	self assert: (metrics at: #loops) equals: 1.
	self assert: (metrics at: #controlFlow) equals: 2.
	self assert: (metrics at: #maxNestingDepth) equals: cfg maxNestingDepth.
	self assert: (metrics at: #isComplete)
]

{ #category : 'tests' }
HyCFGMetricsTest >> testNestedConditionals [
	"A conditional in a conditional adds 1 more"

	self assert: (self complexityOf: 'self a ifTrue: [ self b ifTrue: [ ^ 3 ] ]. ^ 2') equals: 3
]

{ #category : 'tests' }
HyCFGMetricsTest >> testNoEntryNodeGivesZero [
	"An empty CFG has no complexity and no reachable node"

	| cfg |
	cfg := HyCFG new.

	self assert: cfg cyclomaticComplexity equals: 0.
	self assert: cfg reachableNodes isEmpty
]

{ #category : 'tests' }
HyCFGMetricsTest >> testStraightLineMethod [
	"No decision: 1, however many statements"

	self assert: (self complexityOf: '^ 1') equals: 1.
	self assert: (self complexityOf: 'self a. self b. self c. ^ 1') equals: 1
]

{ #category : 'tests' }
HyCFGMetricsTest >> testUnreachableNodesAreIgnored [
	"A node added without edge does not change the complexity"

	| cfg |
	cfg := self simpleCFG.
	cfg addNode: (HyCFGStatementNode createWithNesting: 0).

	self assert: cfg nodes size equals: 4.
	self assert: cfg reachableNodes size equals: 3.
	self assert: cfg cyclomaticComplexity equals: 1
]
