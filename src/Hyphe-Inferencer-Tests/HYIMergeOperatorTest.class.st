"
Task 2: exhaustive tests of the ~ evidence-merge operator, Sec 3.2.1 (3-tag table) and Sec 3.2.2 (5-tag extension). Uses real kernel classes (SmallInteger <: Integer <: Number; String, Boolean unrelated to Integer) for subtype-related and unrelated pairs, per Task 1's provisional isSubtypeOf: (live class hierarchy, not yet the real expand()-based Sec 3.1 structural subtyping -- that is Task 5/6).
"
Class {
	#name : 'HYIMergeOperatorTest',
	#superclass : 'TestCase',
	#instVars : [
		'int',
		'si',
		'num',
		'str',
		'bool',
		'siAgain'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYIMergeOperatorTest >> setUp [
	"Shared taus for the whole suite -- si/siAgain are two independently-constructed but equal SmallInteger taus, used throughout to test structural (not identity) equality in the merge rules."

	super setUp.
	int := HYIStructNominal nominal: 'Integer'.
	si := HYIStructNominal nominal: 'SmallInteger'.
	num := HYIStructNominal nominal: 'Number'.
	str := HYIStructNominal nominal: 'String'.
	bool := HYIStructNominal nominal: 'Boolean'.
	siAgain := HYIStructNominal nominal: 'SmallInteger'
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testAnyTagWithBottomDissolvesToTheOtherOperand [
	"_(a)~Bottom=_(a) (Sec 3.2.2), on either side, for every Stability tag -- and Bottom~Bottom stays Bottom."

	self assert: (HYITypeVariant fixedNS: si) ~ HYIBottom value = (HYITypeVariant fixedNS: si).
	self assert: HYIBottom value ~ (HYITypeVariant fixedNS: si) = (HYITypeVariant fixedNS: si).
	self assert: (HYITypeVariant observed: si) ~ HYIBottom value = (HYITypeVariant observed: si).
	self assert: (HYITypeVariant guessed: si) ~ HYIBottom value = (HYITypeVariant guessed: si).
	self assert: HYIBottom value ~ HYIBottom value = HYIBottom value
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testAnyTagWithUnknownTopDissolves [
	"_(a)~Unknown(Top)=_(a) (Sec 3.2.1's last row), on either side, for every tag."

	self assert: (HYITypeVariant fixedNS: si) ~ HYITypeVariant unknown = (HYITypeVariant fixedNS: si).
	self assert: HYITypeVariant unknown ~ (HYITypeVariant fixedNS: si) = (HYITypeVariant fixedNS: si).
	self assert: (HYITypeVariant observed: si) ~ HYITypeVariant unknown = (HYITypeVariant observed: si).
	self assert: (HYITypeVariant guessed: si) ~ HYITypeVariant unknown = (HYITypeVariant guessed: si).
	self assert: HYITypeVariant unknown ~ HYITypeVariant unknown = HYITypeVariant unknown
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testBareTopDissolvesInMergeRevisedInTask7 [
	"Was testBareTopIsRejectedAsOperand: Task 2 originally rejected a bare Top operand of ~ since nothing needed it. Task 7's 'globals type as Top' pinned default creates a real path (a global read assigned straight to an ivar) where bare Top reaches ~, so it now dissolves like Bottom -- see the updated class comment on HYITypeResult class>>merge:with: for what this simplification does not preserve (Sec 3.4's Top-competes-vs-Unknown(Top)-dissolves distinction)."

	self assert: HYITop value ~ (HYITypeVariant fixedNS: si) = (HYITypeVariant fixedNS: si).
	self assert: (HYITypeVariant fixedNS: si) ~ HYITop value = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testConflictPropagatesThroughAnyMerge [
	"Conflict(_)~_ = Conflict(_) (Sec 3.2.1's first row) -- once a Conflict exists it propagates through any further merge, on either side, even against Bottom."

	| conflict |
	conflict := HYIConflict left: si right: str.
	self assert: conflict ~ (HYITypeVariant observed: si) == conflict.
	self assert: (HYITypeVariant observed: si) ~ conflict == conflict.
	self assert: conflict ~ HYIBottom value == conflict.
	self assert: HYIBottom value ~ conflict == conflict
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedGuessedAnyTypeIsIgnored [
	"Incorrect guessing is ignored, regardless of subtype relation -- unlike Observed."

	self assert: (HYITypeVariant fixedNS: si) ~ (HYITypeVariant guessed: str) = (HYITypeVariant fixedNS: si).
	self assert: (HYITypeVariant guessed: str) ~ (HYITypeVariant fixedNS: si) = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedGuessedSameTypeConfirms [
	"F(a)~G(a) = F(a) -- a matching guess confirms the fixed answer but adds nothing."

	self assert: (HYITypeVariant fixedNS: si) ~ (HYITypeVariant guessed: siAgain) = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedNSDeductionNarrowsToMoreSpecific [
	"F-NS(a)~F-NS(b), b<:a -> F-NS(b): a second DEDUCTION narrows"

	self assert: (HYITypeVariant fixedNS: int) ~ (HYITypeVariant fixedNS: si) = (HYITypeVariant fixedNS: si).
	self assert: (HYITypeVariant fixedNS: si) ~ (HYITypeVariant fixedNS: int) = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedNSDistinctUnrelatedIsConflict [
	"F-NS(a)~F-NS(b) for unrelated a,b is a Conflict (Sec 3.2.2) -- two deductions claiming two different exact classes cannot both be right."

	self assert: ((HYITypeVariant fixedNS: si) ~ (HYITypeVariant fixedNS: str)) isConflict
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedNSObservationDoesNotNarrowDeduction [
	"F-NS(a)~O(b), b<:a -> F-NS(a): asymmetric vs the deduction-narrows rule above"

	self assert: (HYITypeVariant fixedNS: int) ~ (HYITypeVariant observed: si) = (HYITypeVariant fixedNS: int)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedObservedNotSubtypeIsConflict [
	"F(a)~O(b), b not<:a, is a Conflict -- an observation incompatible with the deduced complete set is a real contradiction, not just ignored."

	self assert: ((HYITypeVariant fixedNS: si) ~ (HYITypeVariant observed: str)) isConflict.
	self assert: ((HYITypeVariant fixedNS: int) ~ (HYITypeVariant observed: str)) isConflict
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedObservedSameTypeConfirms [
	"F(a)~O(a) = F(a) -- a matching observation confirms the fixed answer."

	self assert: (HYITypeVariant fixedNS: si) ~ (HYITypeVariant observed: siAgain) = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedObservedSubtypeConfirmsOnePossibility [
	"F(a)~O(b), b<:a -> F(a): SmallInteger <: Integer, Fixed keeps its own (broader) payload"

	self assert: (HYITypeVariant fixedNS: int) ~ (HYITypeVariant observed: si) = (HYITypeVariant fixedNS: int).
	self assert: (HYITypeVariant observed: si) ~ (HYITypeVariant fixedNS: int) = (HYITypeVariant fixedNS: int)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedSDistinctTypesIsAlwaysConflict [
	"F-S(a)~F-S(b), a<>b, is always a Conflict (Sec 3.2.1) -- two distinct claims about the complete set of possible subclasses are impossible, in either order."

	self assert: ((HYITypeVariant fixedS: si) ~ (HYITypeVariant fixedS: int)) isConflict.
	self assert: ((HYITypeVariant fixedS: int) ~ (HYITypeVariant fixedS: si)) isConflict
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedSMeetsFixedNSAlwaysConflictEvenSameType [
	"F-S(a)~F-NS(a) is a Conflict even for the SAME class name (Sec 3.2.2) -- the two tags assert genuinely different completeness claims (X-or-any-subclass vs exactly-X), not just different values."

	self assert: ((HYITypeVariant fixedS: si) ~ (HYITypeVariant fixedNS: si)) isConflict.
	self assert: ((HYITypeVariant fixedNS: si) ~ (HYITypeVariant fixedS: si)) isConflict
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testFixedTrivialSameStabilitySameType [
	"F(a)~F(a) = F(a) -- the trivial identity row, for both Fixed variants."

	self assert: (HYITypeVariant fixedNS: si) ~ (HYITypeVariant fixedNS: siAgain) = (HYITypeVariant fixedNS: si).
	self assert: (HYITypeVariant fixedS: si) ~ (HYITypeVariant fixedS: siAgain) = (HYITypeVariant fixedS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testGuessedGuessedAccumulatesAsUnion [
	"G(a)~G(b) = G(a or b) -- two differing guesses accumulate as a union under the same tag, mirroring O(a)~O(b)."

	| result |
	result := (HYITypeVariant guessed: si) ~ (HYITypeVariant guessed: str).
	self assert: result isSingle.
	self assert: result entries first key isGuessed.
	self assert: result entries first value = (HYIUnion left: si right: str)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testGuessedTrivialSameType [
	"G(a)~G(a) = G(a) -- the trivial identity row."

	self assert: (HYITypeVariant guessed: si) ~ (HYITypeVariant guessed: siAgain) = (HYITypeVariant guessed: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testInvalidOperandIsRejected [
	"~'s guard rejects anything that isn't a valid TypeResult operand -- an arbitrary object, or a bare tau that isn't the two accepted Top/Bottom exceptions."

	self should: [ HYITypeResult merge: 42 with: (HYITypeVariant fixedNS: si) ] raise: Error.
	self should: [ HYITypeResult merge: si with: (HYITypeVariant fixedNS: si) ] raise: Error
	"a bare tau (StructNominal) is not itself a TypeResult"
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testMergeAssociativityOnAThreeWayFold [
	"Folding three pieces of evidence gives the same answer regardless of grouping or order -- important since HYIToolAdapter accumulates ARTI~ARTH~CTI one at a time, and the result must not depend on that arbitrary order."

	| f o g r1 r2 r3 |
	f := HYITypeVariant fixedNS: int.
	o := HYITypeVariant observed: si.
	g := HYITypeVariant guessed: str.
	r1 := f ~ o ~ g.
	r2 := f ~ (o ~ g).
	r3 := f ~ g ~ o.
	self assert: r1 = r2.
	self assert: r2 = r3.
	self assert: r1 = (HYITypeVariant fixedNS: int)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testMergeCandEmptyPruneIsConflict [
	"Merging against a Cand whose every hypothesis conflicts with the other operand prunes all of them -- zero survivors is itself a Conflict, not an empty Cand."

	| cand result |
	cand := HYICand with: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: str)).
	result := (HYITypeVariant fixedNS: bool) ~ cand.
	self assert: result isConflict
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testMergeCandFlattensNestedCand [
	"A Cand containing another Cand as one of its own hypotheses gets flattened during merge -- the nesting doesn't survive into the result."

	| r1 innerCand outer result |
	r1 := HYITypeVariant fixedNS: num.
	innerCand := HYICand with: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: int)).
	outer := HYICand with: (Array with: innerCand with: (HYITypeVariant fixedNS: bool)).
	result := r1 ~ outer.
	self assert: result isCand.
	self
		assert: result hypotheses asSet
		equals: (Set withAll: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: int)))
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testMergeCandWithCandIsPairwiseCrossProductPruned [
	"Merging two Cands merges every pairwise combination of their hypotheses, pruning the conflicting ones -- here only one of the four cross-product pairs survives, so the result collapses from a Cand down to a plain TypeVariant."

	| candA candB result |
	candA := HYICand with: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: str)).
	candB := HYICand with: (Array with: (HYITypeVariant observed: si) with: (HYITypeVariant observed: bool)).
	result := candA ~ candB.
	"si~si=F(si) survives, si~bool=Conflict pruned, str~si=Conflict pruned, str~bool=Conflict pruned -> single survivor"
	self assert: result = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testMergeDistributesOverCandAllSurvive [
	"Merging evidence against a Cand distributes over each hypothesis independently -- when none of them conflict, all survive and the Cand shape is preserved."

	| cand result |
	cand := HYICand with: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: num)).
	result := (HYITypeVariant observed: si) ~ cand.
	self assert: result isCand.
	self
		assert: result hypotheses asSet
		equals: (Set withAll: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: num)))
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testMergeDistributesOverCandPrunesConflictingMember [
	"Merging distributes over a Cand's hypotheses, pruning the ones that come out Conflict -- when exactly one survives, the result collapses from a Cand down to that single TypeVariant."

	| cand result |
	cand := HYICand with: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: str)).
	result := (HYITypeVariant observed: si) ~ cand.
	"SmallInteger branch confirms (single survivor collapses); String branch conflicts and is pruned"
	self assert: result = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testMergeIsCommutativeAcrossManyTagCombinations [
	"A property test: a ~ b = b ~ a across a spread of tag combinations, since ~ is meant to be symmetric evidence-merge, not an ordered operation."

	| pairs |
	pairs := OrderedCollection new.
	pairs add: (HYITypeVariant fixedNS: si) -> (HYITypeVariant observed: int).
	pairs add: (HYITypeVariant observed: si) -> (HYITypeVariant guessed: str).
	pairs add: (HYITypeVariant guessed: si) -> (HYITypeVariant guessed: str).
	pairs add: (HYITypeVariant observed: si) -> (HYITypeVariant observed: str).
	pairs add: (HYITypeVariant fixedNS: int) -> (HYITypeVariant fixedNS: si).
	pairs add: HYITypeVariant unknown -> (HYITypeVariant guessed: si).
	pairs do: [ :pair | self assert: pair key ~ pair value = (pair value ~ pair key) ]
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testObservedGuessedDistinctTypesNeedsMoreData [
	"O(a)~G(b) = O(a),G(b): irreducible double, need more data"

	| result |
	result := (HYITypeVariant observed: si) ~ (HYITypeVariant guessed: str).
	self assert: result isDouble.
	self assert: result printString equals: 'Observed(SmallInteger), Guessed(String)'.
	self assert: (HYITypeVariant guessed: str) ~ (HYITypeVariant observed: si) = result
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testObservedGuessedSameTypeConfirms [
	"O(a)~G(a) = O(a)"

	self assert: (HYITypeVariant observed: si) ~ (HYITypeVariant guessed: siAgain) = (HYITypeVariant observed: si)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testObservedObservedAccumulatesAsUnion [
	"O(a)~O(b) = O(a or b) (Sec 3.2.1, decided) -- accumulated observations are a real union, not a separate list structure."

	| result |
	result := (HYITypeVariant observed: si) ~ (HYITypeVariant observed: str).
	self assert: result isTypeVariant.
	self assert: result isSingle.
	self assert: result entries first key isObserved.
	self assert: result entries first value = (HYIUnion left: si right: str)
]

{ #category : 'tests' }
HYIMergeOperatorTest >> testObservedTrivialSameType [
	"O(a)~O(a) = O(a) -- the trivial identity row."

	self assert: (HYITypeVariant observed: si) ~ (HYITypeVariant observed: siAgain) = (HYITypeVariant observed: si)
]
