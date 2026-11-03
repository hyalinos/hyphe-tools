"
Tests of BlockDepthCounter: the examples of the Additional Metrics document (depth 0, 1, 2, 3) and blocks side by side.
"
Class {
	#name : 'BlockDepthCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
BlockDepthCounterTest >> testAnalysesDoNotAccumulate [
	"Analyzing another method starts again"

	| counter |
	counter := BlockDepthCounter new.
	counter analyzeMethod: MetricsTestData >> #deepBlocks.
	counter analyzeMethod: MetricsTestData >> #noBlocks.

	self assert: counter maxDepth equals: 0.
	self assert: counter blockCount equals: 0
]

{ #category : 'tests' }
BlockDepthCounterTest >> testBlockInBlock [
	"Depth 2, mean 1.5"

	| counter |
	counter := BlockDepthCounter new.
	counter analyzeMethod: MetricsTestData >> #nestedBlocks.

	self assert: counter maxDepth equals: 2.
	self assert: counter averageDepth equals: 1.5.
	self assert: counter blockDepths equals: (OrderedCollection withAll: #( 1 2 ))
]

{ #category : 'tests' }
BlockDepthCounterTest >> testNoBlock [
	"Depth 0"

	self assert: (BlockDepthCounter new maxDepthIn: MetricsTestData >> #noBlocks) equals: 0.
	self assert: (BlockDepthCounter new averageDepthIn: MetricsTestData >> #noBlocks) equals: 0
]

{ #category : 'tests' }
BlockDepthCounterTest >> testOneBlock [
	"Depth 1"

	self assert: (BlockDepthCounter new maxDepthIn: MetricsTestData >> #oneBlock) equals: 1.
	self assert: (BlockDepthCounter new averageDepthIn: MetricsTestData >> #oneBlock) equals: 1.0
]

{ #category : 'tests' }
BlockDepthCounterTest >> testSiblingBlocksAreNotNested [
	"Two blocks one after the other are both at depth 1"

	| counter |
	counter := BlockDepthCounter new.
	counter analyzeMethod: MetricsTestData >> #siblingBlocks.

	self assert: counter maxDepth equals: 1.
	self assert: counter blockCount equals: 2
]

{ #category : 'tests' }
BlockDepthCounterTest >> testSiblingsInsideABlock [
	"A block with two blocks inside has depth 2 (BlocsCounter, which counts the blocks inside the biggest block, says 3)"

	| counter |
	counter := BlockDepthCounter new.
	counter analyzeMethod: MetricsTestData >> #siblingsInABlock.

	self assert: counter maxDepth equals: 2.
	self assert: counter blockDepths equals: (OrderedCollection withAll: #( 1 2 2 )).
	self assert: (BlocsCounter new maxDephBlocInMethod: MetricsTestData >> #siblingsInABlock) equals: 3
]

{ #category : 'tests' }
BlockDepthCounterTest >> testThreeLevels [
	"Depth 3: do:, ifTrue: and the inner do: are three blocks inside each other, mean 2"

	| counter |
	counter := BlockDepthCounter new.
	counter analyzeMethod: MetricsTestData >> #deepBlocks.

	self assert: counter maxDepth equals: 3.
	self assert: counter averageDepth equals: 2.0.
	self assert: counter blockCount equals: 3
]
