"
Tests for ARTIMethodGate: the <primitive: N> exclusion gate (REQ-G1) and the empty-body
exclusion gate (REQ-G2), against dedicated ARTIFixtures gate fixtures.
"
Class {
	#name : 'ARTIMethodGateTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIMethodGateTest >> testCommentOnlyMethodHasNoStatements [

	self assert: (ARTIMethodGate hasNoStatements:
			 (ARTIFixtures class >> #gateEmptyCommentOnly) ast)
]

{ #category : 'tests' }
ARTIMethodGateTest >> testNonPrimitivePragmaIsNotExcludedByPrimitiveGate [

	self deny: (ARTIMethodGate isExcludedByPrimitive:
			 ARTIFixtures class >> #gateNonPrimitivePragmaHasStatements)
]

{ #category : 'tests' }
ARTIMethodGateTest >> testNormalMethodHasStatements [

	self deny: (ARTIMethodGate hasNoStatements:
			 (ARTIFixtures class >> #gateNormalMethodNotExcluded) ast)
]

{ #category : 'tests' }
ARTIMethodGateTest >> testNormalMethodIsNotExcludedByPrimitiveGate [

	self deny: (ARTIMethodGate isExcludedByPrimitive:
			 ARTIFixtures class >> #gateNormalMethodNotExcluded)
]

{ #category : 'tests' }
ARTIMethodGateTest >> testPragmaOnlyMethodHasNoStatements [

	self assert: (ARTIMethodGate hasNoStatements:
			 (ARTIFixtures class >> #gateEmptyPragmaOnly) ast)
]

{ #category : 'tests' }
ARTIMethodGateTest >> testPrimitivePragmaIsExcluded [

	self assert: (ARTIMethodGate isExcludedByPrimitive:
			 ARTIFixtures class >> #gatePrimitiveExcluded)
]
