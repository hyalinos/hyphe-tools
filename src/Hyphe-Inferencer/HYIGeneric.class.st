"
tau ::= tau<tau_i>: a generic type. Out of scope per AGENT_BRIEF's pinned default (collections type as their bare class), but kept constructible per Task 1's 'every production must be constructible' requirement.
"
Class {
	#name : 'HYIGeneric',
	#superclass : 'HYIType',
	#instVars : [
		'base',
		'params'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIGeneric class >> base: aBase params: aParamsArray [
	"Constructor. Kept constructible per Task 1's grammar even though nothing in the twelve tasks currently produces a HYIGeneric -- collections type as their bare class instead, per AGENT_BRIEF's pinned default."

	^ self new
		  setBase: aBase params: aParamsArray;
		  yourself
]

{ #category : 'comparing' }
HYIGeneric >> = other [
	"Structural equality: same base type and the same parameter list, in order."

	^ (other isKindOf: HYIGeneric) and: [ base = other base and: [ params = other params ] ]
]

{ #category : 'accessing' }
HYIGeneric >> base [
	"Answers the base (unparameterized) type, e.g. OrderedCollection in OrderedCollection<Integer>."

	^ base
]

{ #category : 'comparing' }
HYIGeneric >> hash [
	"Consistent with =."

	^ base hash bitXor: params hash
]

{ #category : 'testing' }
HYIGeneric >> isGeneric [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'accessing' }
HYIGeneric >> params [
	"Answers the Array of type parameters, e.g. { Integer } in OrderedCollection<Integer>."

	^ params
]

{ #category : 'printing' }
HYIGeneric >> printOn: aStream [
	"Prints as base<p1, p2, ...>."

	base printOn: aStream.
	aStream nextPutAll: '<'.
	params do: [ :p | p printOn: aStream ] separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPutAll: '>'
]

{ #category : 'private' }
HYIGeneric >> setBase: aBase params: aParamsArray [
	"Private initializer, called only from the class-side constructor."

	base := aBase.
	params := aParamsArray
]
