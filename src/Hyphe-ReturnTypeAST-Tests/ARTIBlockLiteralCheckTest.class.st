"
Tests for ARTIBlockLiteralCheck (check 10): positive block-literal fixtures
(with and without arguments) and the direct/nested non-local-return exclusion fixtures.
"
Class {
	#name : 'ARTIBlockLiteralCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIBlockLiteralCheckTest >> testExclusionDirectNonLocalReturn [

	self assert: (ARTIBlockLiteralCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #blockLiteralExclusionNonLocalReturn)
			 context:
			 (ARTIFixtures contextForSelector:
				  #blockLiteralExclusionNonLocalReturn)) isNil
]

{ #category : 'tests' }
ARTIBlockLiteralCheckTest >> testExclusionNestedNonLocalReturn [

	self assert: (ARTIBlockLiteralCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #blockLiteralExclusionNestedNonLocalReturn)
			 context: (ARTIFixtures contextForSelector:
					  #blockLiteralExclusionNestedNonLocalReturn)) isNil
]

{ #category : 'tests' }
ARTIBlockLiteralCheckTest >> testNegativeNonBlockExpressionDoesNotMatch [

	self assert: (ARTIBlockLiteralCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #blockLiteralNegativeLiteral)
			 context:
			 (ARTIFixtures contextForSelector: #blockLiteralNegativeLiteral))
			isNil
]

{ #category : 'tests' }
ARTIBlockLiteralCheckTest >> testPositiveBlockWithArgAndNoReturn [

	self
		assert: (ARTIBlockLiteralCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #blockLiteralPositive)
				 context: (ARTIFixtures contextForSelector: #blockLiteralPositive))
		equals: (HTMClassRef named: #BlockClosure)
]

{ #category : 'tests' }
ARTIBlockLiteralCheckTest >> testPositiveZeroArgBlock [

	self
		assert: (ARTIBlockLiteralCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor:
					  #blockLiteralPositiveNoArgs)
				 context:
				 (ARTIFixtures contextForSelector: #blockLiteralPositiveNoArgs))
		equals: (HTMClassRef named: #BlockClosure)
]
