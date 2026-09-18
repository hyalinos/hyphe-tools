"
Abstract root of TypeResult (Sec 2.2): TypeVariant | Conflict(tau,tau) | Cand{TypeResult,...}. Resolution of the Bottom-carries-no-tag tension flagged in TASKS.md Task 1 (also Sec 3.3.9's open question): a bare HYITop/HYIBottom instance (an HYIType, not wrapped in any Stability) is ALSO a valid TypeResult in its own right -- see class>>isValidTypeResult:. This is resolution B named in Sec 3.3.9: Top/Bottom handled at the tau level, TypeResult-position code accepts them directly alongside HYITypeVariant/HYIConflict/HYICand.
"
Class {
	#name : 'HYITypeResult',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'merging' }
HYITypeResult class >> branchUnion: r1 with: r2 [
	"The (+) operator -- branch union, Sec 3.2/3.3.7/3.3.9. Combines the outcomes of DIFFERENT execution paths of one method; every branch is real, so this NEVER yields Conflict, however different the branch types are. Never confuse with ~ (Task 2), which merges independent evidence about the SAME fact. Bottom is preserved as a visible union member (a path that never returns is not dropped), unlike ~ where Bottom dissolves."

	| n1 n2 |
	(self isValidTypeResult: r1) ifFalse: [ ^ self error: r1 printString , ' is not a valid TypeResult operand of (+)' ].
	(self isValidTypeResult: r2) ifFalse: [ ^ self error: r2 printString , ' is not a valid TypeResult operand of (+)' ].
	n1 := self normalizeForBranchUnion: r1.
	n2 := self normalizeForBranchUnion: r2.
	(n1 isTop or: [ n2 isTop ]) ifTrue: [ ^ HYITop value ].
	(n1 isBottom and: [ n2 isBottom ]) ifTrue: [ ^ HYIBottom value ].
	n1 isBottom ifTrue: [ ^ self unionBottomInto: n2 ].
	n2 isBottom ifTrue: [ ^ self unionBottomInto: n1 ].
	^ self combineVariant: n1 with: n2
]

{ #category : 'private' }
HYITypeResult class >> collapseToSinglePair: aTypeVariant [
	"Reduces a (possibly double-tag, e.g. Observed(a),Guessed(b)) TypeVariant to one canonical Stability->tau pair for (+)'s internal use: min the stabilities, union the tau payloads. A double TypeVariant never legitimately contains Unknown (Task 2's closure argument), so no Unknown/Top validation conflict can arise here."

	| e1 e2 |
	aTypeVariant isSingle ifTrue: [ ^ aTypeVariant entries first ].
	e1 := aTypeVariant entries first.
	e2 := aTypeVariant entries last.
	^ (HYIStability min: e1 key with: e2 key) -> (self unionTau: e1 value with: e2 value)
]

{ #category : 'private' }
HYITypeResult class >> combineVariant: v1 with: v2 [
	"Both operands are real TypeVariants: the Stability tag is the WEAKER of the two (reusing the same min:with: primitive as the message-lookup tag rule, Sec 3.3.1 -- both express 'never claim more confidence than what this was built from'); the tau payload is their union. If the winning tag is Unknown, the union attempt is discarded (Unknown only ever pairs with bare Top, enforced by HYITypeVariant's constructors)."

	| p1 p2 stability |
	p1 := self collapseToSinglePair: v1.
	p2 := self collapseToSinglePair: v2.
	stability := HYIStability min: p1 key with: p2 key.
	stability isUnknown ifTrue: [ ^ HYITypeVariant unknown ].
	^ HYITypeVariant tau: (self unionTau: p1 value with: p2 value) stability: stability
]

{ #category : 'testing' }
HYITypeResult class >> isValidTypeResult: anObject [
	"Guard used by merge:with: -- a valid ~ operand is either a real TypeResult (TypeVariant/Conflict/Cand), or one of the two bare tau singletons (Top/Bottom) that Task 7's simplification lets reach ~ directly, ahead of being wrapped."

	^ (anObject isKindOf: HYITypeResult) or: [ (anObject isKindOf: HYIType) and: [ anObject isTop or: [ anObject isBottom ] ] ]
]

{ #category : 'merging' }
HYITypeResult class >> merge: r1 with: r2 [
	"The ~ operator -- evidence merge, Sec 3.2.1/3.2.2. Two independent sources' claims about the SAME fact; genuine disagreement is a real Conflict. Never confuse with (+) (Task 3), which unions branch outcomes.

	Revised during Task 7: bare Top is now accepted (dissolves, same outcome as Unknown(Top) via the last row of Sec 3.2.1) rather than rejected. Task 2 originally rejected it since nothing then needed it; Task 7's pinned default (globals in Theta type as Top) creates a real path -- a global read flowing straight into an ivar assignment -- where a bare Top legitimately reaches ~. Sec 3.4 draws a real distinction ('Top competes with it' vs Unknown(Top) dissolving) that this simplification does NOT preserve: implementing genuine competition would need new machinery (Top surviving as a recorded alternative, not unlike a Cand) that nothing in the twelve tasks calls for yet. Flagged as a deliberate, documented simplification, not a spec-mandated rule."

	(self isValidTypeResult: r1) ifFalse: [ ^ self error: r1 printString , ' is not a valid TypeResult operand of ~' ].
	(self isValidTypeResult: r2) ifFalse: [ ^ self error: r2 printString , ' is not a valid TypeResult operand of ~' ].
	r1 isConflict ifTrue: [ ^ r1 ].
	r2 isConflict ifTrue: [ ^ r2 ].
	r1 isBottom ifTrue: [ ^ r2 ].
	r2 isBottom ifTrue: [ ^ r1 ].
	r1 isTop ifTrue: [ ^ r2 ].
	r2 isTop ifTrue: [ ^ r1 ].
	(r1 isCand or: [ r2 isCand ]) ifTrue: [ ^ self mergeCand: r1 with: r2 ].
	^ self mergeVariant: r1 with: r2
]

{ #category : 'merging' }
HYITypeResult class >> mergeAtomic: assoc1 with: assoc2 [
	"One pairwise step of Sec 3.2.1/3.2.2's tables, on two bare (Stability -> tau) associations. Answers: an Association (reduced to one atom), an HYIConflict (short-circuits the whole merge), or nil (irreducible -- only the Observed/Guessed-distinct-types case)."

	| s1 t1 s2 t2 fAssoc oAssoc |
	s1 := assoc1 key.
	t1 := assoc1 value.
	s2 := assoc2 key.
	t2 := assoc2 value.
	(s1 isFixed and: [ s2 isFixed ]) ifTrue: [
			s1 isFixedS ~= s2 isFixedS ifTrue: [ ^ HYIConflict left: t1 right: t2 ].
			t1 = t2 ifTrue: [ ^ s1 -> t1 ].
			s1 isFixedS ifTrue: [ ^ HYIConflict left: t1 right: t2 ].
			(t2 isSubtypeOf: t1) ifTrue: [ ^ s2 -> t2 ].
			(t1 isSubtypeOf: t2) ifTrue: [ ^ s1 -> t1 ].
			^ HYIConflict left: t1 right: t2 ].
	(s1 isFixed or: [ s2 isFixed ]) ifTrue: [
			s1 isFixed
				ifTrue: [
						fAssoc := assoc1.
						oAssoc := assoc2 ]
				ifFalse: [
						fAssoc := assoc2.
						oAssoc := assoc1 ].
			oAssoc key isUnknown ifTrue: [ ^ fAssoc ].
			oAssoc key isGuessed ifTrue: [ ^ fAssoc ].
			(oAssoc value isSubtypeOf: fAssoc value) ifTrue: [ ^ fAssoc ].
			^ HYIConflict left: fAssoc value right: oAssoc value ].
	s1 isUnknown ifTrue: [ ^ assoc2 ].
	s2 isUnknown ifTrue: [ ^ assoc1 ].
	s1 class == s2 class ifTrue: [
			t1 = t2 ifTrue: [ ^ assoc1 ].
			^ s1 -> (HYIUnion left: t1 right: t2) ].
	t1 = t2 ifTrue: [
			^ s1 isObserved
				  ifTrue: [ assoc1 ]
				  ifFalse: [ assoc2 ] ].
	^ nil
]

{ #category : 'merging' }
HYITypeResult class >> mergeCand: r1 with: r2 [
	"Sec 3.2.2: R~Cand{...} = prune(Cand{R~R1,...}); Cand~Cand is the pairwise cross-product, pruned."

	| results |
	(r1 isCand and: [ r2 isCand ]) ifTrue: [
			results := OrderedCollection new.
			r1 hypotheses do: [ :h1 | r2 hypotheses do: [ :h2 | results add: (self merge: h1 with: h2) ] ].
			^ self pruneResults: results ].
	r1 isCand ifTrue: [ ^ self pruneResults: (r1 hypotheses collect: [ :h | self merge: h with: r2 ]) ].
	^ self pruneResults: (r2 hypotheses collect: [ :h | self merge: r1 with: h ])
]

{ #category : 'merging' }
HYITypeResult class >> mergeVariant: v1 with: v2 [
	"Fold the union of both operands' (Stability,tau) entries to a fixed point via mergeAtomic:with:. By construction (each input has <=2 entries, and the only ever-growing pair is Observed/Guessed) this always converges to 1 or 2 entries, or short-circuits to Conflict."

	| worklist changedAny i j result sorted |
	worklist := OrderedCollection new.
	worklist addAll: v1 entries.
	worklist addAll: v2 entries.
	changedAny := true.
	[ changedAny ] whileTrue: [
			changedAny := false.
			i := 1.
			[ i <= worklist size and: [ changedAny not ] ] whileTrue: [
					j := i + 1.
					[ j <= worklist size and: [ changedAny not ] ] whileTrue: [
							result := self mergeAtomic: (worklist at: i) with: (worklist at: j).
							result ifNotNil: [
									(result isKindOf: HYIConflict) ifTrue: [ ^ result ].
									worklist removeIndex: j.
									worklist removeIndex: i.
									worklist add: result.
									changedAny := true ].
							j := j + 1 ].
					i := i + 1 ] ].
	worklist size = 1 ifTrue: [ ^ HYITypeVariant tau: worklist first value stability: worklist first key ].
	worklist size = 2 ifTrue: [
			sorted := worklist asSortedCollection: [ :a :b | a key rank >= b key rank ].
			^ HYITypeVariant
				  tau: sorted first value
				  stability: sorted first key
				  tau: sorted last value
				  stability: sorted last key ].
	^ self error: 'merge did not converge to <= 2 entries -- atomic table gap'
]

{ #category : 'private' }
HYITypeResult class >> normalizeForBranchUnion: r [
	"Not spec-mandated -- flagged simplification: Conflict/Cand branch outcomes have no single settled (Stability,tau) claim to contribute, so for union purposes they widen to bare Top ('no reliable info from this path'), which is absorbing below. TypeVariant and bare Top/Bottom pass through unchanged."

	(r isConflict or: [ r isCand ]) ifTrue: [ ^ HYITop value ].
	^ r
]

{ #category : 'merging' }
HYITypeResult class >> pruneResults: aCollection [
	"prune(Cand{...}): drop Conflict members; one survivor collapses to it; no survivors is a Conflict (the empty-prune case, Sec 3.2.2); nested Cand is flattened. Logs to HYIDiagnostics (Task 11) whenever a member is actually dropped."

	| survivors flattened |
	survivors := aCollection reject: [ :r | r isConflict ].
	survivors size < aCollection size ifTrue: [
			HYIDiagnostics log: 'pruned ' , (aCollection size - survivors size) printString , ' of ' , aCollection size printString
				, ' Cand hypotheses as Conflict' ].
	survivors isEmpty ifTrue: [ ^ aCollection first ].
	flattened := OrderedCollection new.
	survivors do: [ :r |
			r isCand
				ifTrue: [ flattened addAll: r hypotheses ]
				ifFalse: [ flattened add: r ] ].
	flattened size = 1 ifTrue: [ ^ flattened first ].
	^ HYICand with: flattened
]

{ #category : 'private' }
HYITypeResult class >> unionBottomInto: aTypeVariant [
	"Bottom is a member of the outcome union, not dropped (Sec 3.3.9) -- unlike ~, where Bottom dissolves. Unions Bottom into the (collapsed) tau payload, keeping the surviving branch's own Stability tag: Bottom carries no competing claim of its own to weaken it."

	| pair |
	pair := self collapseToSinglePair: aTypeVariant.
	^ HYITypeVariant tau: (self unionTau: pair value with: HYIBottom value) stability: pair key
]

{ #category : 'private' }
HYITypeResult class >> unionTau: t1 with: t2 [
	"Binary tau-level union, Top-absorbing (X or Top = Top, per the top subtyping axiom, Sec 3.1) and deduplicating (t or t = t)."

	t1 = t2 ifTrue: [ ^ t1 ].
	t1 isTop ifTrue: [ ^ t1 ].
	t2 isTop ifTrue: [ ^ t2 ].
	^ HYIUnion left: t1 right: t2
]

{ #category : 'operations' }
HYITypeResult >> branchUnion: other [
	"The (+) operator (Task 3), invoked with the receiver as the left operand -- dispatches to the class-side implementation."

	^ HYITypeResult branchUnion: self with: other
]

{ #category : 'testing' }
HYITypeResult >> isBottom [
	"Shape-check predicate -- false by default here on the abstract root, overridden true on the one production it actually names."

	^ false
]

{ #category : 'testing' }
HYITypeResult >> isCand [
	"Shape-check predicate -- false by default here on the abstract root, overridden true on the one production it actually names."

	^ false
]

{ #category : 'testing' }
HYITypeResult >> isConflict [
	"Shape-check predicate -- false by default here on the abstract root, overridden true on the one production it actually names."

	^ false
]

{ #category : 'testing' }
HYITypeResult >> isTop [
	"Shape-check predicate -- false by default here on the abstract root, overridden true on the one production it actually names."

	^ false
]

{ #category : 'testing' }
HYITypeResult >> isTypeVariant [
	"Shape-check predicate -- false by default here on the abstract root, overridden true on the one production it actually names."

	^ false
]

{ #category : 'operations' }
HYITypeResult >> ~ other [
	"The ~ operator (Task 2), invoked with the receiver as one operand -- dispatches to the class-side implementation."

	^ HYITypeResult merge: self with: other
]
