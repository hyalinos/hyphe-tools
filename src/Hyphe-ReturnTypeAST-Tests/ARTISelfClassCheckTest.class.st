"
Tests for ARTISelfClassCheck (check 4): positive self class/super class fixtures and
negative fixtures (bare self, a class message sent to a global) confirming it doesn't overreach into
check 3's territory.
"
Class {
	#name : 'ARTISelfClassCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTISelfClassCheckTest >> testNegativeBareSelfDoesNotMatch [

	self assert: (ARTISelfClassCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #selfClassNegativeBareSelf)
			 context:
			 (ARTIFixtures contextForSelector: #selfClassNegativeBareSelf))
			isNil
]

{ #category : 'tests' }
ARTISelfClassCheckTest >> testNegativeClassMessageOnGlobalDoesNotMatch [

	self assert: (ARTISelfClassCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #selfClassNegativeOnGlobal)
			 context:
			 (ARTIFixtures contextForSelector: #selfClassNegativeOnGlobal))
			isNil
]

{ #category : 'tests' }
ARTISelfClassCheckTest >> testPositiveSelfClass [

	self
		assert: (ARTISelfClassCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #selfClassPositive)
				 context: (ARTIFixtures contextForSelector: #selfClassPositive))
		equals: ARTISelfClassType new
]

{ #category : 'tests' }
ARTISelfClassCheckTest >> testPositiveSuperClass [

	self
		assert: (ARTISelfClassCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #superClassPositive)
				 context: (ARTIFixtures contextForSelector: #superClassPositive))
		equals: ARTISelfClassType new
]
