"
Tests for ARTIPipeline (REQ-U1..U4): plain single-type results, same-type de-duplication
collapsing a union to one member, partial no-match folding Unknown into a union (REQ-U3), total no-match
being exactly Unknown rather than an empty union (REQ-U4), and the two exclusion gates.
"
Class {
	#name : 'ARTIPipelineTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIPipelineTest >> testAllClassifiedTerminalsProduceAPlainUnionOrSingleType [

	self
		assert: (ARTIPipeline
				 inferType: ARTIFixtures class >> #literalInteger
				 safetyTable: ARTINewSafetyTable new)
		equals: (HTMClassRef named: #Integer)
]

{ #category : 'tests' }
ARTIPipelineTest >> testDynamicArrayClassifiesAsClassRefArrayThroughFullPipeline [

	self
		assert: (ARTIPipeline
				 inferType: ARTIFixtures class >> #dynamicArrayPositive
				 safetyTable: ARTINewSafetyTable new)
		equals: (HTMClassRef named: #Array)
]

{ #category : 'tests' }
ARTIPipelineTest >> testEmptyBodyMethodIsExcluded [

	self
		assert: (ARTIPipeline
				 inferType: ARTIFixtures class >> #gateEmptyCommentOnly
				 safetyTable: ARTINewSafetyTable new)
		equals: #excludedEmpty
]

{ #category : 'tests' }
ARTIPipelineTest >> testPartialNoMatchFoldsIntoUnionWithUnknown [
	"REQ-U3: one branch classifies (Integer literal), the other is an arbitrary unclassifiable
	send -- the method still appears with a result, Unknown folded into the union."

	| result |
	result := ARTIPipeline
		          inferType:
		          ARTIFixtures class >> #partialUnknownMixedBranches:
		          safetyTable: ARTINewSafetyTable new.
	self assert: result isUnion.
	self assert: result members size equals: 2.
	self assert:
		(result members includes: (HTMClassRef named: #Integer)).
	self assert: (result members includes: HTMUnknown new)
]

{ #category : 'tests' }
ARTIPipelineTest >> testPrimitiveMethodIsExcluded [

	self
		assert: (ARTIPipeline
				 inferType: ARTIFixtures class >> #gatePrimitiveExcluded
				 safetyTable: ARTINewSafetyTable new)
		equals: #excludedPrimitive
]

{ #category : 'tests' }
ARTIPipelineTest >> testSingleAssignmentTempClassifiesThroughFullPipeline [

	self
		assert: (ARTIPipeline
				 inferType: ARTIFixtures class >> #singleAssignTempPositive
				 safetyTable: ARTINewSafetyTable new)
		equals: (HTMClassRef named: #Integer)
]

{ #category : 'tests' }
ARTIPipelineTest >> testSingleUnclassifiableTerminalIsExactlyUnknown [

	| result |
	result := ARTIPipeline
		          inferType: ARTIFixtures class >> #unknownArbitrarySend
		          safetyTable: ARTINewSafetyTable new.
	self assert: result equals: HTMUnknown new
]

{ #category : 'tests' }
ARTIPipelineTest >> testTotalNoMatchIsExactlyUnknownNotAnEmptyUnion [
	"REQ-U4."

	| result |
	result := ARTIPipeline
		          inferType:
		          ARTIFixtures class
		          >> #totalUnknownAllBranchesUnclassifiable:
		          safetyTable: ARTINewSafetyTable new.
	self assert: result equals: HTMUnknown new.
	self deny: result isUnion
]

{ #category : 'tests' }
ARTIPipelineTest >> testUnionOfDifferentlyClassifiedTerminalsCollapsesDuplicates [
	"REQ-U2 + de-duplication: both branches classify to the same ClassRef(Integer), so the whole
	method's type collapses to that single type rather than a two-member union."

	self
		assert: (ARTIPipeline
				 inferType: ARTIFixtures class >> #reachIfTrueIfFalseBothReturn:
				 safetyTable: ARTINewSafetyTable new)
		equals: (HTMClassRef named: #Integer)
]

{ #category : 'tests' }
ARTIPipelineTest >> testUnsafeClassNameNewFallsBackToUnknownRatherThanNoMatchAtWholeMethodLevel [
	"Check 7 itself reports no match for an unsafe class; at the pipeline level that surfaces as
	Unknown (REQ-U4), distinguishing 'we don't know' from 'the class new is definitely a ClassRef'."

	self
		assert: (ARTIPipeline
				 inferType: ARTIFixtures class >> #classNameNewNegativeUnsafe
				 safetyTable: ARTINewSafetyTable new)
		equals: HTMUnknown new
]
