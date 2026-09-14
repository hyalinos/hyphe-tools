"
Conflict(tau,tau): two incompatible claims about one program element. Propagates through any merge (Sec 3.2.1, first row). Equality is symmetric.
"
Class {
	#name : 'HYIConflict',
	#superclass : 'HYITypeResult',
	#instVars : [
		'left',
		'right'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIConflict class >> left: aLeft right: aRight [
	"Constructor."

	^ self new
		  setLeft: aLeft right: aRight;
		  yourself
]

{ #category : 'comparing' }
HYIConflict >> = other [
	"Equality is symmetric (Sec 3.2.1) -- Conflict(a,b) = Conflict(b,a), since the operands' order carries no meaning."

	^ (other isKindOf: HYIConflict) and: [
		  (left = other left and: [ right = other right ]) or: [ left = other right and: [ right = other left ] ] ]
]

{ #category : 'comparing' }
HYIConflict >> hash [
	"Consistent with the symmetric =."

	^ left hash bitXor: right hash
]

{ #category : 'testing' }
HYIConflict >> isConflict [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'accessing' }
HYIConflict >> left [
	"Answers the left of the two incompatible claims."

	^ left
]

{ #category : 'printing' }
HYIConflict >> printOn: aStream [
	"Prints as Conflict(left, right)."

	aStream nextPutAll: 'Conflict('.
	left printOn: aStream.
	aStream nextPutAll: ', '.
	right printOn: aStream.
	aStream nextPutAll: ')'
]

{ #category : 'accessing' }
HYIConflict >> right [
	"Answers the right of the two incompatible claims."

	^ right
]

{ #category : 'private' }
HYIConflict >> setLeft: aLeft right: aRight [
	"Private initializer, called only from the class-side constructor."

	left := aLeft.
	right := aRight
]
