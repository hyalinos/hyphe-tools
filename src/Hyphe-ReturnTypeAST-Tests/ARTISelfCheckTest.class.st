"
Tests for ARTISelfCheck (check 3): positive self/super fixtures and negative fixtures
(self class, a plain literal) confirming it doesn't overreach into check 4's territory.
"
Class {
	#name : 'ARTISelfCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTISelfCheckTest >> testNegativeLiteralDoesNotMatch [

	self assert: (ARTISelfCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #selfNegativeLiteral)
			 context: (ARTIFixtures contextForSelector: #selfNegativeLiteral))
			isNil
]

{ #category : 'tests' }
ARTISelfCheckTest >> testNegativeSelfClassMessageDoesNotMatch [

	self assert: (ARTISelfCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #selfNegativeClassMessage)
			 context:
			 (ARTIFixtures contextForSelector: #selfNegativeClassMessage))
			isNil
]

{ #category : 'tests' }
ARTISelfCheckTest >> testPositiveSelf [

	self
		assert: (ARTISelfCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor: #selfPositive)
				 context: (ARTIFixtures contextForSelector: #selfPositive))
		equals: ARTISelfType new
]

{ #category : 'tests' }
ARTISelfCheckTest >> testPositiveSuper [

	self
		assert: (ARTISelfCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #superPositive)
				 context: (ARTIFixtures contextForSelector: #superPositive))
		equals: ARTISelfType new
]
