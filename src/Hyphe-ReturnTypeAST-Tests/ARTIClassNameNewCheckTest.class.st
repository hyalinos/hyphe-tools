"
Tests for ARTIClassNameNewCheck (check 7): safe-class positive fixtures, unsafe
(overridden new/basicNew) negative fixtures confirming no-match rather than a false ClassRef, and the
self-new/super-new exclusion fixtures.
"
Class {
	#name : 'ARTIClassNameNewCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIClassNameNewCheckTest >> testExclusionSelfNewNeverMatches [

	self assert: (ARTIClassNameNewCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #classNameNewExclusionSelfNew)
			 context:
			 (ARTIFixtures contextForSelector: #classNameNewExclusionSelfNew))
			isNil
]

{ #category : 'tests' }
ARTIClassNameNewCheckTest >> testExclusionSuperNewNeverMatches [

	self assert: (ARTIClassNameNewCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #classNameNewExclusionSuperNew)
			 context:
			 (ARTIFixtures contextForSelector: #classNameNewExclusionSuperNew))
			isNil
]

{ #category : 'tests' }
ARTIClassNameNewCheckTest >> testNegativeUnsafeOverriddenBasicNewReportsNoMatch [

	self assert: (ARTIClassNameNewCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #classNameNewNegativeUnsafeViaBasicNew)
			 context: (ARTIFixtures contextForSelector:
					  #classNameNewNegativeUnsafeViaBasicNew)) isNil
]

{ #category : 'tests' }
ARTIClassNameNewCheckTest >> testNegativeUnsafeOverriddenNewReportsNoMatchNotUnknown [

	self assert: (ARTIClassNameNewCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #classNameNewNegativeUnsafe)
			 context:
			 (ARTIFixtures contextForSelector: #classNameNewNegativeUnsafe))
			isNil
]

{ #category : 'tests' }
ARTIClassNameNewCheckTest >> testPositiveObjectNewIsSafe [

	self
		assert: (ARTIClassNameNewCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor:
					  #classNameNewPositiveObject)
				 context:
				 (ARTIFixtures contextForSelector: #classNameNewPositiveObject))
		equals: (ARTIClassRef named: #Object)
]

{ #category : 'tests' }
ARTIClassNameNewCheckTest >> testPositiveSafeFixtureClassNew [

	self
		assert: (ARTIClassNameNewCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor:
						  #classNameNewPositiveSafeFixture)
				 context:
				 (ARTIFixtures contextForSelector:
					  #classNameNewPositiveSafeFixture))
		equals: (ARTIClassRef named: #ARTISafeFixtureClass)
]
