"
Type ::= Union(Type, Type, ...): two or more of the other type kinds, contributed by different
reachable branches of the same method. Members are de-duplicated by =; construct instances only via
the class-side #withMembers:, which also collapses a single surviving distinct member to that member
itself rather than wrapping it (a Union never has exactly one member).
"
Class {
	#name : 'ARTIUnionType',
	#superclass : 'ARTIType',
	#instVars : [
		'members'
	],
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'instance creation' }
ARTIUnionType class >> withMembers: aCollection [
	"De-duplicates aCollection (by =) preserving first-seen order. A single distinct member
	collapses to that member itself rather than being wrapped in a union (REQ-U2)."

	| deduped |
	deduped := OrderedCollection new.
	aCollection do: [ :each |
		(deduped includes: each) ifFalse: [ deduped add: each ] ].
	deduped size = 1 ifTrue: [ ^ deduped first ].
	^ self new
		  setMembers: deduped;
		  yourself
]

{ #category : 'comparing' }
ARTIUnionType >> = other [

	^ (other isKindOf: ARTIUnionType) and: [
		  members asSet = other members asSet ]
]

{ #category : 'comparing' }
ARTIUnionType >> hash [

	^ ARTIUnionType hash bitXor: members asSet hash
]

{ #category : 'testing' }
ARTIUnionType >> isUnion [

	^ true
]

{ #category : 'accessing' }
ARTIUnionType >> members [

	^ members
]

{ #category : 'printing' }
ARTIUnionType >> printOn: aStream [

	aStream nextPutAll: 'Union('.
	members
		do: [ :each | aStream print: each ]
		separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPut: $)
]

{ #category : 'private' }
ARTIUnionType >> setMembers: aCollection [

	members := aCollection asOrderedCollection
]
