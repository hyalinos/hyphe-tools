"
Cand{TypeResult,...}: a set of hypotheses about one unknown truth, exactly one true. Requires at least one hypothesis; pruning to zero survivors is Conflict, not an empty Cand -- see Task 2's merge implementation.
"
Class {
	#name : 'HYICand',
	#superclass : 'HYITypeResult',
	#instVars : [
		'hypotheses'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYICand class >> with: aCollection [
	"Constructor -- requires at least one hypothesis; pruning to zero survivors during a merge is Conflict, not an empty Cand."

	| coll |
	coll := aCollection asOrderedCollection.
	coll isEmpty ifTrue: [ ^ self error: 'HYICand requires at least one hypothesis' ].
	^ self new
		  setHypotheses: coll;
		  yourself
]

{ #category : 'comparing' }
HYICand >> = other [
	"Equality is set-equality of the hypotheses -- order among them carries no meaning."

	^ (other isKindOf: HYICand) and: [ hypotheses asSet = other hypotheses asSet ]
]

{ #category : 'comparing' }
HYICand >> hash [
	"Consistent with =."

	^ hypotheses asSet hash
]

{ #category : 'accessing' }
HYICand >> hypotheses [
	"Answers the collection of candidate TypeResults, exactly one of which is the truth."

	^ hypotheses
]

{ #category : 'testing' }
HYICand >> isCand [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYICand >> printOn: aStream [
	"Prints as Cand{h1, h2, ...}."

	aStream nextPutAll: 'Cand{'.
	hypotheses do: [ :h | h printOn: aStream ] separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPutAll: '}'
]

{ #category : 'private' }
HYICand >> setHypotheses: aCollection [
	"Private initializer, called only from the class-side constructor."

	hypotheses := aCollection
]
