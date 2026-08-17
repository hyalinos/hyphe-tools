"
REQ-C2: for one representative fixture per ExplicitReturn-eligible check (1,
2, 3, 4, 7, 8, 9, 10), confirms that check and only that check among all eight ever classifies it --
covering every pair of checks at once rather than fixture-by-fixture.
"
Class {
	#name : 'ARTICheckPairwiseDisjointTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'asserting' }
ARTICheckPairwiseDisjointTest >> assertExactlyOneMatchFor: aSelector expected: expectedCheckClass [

	| terminal context matches |
	terminal := ARTIFixtures explicitReturnTerminalFor: aSelector.
	context := ARTIFixtures contextForSelector: aSelector.
	matches := self explicitReturnChecks select: [ :checkClass |
		           (checkClass classify: terminal context: context) notNil ].
	self assert: matches size equals: 1.
	self assert: matches first equals: expectedCheckClass
]

{ #category : 'accessing' }
ARTICheckPairwiseDisjointTest >> explicitReturnChecks [
	"REQ-C2: the 8 checks that can match an ExplicitReturn(Expr) terminal."

	^ {
		  ARTILiteralCheck.
		  ARTIClassGlobalReadCheck.
		  ARTISelfCheck.
		  ARTISelfClassCheck.
		  ARTIClassNameNewCheck.
		  ARTITypeVarCheck.
		  ARTICascadeShapeCheck.
		  ARTIBlockLiteralCheck }
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testBlockLiteralShapeMatchesOnlyThatCheck [

	self
		assertExactlyOneMatchFor: #blockLiteralPositive
		expected: ARTIBlockLiteralCheck
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testCascadeShapeMatchesOnlyCascadeCheckEvenThoughReceiverAlsoMatchesLiteralCheck [

	self
		assertExactlyOneMatchFor: #cascadeOnLiteral
		expected: ARTICascadeShapeCheck
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testClassGlobalReadShapeMatchesOnlyThatCheck [

	self
		assertExactlyOneMatchFor: #classGlobalReadPositive
		expected: ARTIClassGlobalReadCheck
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testClassNameNewShapeMatchesOnlyThatCheck [

	self
		assertExactlyOneMatchFor: #classNameNewPositiveObject
		expected: ARTIClassNameNewCheck
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testLiteralShapeMatchesOnlyLiteralCheck [

	self
		assertExactlyOneMatchFor: #literalInteger
		expected: ARTILiteralCheck
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testSelfClassShapeMatchesOnlySelfClassCheck [

	self
		assertExactlyOneMatchFor: #selfClassPositive
		expected: ARTISelfClassCheck
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testSelfShapeMatchesOnlySelfCheck [

	self assertExactlyOneMatchFor: #selfPositive expected: ARTISelfCheck
]

{ #category : 'tests' }
ARTICheckPairwiseDisjointTest >> testTypeVarShapeMatchesOnlyThatCheck [

	self
		assertExactlyOneMatchFor: #typeVarPositive:
		expected: ARTITypeVarCheck
]
