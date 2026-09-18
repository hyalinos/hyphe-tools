"
tau ::= tau or tau: a union of FACT, not a set of hypotheses (that is HYICand at the TypeResult level -- see Sec 2.2 'Decided'). Binary by construction; #members flattens nested unions into a flat collection.
"
Class {
	#name : 'HYIUnion',
	#superclass : 'HYIType',
	#instVars : [
		'left',
		'right'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIUnion class >> fromMembers: aCollection [
	"Builds a (possibly nested, always binary) union from an arbitrary-sized collection of members -- a single member is returned unwrapped, not wrapped in a trivial one-member union."

	| coll |
	coll := aCollection asOrderedCollection.
	coll isEmpty ifTrue: [ ^ self error: 'HYIUnion fromMembers: requires at least one member' ].
	coll size = 1 ifTrue: [ ^ coll first ].
	^ coll allButFirst inject: coll first into: [ :acc :each | self left: acc right: each ]
]

{ #category : 'instance creation' }
HYIUnion class >> left: aLeft right: aRight [
	"Constructor for one binary union node."

	^ self new
		  setLeft: aLeft right: aRight;
		  yourself
]

{ #category : 'comparing' }
HYIUnion >> = other [
	"Equality is set-equality of the flattened members -- (A or B) = (B or A), and nested unions with the same overall member set are equal regardless of association shape."

	^ (other isKindOf: HYIUnion) and: [ self members asSet = other members asSet ]
]

{ #category : 'comparing' }
HYIUnion >> hash [
	"Consistent with = -- derived from the flattened member set, not the binary left/right shape."

	^ self members asSet hash
]

{ #category : 'typing' }
HYIUnion >> isSubtypeOf: other [
	"or-elim (Sec 3.1): self, a union, is a subtype of other iff EVERY member is."

	(super isSubtypeOf: other) ifTrue: [ ^ true ].
	^ self members allSatisfy: [ :m | m isSubtypeOf: other ]
]

{ #category : 'testing' }
HYIUnion >> isUnion [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'accessing' }
HYIUnion >> left [
	"Answers the left branch tau, as originally constructed (before flattening)."

	^ left
]

{ #category : 'accessing' }
HYIUnion >> members [
	"Flattens the (binary-by-construction) union tree into a flat OrderedCollection of its non-union leaf members."

	| result |
	result := OrderedCollection new.
	left isUnion
		ifTrue: [ result addAll: left members ]
		ifFalse: [ result add: left ].
	right isUnion
		ifTrue: [ result addAll: right members ]
		ifFalse: [ result add: right ].
	^ result
]

{ #category : 'printing' }
HYIUnion >> printOn: aStream [
	"Prints as 'left or right', matching the spec's own tau or tau notation."

	left printOn: aStream.
	aStream nextPutAll: ' or '.
	right printOn: aStream
]

{ #category : 'accessing' }
HYIUnion >> right [
	"Answers the right branch tau, as originally constructed (before flattening)."

	^ right
]

{ #category : 'private' }
HYIUnion >> setLeft: aLeft right: aRight [
	"Private initializer, called only from the class-side constructors."

	left := aLeft.
	right := aRight
]
