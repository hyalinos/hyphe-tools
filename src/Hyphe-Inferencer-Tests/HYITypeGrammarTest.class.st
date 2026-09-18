"
Task 1 tests: every production of Sec 2.2's tau/TypeResult grammar is constructible, Top/Bottom cannot be given a Stability tag by construction (except the sole Unknown(Top) sentinel), and printing/equality round-trip.
"
Class {
	#name : 'HYITypeGrammarTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYITypeGrammarTest >> testBareTopAndBottomAreValidTypeResultsWithoutWrapping [
	"Task 7's accepted simplification: a bare Top/Bottom tau is itself a valid ~ operand, ahead of being wrapped -- but an arbitrary object, or a bare tau that isn't Top/Bottom, is not."

	self assert: (HYITypeResult isValidTypeResult: HYITop value).
	self assert: (HYITypeResult isValidTypeResult: HYIBottom value).
	self assert: (HYITypeResult isValidTypeResult: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'A'))).
	self deny: (HYITypeResult isValidTypeResult: 42).
	self deny: (HYITypeResult isValidTypeResult: (HYIStructNominal nominal: 'A'))
]

{ #category : 'tests' }
HYITypeGrammarTest >> testBottomIsSingletonAndAtomic [
	"HYIBottom is a true singleton (identity, not just equality) and atomic -- never both Bottom and Top."

	self assert: HYIBottom value == HYIBottom value.
	self assert: HYIBottom value isBottom.
	self deny: HYIBottom value isTop.
	self assert: HYIBottom value printString equals: 'Bottom'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testBottomNeverCarriesAnyTagIncludingUnknown [
	"Task 1's invariant: Bottom cannot be given a Stability tag by construction, not even Unknown -- validateTau:stability: must reject it."

	self should: [ HYITypeVariant fixedNS: HYIBottom value ] raise: Error.
	self should: [ HYITypeVariant tau: HYIBottom value stability: HYIUnknown value ] raise: Error
]

{ #category : 'tests' }
HYITypeGrammarTest >> testCandConstructibleRequiresAtLeastOneHypothesisAndPrints [
	"Cand{...} is constructible with real hypotheses and prints them; an empty hypothesis set is rejected outright rather than silently allowed."

	| r1 r2 cand |
	r1 := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'A').
	r2 := HYITypeVariant observed: (HYIStructNominal nominal: 'B').
	cand := HYICand with: (Array with: r1 with: r2).
	self assert: cand isCand.
	self assert: cand printString equals: 'Cand{Fixed-NS(A), Observed(B)}'.
	self should: [ HYICand with: #(  ) ] raise: Error
]

{ #category : 'tests' }
HYITypeGrammarTest >> testConflictConstructibleAndSymmetric [
	"Conflict(a,b) = Conflict(b,a) -- operand order carries no meaning."

	| a b conflict1 conflict2 |
	a := HYIStructNominal nominal: 'A'.
	b := HYIStructNominal nominal: 'B'.
	conflict1 := HYIConflict left: a right: b.
	conflict2 := HYIConflict left: b right: a.
	self assert: conflict1 isConflict.
	self assert: conflict1 printString equals: 'Conflict(A, B)'.
	self assert: conflict1 = conflict2
]

{ #category : 'tests' }
HYITypeGrammarTest >> testDifferentValuesAreNotEqual [
	"Equality is sensitive to both the tau and the Stability tag -- neither alone is enough to make two TypeVariants equal."

	self deny: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'A')) = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'B')).
	self deny: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'A')) = (HYITypeVariant observed: (HYIStructNominal nominal: 'A'))
]

{ #category : 'tests' }
HYITypeGrammarTest >> testEqualityIsStructuralNotIdentity [
	"Two independently-constructed but structurally identical TypeVariants are = (and hash-consistent), even though they're not the same object."

	| v1 v2 |
	v1 := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger').
	v2 := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger').
	self deny: v1 == v2.
	self assert: v1 = v2.
	self assert: v1 hash equals: v2 hash.
	self assert: v1 printString equals: v2 printString
]

{ #category : 'tests' }
HYITypeGrammarTest >> testGenericConstructibleAndPrints [
	"tau<tau_i> is constructible per Task 1's grammar, even though nothing in the twelve tasks currently produces one."

	| g |
	g := HYIGeneric
		     base: (HYIStructNominal nominal: 'OrderedCollection')
		     params: (Array with: (HYIStructNominal nominal: 'SmallInteger')).
	self assert: g isGeneric.
	self assert: g printString equals: 'OrderedCollection<SmallInteger>'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testMethodTypeAndBlockTypeAreDistinctProductions [
	"MethodType and BlockType are structurally identical (ArgType* -> ReturnType) but genuinely distinct productions -- a method's shape is never confused with a block's."

	| mt bt |
	mt := HYIMethodType
		      argTypes: (Array with: (HYIStructNominal nominal: 'SmallInteger'))
		      returnType: (HYIStructNominal nominal: 'Boolean').
	bt := HYIBlockType
		      argTypes: (Array with: (HYIStructNominal nominal: 'SmallInteger'))
		      returnType: (HYIStructNominal nominal: 'Boolean').
	self assert: mt isMethodType.
	self assert: bt isBlockType.
	self deny: mt class == bt class.
	self assert: mt printString equals: '(SmallInteger) -> Boolean'.
	self assert: bt printString equals: '[SmallInteger -> Boolean]'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testSelfRefAndSelfClassRefAreSingletonsAndDistinct [
	"Self and Self class are each true singletons, and never equal to each other."

	self assert: HYISelfRef value == HYISelfRef value.
	self assert: HYISelfClassRef value == HYISelfClassRef value.
	self deny: HYISelfRef value = HYISelfClassRef value.
	self assert: HYISelfRef value printString equals: 'Self'.
	self assert: HYISelfClassRef value printString equals: 'Self class'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testStabilityRankOrderingAndFixedTie [
	"The min-tag rule's ordering: Fixed > Observed > Guessed > Unknown, with Fixed-S and Fixed-NS tied at the top rank."

	self assert: (HYIStability min: HYIFixedNS value with: HYIObserved value) = HYIObserved value.
	self assert: (HYIStability min: HYIObserved value with: HYIGuessed value) = HYIGuessed value.
	self assert: (HYIStability min: HYIGuessed value with: HYIUnknown value) = HYIUnknown value.
	"Pinned default: Fixed-S and Fixed-NS are equal rank for the min-tag rule."
	self assert: (HYIStability min: HYIFixedS value with: HYIFixedNS value) rank equals: 3
]

{ #category : 'tests' }
HYITypeGrammarTest >> testStructNominalConstructibleAndPrints [
	"A purely nominal StructNominal (no structural selectors) prints as just its class name."

	| s |
	s := HYIStructNominal nominal: 'SmallInteger'.
	self assert: s isStructNominal.
	self assert: s nominal equals: 'SmallInteger'.
	self assert: s selectors isEmpty.
	self assert: s printString equals: 'SmallInteger'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testStructNominalWithSelectorsPrints [
	"A StructNominal carrying real structural selectors prints them alongside its nominal name."

	| mt s |
	mt := HYIMethodType returnType: (HYIStructNominal nominal: 'SmallInteger').
	s := HYIStructNominal
		     selectors: (Dictionary new
				      at: #size put: mt;
				      yourself)
		     nominal: 'Foo'.
	self assert: s printString equals: 'Foo[size: () -> SmallInteger]'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testTopIsSingletonAndAtomic [
	"HYITop is a true singleton and atomic -- never both Top and Bottom."

	self assert: HYITop value == HYITop value.
	self assert: HYITop value isTop.
	self deny: HYITop value isBottom.
	self assert: HYITop value printString equals: 'Top'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testTypeVarConstructibleAndPrints [
	"TypeVar prints as a1, a2, ... and equality is purely by positional index."

	self assert: (HYITypeVar index: 2) printString equals: 'a2'.
	self assert: (HYITypeVar index: 1) = (HYITypeVar index: 1)
]

{ #category : 'tests' }
HYITypeGrammarTest >> testTypeVariantSingleAndDoubleConstructibleAndPrint [
	"Both the common single-entry shape and the irreducible two-entry shape are constructible and print correctly."

	| single double |
	single := HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger').
	self assert: single isSingle.
	self assert: single printString equals: 'Fixed-NS(SmallInteger)'.
	double := HYITypeVariant
		          tau: (HYIStructNominal nominal: 'A')
		          stability: HYIObserved value
		          tau: (HYIStructNominal nominal: 'B')
		          stability: HYIGuessed value.
	self assert: double isDouble.
	self assert: double printString equals: 'Observed(A), Guessed(B)'
]

{ #category : 'tests' }
HYITypeGrammarTest >> testUnionConstructibleFlattensAndPrints [
	"fromMembers: builds a (binary-by-construction) union from any number of members, and #members correctly flattens it back to the full flat set."

	| a b c u |
	a := HYIStructNominal nominal: 'A'.
	b := HYIStructNominal nominal: 'B'.
	c := HYIStructNominal nominal: 'C'.
	u := HYIUnion fromMembers: (Array with: a with: b with: c).
	self assert: u isUnion.
	self assert: u members asSet equals: (Set withAll: (Array with: a with: b with: c))
]

{ #category : 'tests' }
HYITypeGrammarTest >> testUnknownTopIsTheOnlyLegalTopTag [
	"Task 1's invariant: a bare Top tau can only ever be paired with Unknown -- Fixed-NS(Top), Observed(Top) and Guessed(Top) are all rejected at construction."

	self assert: HYITypeVariant unknown printString equals: 'Unknown(Top)'.
	self should: [ HYITypeVariant fixedNS: HYITop value ] raise: Error.
	self should: [ HYITypeVariant tau: HYITop value stability: HYIObserved value ] raise: Error.
	self should: [ HYITypeVariant guessed: HYITop value ] raise: Error
]
