"
Tests for ARTIReachabilityEngine (REQ-T1) against ARTIFixtures' reachability
fixtures, independent of any of the 10 classification checks: explicit returns, implicit ends, standalone
Bottom-selector sends, one- vs two-armed conditional termination, nested conditionals, dead code after a
terminating statement, and selectors out of this version's scope (REQ-R5).
"
Class {
	#name : 'ARTIReachabilityEngineTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testBottomSendMakesFollowingStatementUnreachable [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachBottomThenDeadReturn) ast.
	self assert: terminals size equals: 1.
	self assert: (terminals first isKindOf: ARTIBottomTerminal)
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testDeadStatementAfterBottomSendIsUnreachable [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachDeadStatementAfterBottom)
			             ast.
	self assert: terminals size equals: 1.
	self assert: (terminals first isKindOf: ARTIBottomTerminal)
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testEngineHasNoKnowledgeOfClassificationOutcomes [
	"REQ-A2/REQ-R4: the engine's vocabulary is limited to the three terminal kinds; it never
	answers, or needs to know, an HTMType."

	self deny: (ARTIReachabilityEngine respondsTo: #classify:context:)
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testIfFalseIfTrueTwoArmedAlsoRecognized [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachIfFalseIfTrueBothReturn:)
			             ast.
	self assert: terminals size equals: 2.
	self assert:
		(terminals allSatisfy: [ :t |
			 t isKindOf: ARTIExplicitReturnTerminal ])
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testIfTrueWithNonLiteralBlockArgumentIsTreatedAsOrdinaryStatement [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class
		              >> #reachIfTrueWithNonLiteralBlock:with:) ast.
	self assert: terminals size equals: 1.
	self assert: (terminals first isKindOf: ARTIExplicitReturnTerminal)
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testImplicitEndOnly [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachImplicitEndOnly) ast.
	self assert: terminals size equals: 1.
	self assert: (terminals first isKindOf: ARTIImplicitEndTerminal)
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testNestedConditionalInsideOneArmedBranch [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachNestedConditional:with:)
			             ast.
	"^1, ^2 nested inside the outer one-armed ifTrue:, plus ^3 following it; no ImplicitEnd"
	self assert: terminals size equals: 3.
	self assert:
		(terminals allSatisfy: [ :t |
			 t isKindOf: ARTIExplicitReturnTerminal ])
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testOneArmedIfTrueAsLastStatementAlsoYieldsImplicitEnd [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachIfTrueOnlyAsLastStatement:)
			             ast.
	self assert: terminals size equals: 2.
	self assert:
		(terminals anySatisfy: [ :t |
			 t isKindOf: ARTIExplicitReturnTerminal ]).
	self assert:
		(terminals anySatisfy: [ :t | t isKindOf: ARTIImplicitEndTerminal ])
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testOneArmedIfTrueNeverTerminatesEnclosingFlow [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachIfTrueOnlyFallsThrough:)
			             ast.
	"the branch's ^1 plus the following ^2 -- both reachable, no ImplicitEnd"
	self assert: terminals size equals: 2.
	self assert:
		(terminals allSatisfy: [ :t |
			 t isKindOf: ARTIExplicitReturnTerminal ])
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testSimpleExplicitReturn [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachSimpleReturn) ast.
	self assert: terminals size equals: 1.
	self assert: (terminals first isKindOf: ARTIExplicitReturnTerminal)
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testStatementAfterReturnIsUnreachable [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachDeadCodeAfterReturn) ast.
	self assert: terminals size equals: 1.
	self assert: (terminals first isKindOf: ARTIExplicitReturnTerminal)
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testTwoArmedConditionalBothBranchesReturnHasNoImplicitEnd [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachIfTrueIfFalseBothReturn:)
			             ast.
	self assert: terminals size equals: 2.
	self assert:
		(terminals allSatisfy: [ :t |
			 t isKindOf: ARTIExplicitReturnTerminal ])
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testTwoArmedConditionalWithOneNonTerminatingBranchDoesNotTerminateAsAWhole [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class >> #reachTwoArmedPartial:) ast.
	"only ^1 (inside the true branch) and ^2 (following the conditional) are genuine terminals;
	the false branch falling off its own end does NOT synthesize a spurious ImplicitEnd"
	self assert: terminals size equals: 2.
	self assert:
		(terminals allSatisfy: [ :t |
			 t isKindOf: ARTIExplicitReturnTerminal ])
]

{ #category : 'tests' }
ARTIReachabilityEngineTest >> testUnsupportedConditionalSelectorIsTreatedAsOrdinaryStatement [

	| terminals |
	terminals := ARTIReachabilityEngine reachableTerminalsOf:
		             (ARTIFixtures class
		              >> #reachOtherConditionalOutOfScope:) ast.
	"to:do: is out of scope (REQ-R5): the ^i inside its block is invisible to the engine;
	only the following ^99 is reported"
	self assert: terminals size equals: 1.
	self assert: (terminals first isKindOf: ARTIExplicitReturnTerminal).
	self assert: terminals first returnValueNode value equals: 99
]
