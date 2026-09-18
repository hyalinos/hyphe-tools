"
Abstract root of the 5-tag Stability axis (Sec 3.2): Fixed-S, Fixed-NS, Observed, Guessed, Unknown. Ordering for the min-tag rule (Sec 3.3.1): Fixed > Observed > Guessed > Unknown, with Fixed-S and Fixed-NS at equal rank per AGENT_BRIEF's pinned default (their MERGE via ~ is still Conflict when they meet -- see Task 2 -- rank-equality is only about the min-tag-strength rule, a separate question).
"
Class {
	#name : 'HYIStability',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'comparing' }
HYIStability class >> min: aStability with: bStability [
	"Fixed-S and Fixed-NS are pinned as equal rank (AGENT_BRIEF.md), which leaves 
	the tie-break undecided. Must be a FIXED, order-independent choice -- 
	otherwise min:with: (reused by both this task's (+) tag rule and the 
	message-lookup min-tag rule) would not be commutative, which (+) needs to be."

	| ra rb |
	ra := aStability rank.
	rb := bStability rank.
	ra < rb ifTrue: [ ^ aStability ].
	ra > rb ifTrue: [ ^ bStability ].
	aStability = bStability ifTrue: [ ^ aStability ].
	^ HYIFixedNS value
]

{ #category : 'accessing' }
HYIStability class >> rank [
	"Subclass responsibility -- see each concrete tag's own override for its numeric rank."

	^ self subclassResponsibility
]

{ #category : 'comparing' }
HYIStability >> = other [
	"All instances of a given Stability subclass are interchangeable -- equality is purely by class."

	^ other class == self class
]

{ #category : 'comparing' }
HYIStability >> hash [
	"Consistent with =."

	^ self class hash
]

{ #category : 'testing' }
HYIStability >> isFixed [
	"Tag-check predicate -- false by default here on the abstract root, overridden true on the one or two subclasses it actually names (isFixed covers both Fixed-S and Fixed-NS)."

	^ false
]

{ #category : 'testing' }
HYIStability >> isFixedNS [
	"Tag-check predicate -- false by default here on the abstract root, overridden true on the one or two subclasses it actually names (isFixed covers both Fixed-S and Fixed-NS)."

	^ false
]

{ #category : 'testing' }
HYIStability >> isFixedS [
	"Tag-check predicate -- false by default here on the abstract root, overridden true on the one or two subclasses it actually names (isFixed covers both Fixed-S and Fixed-NS)."

	^ false
]

{ #category : 'testing' }
HYIStability >> isGuessed [
	"Tag-check predicate -- false by default here on the abstract root, overridden true on the one or two subclasses it actually names (isFixed covers both Fixed-S and Fixed-NS)."

	^ false
]

{ #category : 'testing' }
HYIStability >> isObserved [
	"Tag-check predicate -- false by default here on the abstract root, overridden true on the one or two subclasses it actually names (isFixed covers both Fixed-S and Fixed-NS)."

	^ false
]

{ #category : 'testing' }
HYIStability >> isUnknown [
	"Tag-check predicate -- false by default here on the abstract root, overridden true on the one or two subclasses it actually names (isFixed covers both Fixed-S and Fixed-NS)."

	^ false
]

{ #category : 'accessing' }
HYIStability >> rank [
	"The min-tag rule's ordering (Sec 3.3.1): Fixed > Observed > Guessed > Unknown -- delegates to the class-side rank so it's defined once per tag, not per instance."

	^ self class rank
]
