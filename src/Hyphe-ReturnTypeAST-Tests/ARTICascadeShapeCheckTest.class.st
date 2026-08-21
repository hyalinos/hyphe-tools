"
Tests for ARTICascadeShapeCheck (check 9): one positive fixture delegating to each
of checks 1/2/3/4/7 in turn, plus negative fixtures for an arbitrary receiver and a cascade whose last
message isn't #yourself.
"
Class {
	#name : 'ARTICascadeShapeCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testDelegatesToClassGlobalReadCheck [

	self
		assert: (ARTICascadeShapeCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #cascadeOnGlobalRead)
				 context: (ARTIFixtures contextForSelector: #cascadeOnGlobalRead))
		equals: (HTMMetaclass named: #Integer)
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testDelegatesToClassNameNewCheck [

	self
		assert: (ARTICascadeShapeCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #cascadeOnClassNew)
				 context: (ARTIFixtures contextForSelector: #cascadeOnClassNew))
		equals: (HTMClassRef named: #ARTISafeFixtureClass)
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testDelegatesToDynamicArrayCheck [

	self
		assert: (ARTICascadeShapeCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #cascadeOnDynamicArray)
				 context:
				 (ARTIFixtures contextForSelector: #cascadeOnDynamicArray))
		equals: (HTMClassRef named: #Array)
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testDelegatesToLiteralCheck [

	self
		assert: (ARTICascadeShapeCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #cascadeOnLiteral)
				 context: (ARTIFixtures contextForSelector: #cascadeOnLiteral))
		equals: (HTMClassRef named: #Integer)
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testDelegatesToSelfCheck [

	self
		assert: (ARTICascadeShapeCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #cascadeOnSelf)
				 context: (ARTIFixtures contextForSelector: #cascadeOnSelf))
		equals: HTMSelf new
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testDelegatesToSelfClassCheck [

	self
		assert: (ARTICascadeShapeCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #cascadeOnSelfClass)
				 context: (ARTIFixtures contextForSelector: #cascadeOnSelfClass))
		equals: HTMSelfClass new
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testNegativeArbitraryReceiverDoesNotMatch [

	self assert: (ARTICascadeShapeCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #cascadeNegativeArbitraryReceiver)
			 context:
			 (ARTIFixtures contextForSelector:
				  #cascadeNegativeArbitraryReceiver)) isNil
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testNegativeLastMessageNotYourselfDoesNotMatch [

	self assert: (ARTICascadeShapeCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #cascadeNegativeNotYourself)
			 context:
			 (ARTIFixtures contextForSelector: #cascadeNegativeNotYourself))
			isNil
]

{ #category : 'tests' }
ARTICascadeShapeCheckTest >> testNonCascadeExpressionDoesNotMatch [

	self assert: (ARTICascadeShapeCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #literalInteger)
			 context: (ARTIFixtures contextForSelector: #literalInteger)) isNil
]
