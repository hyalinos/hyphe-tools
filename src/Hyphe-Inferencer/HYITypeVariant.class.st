"
TypeVariant ::= Stability(tau) | Stability(tau), Stability(tau). entries is an Array of 1 or 2 Stability->tau Associations. Construction enforces the invariant that Bottom never carries a tag and Top only ever carries Unknown.
"
Class {
	#name : 'HYITypeVariant',
	#superclass : 'HYITypeResult',
	#instVars : [
		'entries'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYITypeVariant class >> fixedNS: aTau [
	"Constructor for a single Fixed-NS(tau) answer -- classes, instances or literals, deductively certain, no subclasses considered."

	^ self tau: aTau stability: HYIFixedNS value
]

{ #category : 'instance creation' }
HYITypeVariant class >> fixedS: aTau [
	"Constructor for a single Fixed-S(tau) answer -- self/super, deductively certain, subclasses of the true receiver considered."

	^ self tau: aTau stability: HYIFixedS value
]

{ #category : 'instance creation' }
HYITypeVariant class >> guessed: aTau [
	"Constructor for a single Guessed(tau) answer -- predicted by a heuristic or LLM, probabilistic and unverified."

	^ self tau: aTau stability: HYIGuessed value
]

{ #category : 'instance creation' }
HYITypeVariant class >> observed: aTau [
	"Constructor for a single Observed(tau) answer -- seen in real execution, but other types may exist on unexecuted paths."

	^ self tau: aTau stability: HYIObserved value
]

{ #category : 'instance creation' }
HYITypeVariant class >> tau: aTau stability: aStability [
	"Constructor for the single-entry shape, enforcing Task 1's invariant (validateTau:stability:) that Bottom never carries a tag and Top only ever carries Unknown."

	self validateTau: aTau stability: aStability.
	^ self new
		  setEntries: (Array with: aStability -> aTau);
		  yourself
]

{ #category : 'instance creation' }
HYITypeVariant class >> tau: tau1 stability: stability1 tau: tau2 stability: stability2 [
	"Constructor for the irreducible two-entry shape (Sec 2.2's TypeVariant ::= Stability(tau), Stability(tau)), validating both entries."

	self validateTau: tau1 stability: stability1.
	self validateTau: tau2 stability: stability2.
	^ self new
		  setEntries: (Array with: stability1 -> tau1 with: stability2 -> tau2);
		  yourself
]

{ #category : 'instance creation' }
HYITypeVariant class >> unknown [
	"Constructor for the canonical 'not computed yet' answer -- Unknown(Top), the sole pairing the spec's worked examples ever allow for this tag."

	^ self tau: HYITop value stability: HYIUnknown value
]

{ #category : 'instance creation' }
HYITypeVariant class >> validateTau: aTau stability: aStability [
	"Task 1's invariant, enforced at construction rather than trusted by convention: Bottom can never carry a Stability tag at all, and a bare Top can only ever be paired with Unknown (Unknown(Top)) -- never e.g. Fixed-NS(Top)."

	aTau isBottom ifTrue: [ ^ self error: 'Bottom cannot carry a Stability tag' ].
	(aTau isTop and: [ aStability isUnknown not ]) ifTrue: [
		^ self error: 'Top cannot carry a Stability tag other than Unknown ' , '(Unknown(Top) is the sole exception)' ]
]

{ #category : 'comparing' }
HYITypeVariant >> = other [
	"Equality is set-equality of the (Stability,tau) entries -- order between the (at most two) entries doesn't matter."

	^ (other isKindOf: HYITypeVariant) and: [ entries asSet = other entries asSet ]
]

{ #category : 'accessing' }
HYITypeVariant >> entries [
	"Answers the Array of 1 or 2 Stability->tau Associations this variant carries."

	^ entries
]

{ #category : 'comparing' }
HYITypeVariant >> hash [
	"Consistent with =."

	^ entries asSet hash
]

{ #category : 'testing' }
HYITypeVariant >> isDouble [
	"True for the irreducible two-answer shape (e.g. Observed(a), Guessed(b)) that mergeAtomic:with: leaves behind when two differently-tagged, differently-typed pieces of evidence can't be resolved to one."

	^ entries size = 2
]

{ #category : 'testing' }
HYITypeVariant >> isSingle [
	"True for the common, fully-resolved one-answer shape."

	^ entries size = 1
]

{ #category : 'testing' }
HYITypeVariant >> isTypeVariant [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYITypeVariant >> printOn: aStream [
	"Prints as Stability(tau), or Stability(tau), Stability(tau) for the two-entry shape."

	entries
		do: [ :assoc |
				assoc key printOn: aStream.
				aStream nextPutAll: '('.
				assoc value printOn: aStream.
				aStream nextPutAll: ')' ]
		separatedBy: [ aStream nextPutAll: ', ' ]
]

{ #category : 'private' }
HYITypeVariant >> setEntries: anArray [
	"Private initializer, called only from the class-side constructors."

	entries := anArray
]
