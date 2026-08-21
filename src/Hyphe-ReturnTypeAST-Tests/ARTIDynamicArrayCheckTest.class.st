"
Tests for ARTIDynamicArrayCheck: dynamic-array-literal fixtures
(with/without elements, arbitrary element expressions), negative fixtures confirming it stays disjoint from
check 1's literal-array territory, and a non-ExplicitReturn negative.
"
Class {
	#name : 'ARTIDynamicArrayCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIDynamicArrayCheckTest >> testNegativeLiteralArrayDoesNotMatch [
	"#(1 2 3) is OCLiteralArrayNode -- check 1's territory, not this check's."

	self assert: (ARTIDynamicArrayCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #dynamicArrayNegativeLiteralArray)
			 context:
			 (ARTIFixtures contextForSelector:
				  #dynamicArrayNegativeLiteralArray)) isNil
]

{ #category : 'tests' }
ARTIDynamicArrayCheckTest >> testNegativeLiteralDoesNotMatch [

	self assert: (ARTIDynamicArrayCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #dynamicArrayNegativeLiteral)
			 context:
			 (ARTIFixtures contextForSelector: #dynamicArrayNegativeLiteral))
			isNil
]

{ #category : 'tests' }
ARTIDynamicArrayCheckTest >> testNonExplicitReturnTerminalNeverMatches [

	self assert: (ARTIDynamicArrayCheck
			 classify: (ARTIImplicitEndTerminal forMethod: nil)
			 context: nil) isNil
]

{ #category : 'tests' }
ARTIDynamicArrayCheckTest >> testPositiveDynamicArray [

	self
		assert: (ARTIDynamicArrayCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #dynamicArrayPositive)
				 context: (ARTIFixtures contextForSelector: #dynamicArrayPositive))
		equals: (HTMClassRef named: #Array)
]

{ #category : 'tests' }
ARTIDynamicArrayCheckTest >> testPositiveDynamicArrayWithArbitraryElementExpressions [
	"The check never inspects the elements -- {...} builds an Array unconditionally regardless of
	what's inside it."

	self
		assert: (ARTIDynamicArrayCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor:
						  #dynamicArrayPositiveWithExpressions)
				 context:
				 (ARTIFixtures contextForSelector:
					  #dynamicArrayPositiveWithExpressions))
		equals: (HTMClassRef named: #Array)
]

{ #category : 'tests' }
ARTIDynamicArrayCheckTest >> testPositiveEmptyDynamicArray [

	self
		assert: (ARTIDynamicArrayCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor:
					  #dynamicArrayPositiveEmpty)
				 context:
				 (ARTIFixtures contextForSelector: #dynamicArrayPositiveEmpty))
		equals: (HTMClassRef named: #Array)
]
