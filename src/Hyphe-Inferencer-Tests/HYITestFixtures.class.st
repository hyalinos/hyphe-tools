"
Shared TypeResult sample generator for exhaustive/property tests (Task 2's merge tests and Task 3's branch-union property test draw from the same pool, per TASKS.md Task 3's Done-when).
"
Class {
	#name : 'HYITestFixtures',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixtures' }
HYITestFixtures class >> sampleTypeResults [
	"A representative sample covering every TypeResult shape: bare Top/Bottom, all 5 Stability tags (incl. a subtype-related pair and an unrelated pair), a double-tag TypeVariant, a Conflict, and a Cand."

	| int si str bool |
	int := HYIStructNominal nominal: 'Integer'.
	si := HYIStructNominal nominal: 'SmallInteger'.
	str := HYIStructNominal nominal: 'String'.
	bool := HYIStructNominal nominal: 'Boolean'.
	^ OrderedCollection new
		  add: HYITop value;
		  add: HYIBottom value;
		  add: (HYITypeVariant fixedS: si);
		  add: (HYITypeVariant fixedNS: int);
		  add: (HYITypeVariant fixedNS: si);
		  add: (HYITypeVariant fixedNS: str);
		  add: (HYITypeVariant observed: si);
		  add: (HYITypeVariant observed: bool);
		  add: (HYITypeVariant guessed: si);
		  add: (HYITypeVariant guessed: str);
		  add: HYITypeVariant unknown;
		  add: (HYITypeVariant observed: si) ~ (HYITypeVariant guessed: str);
		  add: (HYIConflict left: si right: str);
		  add: (HYICand with: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: bool)));
		  yourself
]
