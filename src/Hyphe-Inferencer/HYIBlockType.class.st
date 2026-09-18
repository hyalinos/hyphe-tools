"
BlockType ::= [ ArgType* -> ReturnType ]. Structurally identical to HYIMethodType but a distinct production per the grammar (a block is not a method).
"
Class {
	#name : 'HYIBlockType',
	#superclass : 'HYIType',
	#instVars : [
		'argTypes',
		'returnType'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIBlockType class >> argTypes: anArray returnType: aReturnType [
	"Constructor."

	^ self new
		  setArgTypes: anArray returnType: aReturnType;
		  yourself
]

{ #category : 'comparing' }
HYIBlockType >> = other [
	"Structural equality: same argument types (in order) and the same return type."

	^ (other isKindOf: HYIBlockType) and: [ argTypes = other argTypes and: [ returnType = other returnType ] ]
]

{ #category : 'accessing' }
HYIBlockType >> argTypes [
	"Answers the Array of the block's parameter types, positional."

	^ argTypes
]

{ #category : 'comparing' }
HYIBlockType >> hash [
	"Consistent with =."

	^ argTypes hash bitXor: returnType hash
]

{ #category : 'testing' }
HYIBlockType >> isBlockType [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYIBlockType >> printOn: aStream [
	"Prints as [arg1, arg2, ... -> ReturnType], the square brackets marking it as a block (not a method) production."

	aStream nextPutAll: '['.
	argTypes do: [ :a | a printOn: aStream ] separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPutAll: ' -> '.
	returnType printOn: aStream.
	aStream nextPutAll: ']'
]

{ #category : 'accessing' }
HYIBlockType >> returnType [
	"Answers the ReturnType tau of what the block evaluates to."

	^ returnType
]

{ #category : 'private' }
HYIBlockType >> setArgTypes: anArray returnType: aReturnType [
	"Private initializer, called only from the class-side constructor."

	argTypes := anArray.
	returnType := aReturnType
]
