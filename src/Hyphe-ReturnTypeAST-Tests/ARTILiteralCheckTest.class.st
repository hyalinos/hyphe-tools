"
Tests for ARTILiteralCheck (check 1): positive fixtures across literal kinds (including
normalization), the dynamic-array negative fixture, and non-matching terminal kinds.
"
Class {
	#name : 'ARTILiteralCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTILiteralCheckTest >> testNegativeDynamicArrayIsNotALiteralNode [

	self assert: (ARTILiteralCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #literalNegativeDynamicArray)
			 context:
			 (ARTIFixtures contextForSelector: #literalNegativeDynamicArray))
			isNil
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testNegativeDynamicArrayStillDoesNotMatchCheck1 [
	"Regression guard for the ARTIDynamicArrayCheck addition: check 1 must keep reporting no match for
	{...}, since that shape now belongs to ARTIDynamicArrayCheck instead."

	self assert: (ARTILiteralCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #dynamicArrayPositive)
			 context: (ARTIFixtures contextForSelector: #dynamicArrayPositive))
			isNil
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testNegativeGlobalReadDoesNotMatch [

	self assert: (ARTILiteralCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #literalNegativeGlobalRead)
			 context:
			 (ARTIFixtures contextForSelector: #literalNegativeGlobalRead))
			isNil
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testNonExplicitReturnTerminalNeverMatches [

	self assert: (ARTILiteralCheck
			 classify: (ARTIImplicitEndTerminal forMethod: nil)
			 context: nil) isNil
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testPositiveInteger [

	self
		assert: (ARTILiteralCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #literalInteger)
				 context: (ARTIFixtures contextForSelector: #literalInteger))
		equals: (ARTIClassRef named: #Integer)
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testPositiveLiteralArray [

	self
		assert: (ARTILiteralCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor: #literalArray)
				 context: (ARTIFixtures contextForSelector: #literalArray))
		equals: (ARTIClassRef named: #Array)
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testPositiveStringNormalizesFromByteString [

	self
		assert: (ARTILiteralCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #literalString)
				 context: (ARTIFixtures contextForSelector: #literalString))
		equals: (ARTIClassRef named: #String)
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testPositiveSymbolNormalizesToString [

	self
		assert: (ARTILiteralCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #literalSymbol)
				 context: (ARTIFixtures contextForSelector: #literalSymbol))
		equals: (ARTIClassRef named: #String)
]

{ #category : 'tests' }
ARTILiteralCheckTest >> testPositiveTrueNormalizesToBoolean [

	self
		assert: (ARTILiteralCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor: #literalTrue)
				 context: (ARTIFixtures contextForSelector: #literalTrue))
		equals: (ARTIClassRef named: #Boolean)
]
