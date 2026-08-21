"
Tests for ARTIImplicitNoReturnCheck (check 5): matches only an
ARTIImplicitEndTerminal, never an ExplicitReturn or Bottom terminal (REQ-C1).
"
Class {
	#name : 'ARTIImplicitNoReturnCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIImplicitNoReturnCheckTest >> testNegativeBottomTerminalDoesNotMatch [

	self assert: (ARTIImplicitNoReturnCheck
			 classify: (ARTIBottomTerminal on: nil)
			 context: nil) isNil
]

{ #category : 'tests' }
ARTIImplicitNoReturnCheckTest >> testNegativeExplicitReturnTerminalDoesNotMatch [

	self assert: (ARTIImplicitNoReturnCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #literalInteger)
			 context: nil) isNil
]

{ #category : 'tests' }
ARTIImplicitNoReturnCheckTest >> testPositiveImplicitEndTerminal [

	self
		assert: (ARTIImplicitNoReturnCheck
				 classify: (ARTIImplicitEndTerminal forMethod: nil)
				 context: nil)
		equals: HTMSelf new
]
