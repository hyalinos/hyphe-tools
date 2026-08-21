"
Tests for ARTITypeVarCheck (check 8): positive fixtures confirming the position is by
argument index (not name), a negative fixture for a non-parameter variable, and a dedicated reassignment-
exclusion test built via RBParser (see the test's comment for why real compilation can't produce that
fixture in this Pharo version).
"
Class {
	#name : 'ARTITypeVarCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTITypeVarCheckTest >> testExclusionWhenParameterIsReassignedAnywhereInBody [
	"This Pharo version enforces read-only method parameters at compile time, so a genuinely
	reassigned parameter cannot be produced via normal compilation. We exercise the reassignment-
	scanning rule directly with an AST built by RBParser (which skips semantic analysis and so
	doesn't enforce that restriction), distinct from the ordinary negative fixture above."

	| methodNode |
	methodNode := RBParser parseMethod: 'm: y | z | z := 1. y := z. ^ y'.
	self assert:
		(ARTITypeVarCheck isParameterNamed: #y reassignedIn: methodNode)
]

{ #category : 'tests' }
ARTITypeVarCheckTest >> testNegativeNonParameterVariableDoesNotMatch [

	self assert: (ARTITypeVarCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #typeVarNegativeNotAParam)
			 context:
			 (ARTIFixtures contextForSelector: #typeVarNegativeNotAParam))
			isNil
]

{ #category : 'tests' }
ARTITypeVarCheckTest >> testNoExclusionWhenParameterIsNeverReassigned [

	| methodNode |
	methodNode := RBParser parseMethod: 'm: y | z | z := 1. ^ y'.
	self deny:
		(ARTITypeVarCheck isParameterNamed: #y reassignedIn: methodNode)
]

{ #category : 'tests' }
ARTITypeVarCheckTest >> testPositionIsByArgumentPositionNotName [

	self
		assert: (ARTITypeVarCheck
				 classify: (ARTIFixtures explicitReturnTerminalFor:
						  #typeVarPositiveSecondArg:with:)
				 context:
				 (ARTIFixtures contextForSelector: #typeVarPositiveSecondArg:with:))
		equals: (HTMTypeVar position: 2)
]

{ #category : 'tests' }
ARTITypeVarCheckTest >> testPositiveFirstArgument [

	self
		assert: (ARTITypeVarCheck
				 classify:
				 (ARTIFixtures explicitReturnTerminalFor: #typeVarPositive:)
				 context: (ARTIFixtures contextForSelector: #typeVarPositive:))
		equals: (HTMTypeVar position: 1)
]
