"
TypeVar ::= a1 | a2 | ...: the i-th positional method argument, used in ArgType/ReturnType position. Per AGENT_BRIEF's pinned default, the apply/substitution mechanism is not implemented: a signature containing a HYITypeVar yields Top when actually used by reconstruction (later tasks), but the value itself must be constructible now.
"
Class {
	#name : 'HYITypeVar',
	#superclass : 'HYIType',
	#instVars : [
		'index'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYITypeVar class >> index: anInteger [
	"Constructor for the TypeVar naming the anInteger-th formal parameter."

	^ self new
		  setIndex: anInteger;
		  yourself
]

{ #category : 'comparing' }
HYITypeVar >> = other [
	"Equality is purely positional: two TypeVars are the same iff they name the same argument index."

	^ (other isKindOf: HYITypeVar) and: [ index = other index ]
]

{ #category : 'comparing' }
HYITypeVar >> hash [
	"Consistent with =."

	^ index hash
]

{ #category : 'accessing' }
HYITypeVar >> index [
	"Answers the 1-based positional index of the formal parameter this TypeVar names."

	^ index
]

{ #category : 'testing' }
HYITypeVar >> isTypeVar [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYITypeVar >> printOn: aStream [
	"Prints as a1, a2, ... matching the spec's own TypeVar ::= a1 | a2 | ... notation."

	aStream nextPutAll: 'a' , index printString
]

{ #category : 'private' }
HYITypeVar >> setIndex: anInteger [
	"Private initializer, called only from the class-side constructor."

	index := anInteger
]
