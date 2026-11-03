"
I measure how deeply the blocks of a method are nested. A block that is in no other block has depth 1, a block inside it depth 2, and so on; a method without block has depth 0. maxDepth is the deepest block, averageDepth the mean over all the blocks (0 if none). Use: BlockDepthCounter new maxDepthIn: aCompiledMethod. Unlike BlocsCounter, which counts the blocks inside the biggest outer block, I follow the definition of the 'Additional Metrics' document (see the examples in BlockDepthCounterTestData).
"
Class {
	#name : 'BlockDepthCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'depth',
		'depths'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'analysis' }
BlockDepthCounter >> analyzeMethod: aCompiledMethod [
	"Measure the blocks of a method; ask maxDepth, averageDepth, blockCount afterwards. Answer the receiver."

	depth := 0.
	depths := OrderedCollection new.
	aCompiledMethod ast acceptVisitor: self
]

{ #category : 'accessing' }
BlockDepthCounter >> averageDepth [
	"Answer the mean depth of the blocks as a Float, 0 if there is none"

	^ depths isEmpty
		  ifTrue: [ 0 ]
		  ifFalse: [ depths sum / depths size asFloat ]
]

{ #category : 'analysis' }
BlockDepthCounter >> averageDepthIn: aCompiledMethod [
	"Answer the mean depth of the blocks of the method, 0 if it has no block"

	self analyzeMethod: aCompiledMethod.
	^ self averageDepth
]

{ #category : 'accessing' }
BlockDepthCounter >> blockCount [
	"Answer the number of blocks of the analyzed method"

	^ depths size
]

{ #category : 'accessing' }
BlockDepthCounter >> blockDepths [
	"Answer the depth of each block, in the order the blocks were met"

	^ depths copy
]

{ #category : 'initialization' }
BlockDepthCounter >> initialize [
	"Start outside of any block, with no block seen"

	super initialize.
	depth := 0.
	depths := OrderedCollection new
]

{ #category : 'accessing' }
BlockDepthCounter >> maxDepth [
	"Answer the depth of the deepest block, 0 if there is none"

	^ depths isEmpty
		  ifTrue: [ 0 ]
		  ifFalse: [ depths max ]
]

{ #category : 'analysis' }
BlockDepthCounter >> maxDepthIn: aCompiledMethod [
	"Answer the depth of the deepest block of the method, 0 if it has no block"

	self analyzeMethod: aCompiledMethod.
	^ self maxDepth
]

{ #category : 'visiting' }
BlockDepthCounter >> visitBlockNode: aBlockNode [
	"A block is one level deeper than the block around it"

	depth := depth + 1.
	depths add: depth.
	[ super visitBlockNode: aBlockNode ] ensure: [ depth := depth - 1 ]
]
