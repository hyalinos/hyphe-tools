"
The never-returns tau. Singleton (use HYIBottom value). Atomic; never carries a Stability tag, not even Unknown.
"
Class {
	#name : 'HYIBottom',
	#superclass : 'HYIType',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIBottom class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'comparing' }
HYIBottom >> = other [
	"All instances of a singleton class are interchangeable -- equality is purely by class."

	^ other class == self class
]

{ #category : 'comparing' }
HYIBottom >> hash [
	"Consistent with =."

	^ self class hash
]

{ #category : 'testing' }
HYIBottom >> isBottom [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYIBottom >> printOn: aStream [
	"Prints as the spec's own name for this atomic production."

	aStream nextPutAll: 'Bottom'
]
