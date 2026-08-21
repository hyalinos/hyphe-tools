"
Tests for ARTIClassGlobalReadCheck (check 2): positive global-read fixtures and
negative fixtures (self, a plain literal).
"
Class {
	#name : 'ARTIClassGlobalReadCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIClassGlobalReadCheckTest >> testNegativeLiteralDoesNotMatch [

	self assert: (ARTIClassGlobalReadCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #classGlobalReadNegativeLiteral)
			 context:
			 (ARTIFixtures contextForSelector: #classGlobalReadNegativeLiteral))
			isNil
]

{ #category : 'tests' }
ARTIClassGlobalReadCheckTest >> testNegativeSelfDoesNotMatch [

	self assert: (ARTIClassGlobalReadCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor:
				  #classGlobalReadNegativeSelf)
			 context:
			 (ARTIFixtures contextForSelector: #classGlobalReadNegativeSelf))
			isNil
]

{ #category : 'tests' }
ARTIClassGlobalReadCheckTest >> testPositiveIntegerGlobal [

	self
		assert: (ARTIClassGlobalReadCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #classGlobalReadPositive)
				 context:
				 (ARTIFixtures contextForSelector: #classGlobalReadPositive))
		equals: (HTMMetaclass named: #Integer)
]

{ #category : 'tests' }
ARTIClassGlobalReadCheckTest >> testPositiveOrderedCollectionGlobal [

	self
		assert: (ARTIClassGlobalReadCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor:
						  #classGlobalReadPositiveOrderedCollection)
				 context: (ARTIFixtures contextForSelector:
						  #classGlobalReadPositiveOrderedCollection))
		equals: (HTMMetaclass named: #OrderedCollection)
]
