"
Small, self-documenting compiled methods used purely as AST fixtures by the test suites.
Nothing in here is meant to be executed; only the compiled ASTs are inspected.
"
Class {
	#name : 'ARTIFixtures',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Tests-Fixtures',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Fixtures'
}

{ #category : 'block literal fixtures' }
ARTIFixtures class >> blockLiteralExclusionNestedNonLocalReturn [

	^ [ :x | [ :y | ^ y ] value: x ]
]

{ #category : 'block literal fixtures' }
ARTIFixtures class >> blockLiteralExclusionNonLocalReturn [

	^ [ :x | ^ x ]
]

{ #category : 'block literal fixtures' }
ARTIFixtures class >> blockLiteralNegativeLiteral [

	^ 5
]

{ #category : 'block literal fixtures' }
ARTIFixtures class >> blockLiteralPositive [

	^ [ :x | x + 1 ]
]

{ #category : 'block literal fixtures' }
ARTIFixtures class >> blockLiteralPositiveNoArgs [

	^ [ 42 ]
]

{ #category : 'cascade shape fixtures' }
ARTIFixtures class >> cascadeNegativeArbitraryReceiver [

	| t |
	t := 5.
	^ t
		  printString;
		  yourself
]

{ #category : 'cascade shape fixtures' }
ARTIFixtures class >> cascadeNegativeNotYourself [

	^ 5
		  printString;
		  displayString
]

{ #category : 'cascade shape fixtures' }
ARTIFixtures class >> cascadeOnClassNew [

	^ ARTISafeFixtureClass new
		  printString;
		  yourself
]

{ #category : 'dynamic array check fixtures' }
ARTIFixtures class >> cascadeOnDynamicArray [

	^ { 1. 2 }
		  printString;
		  yourself
]

{ #category : 'cascade shape fixtures' }
ARTIFixtures class >> cascadeOnGlobalRead [

	^ Integer
		  printString;
		  yourself
]

{ #category : 'cascade shape fixtures' }
ARTIFixtures class >> cascadeOnLiteral [

	^ 5
		  printString;
		  yourself
]

{ #category : 'cascade shape fixtures' }
ARTIFixtures class >> cascadeOnSelf [

	^ self
		  printString;
		  yourself
]

{ #category : 'cascade shape fixtures' }
ARTIFixtures class >> cascadeOnSelfClass [

	^ self class
		  printString;
		  yourself
]

{ #category : 'class global read fixtures' }
ARTIFixtures class >> classGlobalReadNegativeLiteral [

	^ 5
]

{ #category : 'class global read fixtures' }
ARTIFixtures class >> classGlobalReadNegativeSelf [

	^ self
]

{ #category : 'class global read fixtures' }
ARTIFixtures class >> classGlobalReadPositive [

	^ Integer
]

{ #category : 'class global read fixtures' }
ARTIFixtures class >> classGlobalReadPositiveOrderedCollection [

	^ OrderedCollection
]

{ #category : 'class name new fixtures' }
ARTIFixtures class >> classNameNewExclusionSelfNew [

	^ self new
]

{ #category : 'class name new fixtures' }
ARTIFixtures class >> classNameNewExclusionSuperNew [

	^ super new
]

{ #category : 'class name new fixtures' }
ARTIFixtures class >> classNameNewNegativeUnsafe [

	^ ARTIUnsafeFixtureClass new
]

{ #category : 'class name new fixtures' }
ARTIFixtures class >> classNameNewNegativeUnsafeViaBasicNew [

	^ ARTIUnsafeFixtureBasicNewClass new
]

{ #category : 'class name new fixtures' }
ARTIFixtures class >> classNameNewPositiveObject [

	^ Object new
]

{ #category : 'class name new fixtures' }
ARTIFixtures class >> classNameNewPositiveSafeFixture [

	^ ARTISafeFixtureClass new
]

{ #category : 'test support' }
ARTIFixtures class >> contextForSelector: aSelector [

	^ ARTICheckContext
		  methodNode: (self class >> aSelector) ast
		  safetyTable: ARTINewSafetyTable new
]

{ #category : 'dynamic array check fixtures' }
ARTIFixtures class >> dynamicArrayNegativeLiteral [

	^ 5
]

{ #category : 'dynamic array check fixtures' }
ARTIFixtures class >> dynamicArrayNegativeLiteralArray [

	^ #( 1 2 3 )
]

{ #category : 'dynamic array check fixtures' }
ARTIFixtures class >> dynamicArrayPositive [

	^ { 1. 2 }
]

{ #category : 'dynamic array check fixtures' }
ARTIFixtures class >> dynamicArrayPositiveEmpty [

	^ {  }
]

{ #category : 'dynamic array check fixtures' }
ARTIFixtures class >> dynamicArrayPositiveWithExpressions [

	^ {
		  (1 + 1).
		  self class }
]

{ #category : 'test support' }
ARTIFixtures class >> explicitReturnTerminalFor: aSelector [

	| methodNode returnStatement |
	methodNode := (self class >> aSelector) ast.
	returnStatement := methodNode body statements detect: [ :s |
		                   s isReturn ].
	^ ARTIExplicitReturnTerminal on: returnStatement
]

{ #category : 'gate fixtures' }
ARTIFixtures class >> gateEmptyCommentOnly [
	"just a comment, no statements"

	
]

{ #category : 'gate fixtures' }
ARTIFixtures class >> gateEmptyPragmaOnly [

	<category: 'gate fixtures'>
	
]

{ #category : 'gate fixtures' }
ARTIFixtures class >> gateNonPrimitivePragmaHasStatements [

	<category: 'gate fixtures'>
	^ 5
]

{ #category : 'gate fixtures' }
ARTIFixtures class >> gateNormalMethodNotExcluded [

	^ 42
]

{ #category : 'gate fixtures' }
ARTIFixtures class >> gatePrimitiveExcluded [

	<primitive: 60>
	^ self primitiveFailed: #gatePrimitiveExcluded
]

{ #category : 'literal check fixtures' }
ARTIFixtures class >> literalArray [

	^ #( 1 2 3 )
]

{ #category : 'literal check fixtures' }
ARTIFixtures class >> literalInteger [

	^ 5
]

{ #category : 'literal check fixtures' }
ARTIFixtures class >> literalNegativeDynamicArray [

	^ { 1. 2 }
]

{ #category : 'literal check fixtures' }
ARTIFixtures class >> literalNegativeGlobalRead [

	^ Integer
]

{ #category : 'literal check fixtures' }
ARTIFixtures class >> literalString [

	^ 'hi'
]

{ #category : 'literal check fixtures' }
ARTIFixtures class >> literalSymbol [

	^ #foo
]

{ #category : 'literal check fixtures' }
ARTIFixtures class >> literalTrue [

	^ true
]

{ #category : 'unknown fixtures' }
ARTIFixtures class >> partialUnknownMixedBranches: aBool [

	aBool
		ifTrue: [ ^ 5 ]
		ifFalse: [ ^ self foo bar ]
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachBottomThenDeadReturn [

	self error: 'boom'.
	^ 6
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachDeadCodeAfterReturn [

	^ 1.
	self foo
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachDeadStatementAfterBottom [

	self halt.
	self foo.
	^ 7
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachIfFalseIfTrueBothReturn: x [

	x
		ifFalse: [ ^ 1 ]
		ifTrue: [ ^ 2 ]
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachIfTrueIfFalseBothReturn: x [

	x
		ifTrue: [ ^ 1 ]
		ifFalse: [ ^ 2 ]
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachIfTrueOnlyAsLastStatement: x [

	x ifTrue: [ ^ 1 ]
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachIfTrueOnlyFallsThrough: x [

	x ifTrue: [ ^ 1 ].
	^ 2
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachIfTrueWithNonLiteralBlock: x with: aBlock [

	x ifTrue: aBlock.
	^ 1
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachImplicitEndOnly [

	self foo
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachNestedConditional: x with: y [

	x ifTrue: [
			y
				ifTrue: [ ^ 1 ]
				ifFalse: [ ^ 2 ] ].
	^ 3
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachOtherConditionalOutOfScope: x [

	1 to: 5 do: [ :i | ^ i ].
	^ 99
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachSimpleReturn [

	^ 5
]

{ #category : 'reachability fixtures' }
ARTIFixtures class >> reachTwoArmedPartial: x [

	x
		ifTrue: [ ^ 1 ]
		ifFalse: [ self foo ].
	^ 2
]

{ #category : 'self class check fixtures' }
ARTIFixtures class >> selfClassNegativeBareSelf [

	^ self
]

{ #category : 'self class check fixtures' }
ARTIFixtures class >> selfClassNegativeOnGlobal [

	^ Integer class
]

{ #category : 'self class check fixtures' }
ARTIFixtures class >> selfClassPositive [

	^ self class
]

{ #category : 'self check fixtures' }
ARTIFixtures class >> selfNegativeClassMessage [

	^ self class
]

{ #category : 'self check fixtures' }
ARTIFixtures class >> selfNegativeLiteral [

	^ 5
]

{ #category : 'self check fixtures' }
ARTIFixtures class >> selfPositive [

	^ self
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempExclusionAssignedInBranch: cond [

	| x |
	cond ifTrue: [ x := 5 ].
	^ x
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempExclusionReassigned [

	| x |
	x := 5.
	x := 6.
	^ x
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempNegativeUnclassifiableRhs [

	| x |
	x := self foo bar.
	^ x
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempOrderCheck: cond [

	| x |
	cond ifTrue: [ ^ x ].
	x := 5.
	^ x
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempPositive [

	| x |
	x := 5.
	^ x
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempPositiveViaClassNameNew [

	| x |
	x := ARTISafeFixtureClass new.
	^ x
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempPositiveViaDynamicArray [

	| x |
	x := { 1. 2 }.
	^ x
]

{ #category : 'single-assignment temp check fixtures' }
ARTIFixtures class >> singleAssignTempPositiveViaGlobalRead [

	| x |
	x := Integer.
	^ x
]

{ #category : 'self class check fixtures' }
ARTIFixtures class >> superClassPositive [

	^ super class
]

{ #category : 'self check fixtures' }
ARTIFixtures class >> superPositive [

	^ super
]

{ #category : 'unknown fixtures' }
ARTIFixtures class >> totalUnknownAllBranchesUnclassifiable: aBool [

	aBool
		ifTrue: [ ^ self foo ]
		ifFalse: [ ^ self bar ]
]

{ #category : 'type var fixtures' }
ARTIFixtures class >> typeVarNegativeNotAParam [

	| t |
	t := 5.
	^ t
]

{ #category : 'type var fixtures' }
ARTIFixtures class >> typeVarPositive: x [

	^ x
]

{ #category : 'type var fixtures' }
ARTIFixtures class >> typeVarPositiveSecondArg: x with: y [

	^ y
]

{ #category : 'unknown fixtures' }
ARTIFixtures class >> unknownArbitrarySend [

	^ self foo bar
]
