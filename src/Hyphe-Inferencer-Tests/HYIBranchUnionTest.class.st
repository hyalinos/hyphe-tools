"
Task 3: tests of the (+) branch-union operator, Sec 3.2/3.3.7/3.3.9. Property test over HYITestFixtures class>>sampleTypeResults asserts (+) never yields Conflict, for any pair -- the pool used by Task 2's exhaustive merge tests in spirit.
"
Class {
	#name : 'HYIBranchUnionTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYIBranchUnionTest >> testBottomBranchUnionBottomIsBottom [
	"Bottom (+) Bottom = Bottom -- if every branch is unreachable, the whole thing is too."

	self assert: (HYIBottom value branchUnion: HYIBottom value) = HYIBottom value
]

{ #category : 'tests' }
HYIBranchUnionTest >> testBottomIsPreservedAsAUnionMemberNotDropped [
	"Sec 3.3.9's own worked example: a Bottom-terminating branch is kept as a member of the outcome union, not silently dropped -- and (+) is commutative either way round."

	| si result |
	si := HYIStructNominal nominal: 'SmallInteger'.
	result := (HYITypeVariant fixedNS: si) branchUnion: HYIBottom value.
	self assert: result printString equals: 'Fixed-NS(SmallInteger or Bottom)'.
	self assert: (HYIBottom value branchUnion: (HYITypeVariant fixedNS: si)) = result description: 'must be commutative'
]

{ #category : 'tests' }
HYIBranchUnionTest >> testBottomUnionedIntoADoubleTagOperandAppliesToTheCollapsedResult [
	"Branch-unioning Bottom into an already-irreducible two-entry TypeVariant works against its collapsed (weaker-tag) form, not each entry separately."

	| double result |
	double := (HYITypeVariant observed: (HYIStructNominal nominal: 'SmallInteger'))
	          ~ (HYITypeVariant guessed: (HYIStructNominal nominal: 'String')).
	result := double branchUnion: HYIBottom value.
	self deny: result isConflict.
	self assert: result entries first key = HYIGuessed value
]

{ #category : 'tests' }
HYIBranchUnionTest >> testBranchUnionDedupsIdenticalBranchTypes [
	"Unioning a branch outcome with itself doesn't duplicate it into a trivial one-member union -- it stays exactly that one answer."

	| si |
	si := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger').
	self assert: (si branchUnion: si) = si
]

{ #category : 'tests' }
HYIBranchUnionTest >> testBranchUnionDoesNotConsultSubtypingUnlikeMerge [
	"Unlike ~, (+) never checks isSubtypeOf: -- both branches are equally real,
	so even a subtype-related pair still unions rather than narrowing/confirming."

	| int si result |
	int := HYIStructNominal nominal: 'Integer'.
	si := HYIStructNominal nominal: 'SmallInteger'.
	result := (HYITypeVariant fixedNS: int) branchUnion: (HYITypeVariant fixedNS: si).
	self assert: result printString equals: 'Fixed-NS(Integer or SmallInteger)'
]

{ #category : 'tests' }
HYIBranchUnionTest >> testBranchUnionIsCommutativeAcrossSamples [
	"A property test across a representative sample of TypeResult shapes: (+) never depends on operand order."

	| samples |
	samples := HYITestFixtures sampleTypeResults.
	samples do: [ :r1 |
		samples do: [ :r2 | self assert: (HYITypeResult branchUnion: r1 with: r2) = (HYITypeResult branchUnion: r2 with: r1) ] ]
]

{ #category : 'tests' }
HYIBranchUnionTest >> testConflictAndCandOperandsWidenToTop [
	"Branch-unioning a Conflict or a Cand (neither of which is a plain tagged tau) with anything degrades to bare Top -- (+) has no principled way to union a hypothesis-set or a contradiction into an ordinary branch outcome."

	| si num conflict cand |
	si := HYIStructNominal nominal: 'SmallInteger'.
	num := HYIStructNominal nominal: 'Number'.
	conflict := HYIConflict left: si right: (HYIStructNominal nominal: 'Boolean').
	cand := HYICand with:
		        (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Boolean'))).
	self assert: (conflict branchUnion: (HYITypeVariant fixedNS: num)) = HYITop value.
	self assert: (cand branchUnion: (HYITypeVariant fixedNS: num)) = HYITop value
]

{ #category : 'tests' }
HYIBranchUnionTest >> testDoubleTagOperandCollapsesBeforeUnioning [
	"An irreducible two-entry operand collapses to its weaker tag before being branch-unioned with anything else."

	| si str num double result |
	si := HYIStructNominal nominal: 'SmallInteger'.
	str := HYIStructNominal nominal: 'String'.
	num := HYIStructNominal nominal: 'Number'.
	double := (HYITypeVariant observed: si) ~ (HYITypeVariant guessed: str).
	"double = Observed(SmallInteger), Guessed(String) -- collapses to Guessed(SmallInteger or String), since Guessed is the WEAKER of the two internal tags."
	result := double branchUnion: (HYITypeVariant fixedNS: num).
	self deny: result isConflict.
	self
		assert: result entries first key = HYIGuessed value
		description: 'the weaker of the double''s two internal tags (Guessed) wins the collapse'
]

{ #category : 'tests' }
HYIBranchUnionTest >> testFixedNSTrueBranchUnionFixedNSFalseIsAUnionNotAConflict [
	"The exact case the spec calls out to distinguish (+) from ~: two Fixed-NS branches with different, real types union rather than conflict, because branches are real alternatives, not competing claims."

	| t f result |
	t := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'True').
	f := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'False').
	result := t branchUnion: f.
	self deny: result isConflict.
	self assert: result printString equals: 'Fixed-NS(True or False)'
]

{ #category : 'tests' }
HYIBranchUnionTest >> testMixedStabilityTagsUseTheWeakerOne [
	"Branch-unioning two DIFFERENTLY-tagged branches settles on the weaker of the two tags for the combined union -- the stronger branch's certainty doesn't survive once merged with a weaker one."

	| si bool result |
	si := HYIStructNominal nominal: 'SmallInteger'.
	bool := HYIStructNominal nominal: 'Boolean'.
	result := (HYITypeVariant fixedNS: si) branchUnion: (HYITypeVariant observed: bool).
	self assert: result entries first key = HYIObserved value.
	self assert: result entries first value = (HYIUnion left: si right: bool)
]

{ #category : 'tests' }
HYIBranchUnionTest >> testPropertyBranchUnionNeverYieldsConflict [
	"The central property from Task 3's own Done-when: (+) never returns a Conflict, checked exhaustively across every pair from the same sample generator Task 2's merge tests use."

	| samples |
	samples := HYITestFixtures sampleTypeResults.
	samples do: [ :r1 |
			samples do: [ :r2 |
					| result |
					result := HYITypeResult branchUnion: r1 with: r2.
					self
						deny: result isConflict
						description: 'branchUnion: ' , r1 printString , ' with: ' , r2 printString , ' yielded a Conflict' ] ]
]

{ #category : 'tests' }
HYIBranchUnionTest >> testTopAbsorbsEitherOperand [
	"A bare Top operand absorbs the union entirely -- 'no information' about one branch means no information about the whole union, on either side."

	| si |
	si := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger').
	self assert: (HYITop value branchUnion: si) = HYITop value.
	self assert: (si branchUnion: HYITop value) = HYITop value
]

{ #category : 'tests' }
HYIBranchUnionTest >> testUnknownWinsAsTheWeakestTagDiscardingTheOtherBranch [
	"Unknown is the weakest possible tag, so unioning it with anything else discards the other branch's information entirely, on either side."

	| si result |
	si := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger').
	result := HYITypeVariant unknown branchUnion: si.
	self assert: result = HYITypeVariant unknown.
	self assert: (si branchUnion: HYITypeVariant unknown) = HYITypeVariant unknown
]
