"
Marks an unresolved 'Self' -- the var-self/var-super typing rule (Sec 3.3.4) produces Fixed-S(Self) before substSelf (Sec 3.3.1) replaces every occurrence with a concrete class. Singleton (use HYISelfRef value).
"
Class {
	#name : 'HYISelfRef',
	#superclass : 'HYIType',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYISelfRef class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'comparing' }
HYISelfRef >> = other [
	"All instances of a singleton class are interchangeable -- equality is purely by class."

	^ other class == self class
]

{ #category : 'comparing' }
HYISelfRef >> hash [
	"Consistent with =."

	^ self class hash
]

{ #category : 'testing' }
HYISelfRef >> isSelfRef [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYISelfRef >> printOn: aStream [
	"Prints as the spec's own name for this atomic production."

	aStream nextPutAll: 'Self'
]
