"
Tests for ARTIBottomCheck (check 6): matches only an ARTIBottomTerminal, never an
ImplicitEnd terminal or an ExplicitReturn of an error:-style send, plus an end-to-end fixture through
ARTIReachabilityEngine confirming a real standalone error: send produces a BottomTerminal in the first
place.
"
Class {
	#name : 'ARTIBottomCheckTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIBottomCheckTest >> testEndToEndStandaloneErrorSendProducesBottomTerminal [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachBottomThenDeadReturn) ast.
	self
		assert: (ARTIBottomCheck classify: terminals first context: nil)
		equals: HTMBottom new
]

{ #category : 'tests' }
ARTIBottomCheckTest >> testNegativeExplicitReturnOfErrorSendDoesNotMatch [
	"A return of an error: send, e.g. ^ self error: 'x', is a plain ExplicitReturn -- the
	reachability engine only ever produces a BottomTerminal for a *standalone* send."

	self assert: (ARTIBottomCheck
			 classify:
			 (ARTIFixtures explicitReturnTerminalFor: #literalInteger)
			 context: nil) isNil
]

{ #category : 'tests' }
ARTIBottomCheckTest >> testNegativeImplicitEndDoesNotMatch [

	self assert: (ARTIBottomCheck
			 classify: (ARTIImplicitEndTerminal forMethod: nil)
			 context: nil) isNil
]

{ #category : 'tests' }
ARTIBottomCheckTest >> testPositiveBottomTerminal [

	self
		assert:
		(ARTIBottomCheck classify: (ARTIBottomTerminal on: nil) context: nil)
		equals: HTMBottom new
]
