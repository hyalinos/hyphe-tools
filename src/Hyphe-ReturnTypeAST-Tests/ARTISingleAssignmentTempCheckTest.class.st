"
Tests for ARTISingleAssignmentTempCheck: positive fixtures for
each delegate check kind (literal, global read, ClassName new, dynamic array), exclusion fixtures (reassigned,
assignment not top-level/unconditional), a negative for an unclassifiable RHS, a regression guard confirming
argument reads stay check 8's territory, and an order-sensitivity test confirming a read before the defining
assignment does not match while a read after it does.
"
Class {
	#name : 'ARTISingleAssignmentTempCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testExclusionWhenAssignmentIsNotTopLevel [

	self assert: (ARTISingleAssignmentTempCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #singleAssignTempExclusionAssignedInBranch:)
			 context: (ARTIFixtures contextForSelector:
					  #singleAssignTempExclusionAssignedInBranch:)) isNil
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testExclusionWhenReassigned [

	self assert: (ARTISingleAssignmentTempCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #singleAssignTempExclusionReassigned)
			 context:
			 (ARTIFixtures contextForSelector:
				  #singleAssignTempExclusionReassigned)) isNil
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testNegativeArgumentVariableDoesNotMatch [
	"Regression guard: ArgumentVariable reads are check 8's territory, not this one -- the gate on
	TemporaryVariable already prevents overlap."

	self assert: (ARTISingleAssignmentTempCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #typeVarPositive:)
			 context: (ARTIFixtures contextForSelector: #typeVarPositive:))
			isNil
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testNegativeWhenRhsIsNotClassifiableByAnyDelegate [

	self assert: (ARTISingleAssignmentTempCheck
			 classify: (ARTIFixtures explicitReturnTerminalFor:
					  #singleAssignTempNegativeUnclassifiableRhs)
			 context: (ARTIFixtures contextForSelector:
					  #singleAssignTempNegativeUnclassifiableRhs)) isNil
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testNonExplicitReturnTerminalNeverMatches [

	self assert: (ARTISingleAssignmentTempCheck
			 classify: (ARTIImplicitEndTerminal forMethod: nil)
			 context: nil) isNil
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testOrderSensitivity [
	"A read reachable *before* the single top-level assignment must not match; the same variable's
	read reachable *after* it must."

	| context terminals |
	context := ARTIFixtures contextForSelector:
		           #singleAssignTempOrderCheck:.
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             context methodNode.
	self assert: terminals size equals: 2.
	self assert: (ARTISingleAssignmentTempCheck
			 classify: terminals first
			 context: context) isNil.
	self
		assert: (ARTISingleAssignmentTempCheck
				 classify: terminals second
				 context: context)
		equals: (HTMClassRef named: #Integer)
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testPositiveClassNameNewRhsDelegatesToCheck7 [

	self
		assert: (ARTISingleAssignmentTempCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor:
						  #singleAssignTempPositiveViaClassNameNew)
				 context: (ARTIFixtures contextForSelector:
						  #singleAssignTempPositiveViaClassNameNew))
		equals: (HTMClassRef named: #ARTISafeFixtureClass)
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testPositiveDynamicArrayRhsDelegatesToNewCheck [

	self
		assert: (ARTISingleAssignmentTempCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor:
						  #singleAssignTempPositiveViaDynamicArray)
				 context: (ARTIFixtures contextForSelector:
						  #singleAssignTempPositiveViaDynamicArray))
		equals: (HTMClassRef named: #Array)
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testPositiveGlobalReadRhsDelegatesToCheck2 [

	self
		assert: (ARTISingleAssignmentTempCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor:
						  #singleAssignTempPositiveViaGlobalRead)
				 context: (ARTIFixtures contextForSelector:
						  #singleAssignTempPositiveViaGlobalRead))
		equals: (HTMMetaclass named: #Integer)
]

{ #category : 'tests' }
ARTISingleAssignmentTempCheckTest >> testPositiveLiteralRhs [

	self
		assert: (ARTISingleAssignmentTempCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor:
					  #singleAssignTempPositive)
				 context:
				 (ARTIFixtures contextForSelector: #singleAssignTempPositive))
		equals: (HTMClassRef named: #Integer)
]
