"
The 'self class' ArgType/ReturnType production (Sec 2.2) -- the metaclass of whatever self resolves to. Singleton (use HYISelfClassRef value).
"
Class {
	#name : 'HYISelfClassRef',
	#superclass : 'HYIType',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYISelfClassRef class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'comparing' }
HYISelfClassRef >> = other [
	"All instances of a singleton class are interchangeable -- equality is purely by class."

	^ other class == self class
]

{ #category : 'comparing' }
HYISelfClassRef >> hash [
	"Consistent with =."

	^ self class hash
]

{ #category : 'testing' }
HYISelfClassRef >> isSelfClassRef [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYISelfClassRef >> printOn: aStream [
	"Prints as the spec's own name for this atomic production."

	aStream nextPutAll: 'Self class'
]
