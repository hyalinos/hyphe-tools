"
MethodType ::= ArgType* -> ReturnType. This is what Sigma stores per (C,sel), wrapped in a Stability tag (an HYITypeVariant whose tau is an HYIMethodType).
"
Class {
	#name : 'HYIMethodType',
	#superclass : 'HYIType',
	#instVars : [
		'argTypes',
		'returnType'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIMethodType class >> argTypes: anArray returnType: aReturnType [
	"Full constructor, both argument types and the return type given explicitly."

	^ self new
		  setArgTypes: anArray returnType: aReturnType;
		  yourself
]

{ #category : 'instance creation' }
HYIMethodType class >> returnType: aReturnType [
	"Convenience constructor for a MethodType with no tracked argument types (the common case before Task 9's tool adapters started seeding real ArgTypes)."

	^ self argTypes: #(  ) returnType: aReturnType
]

{ #category : 'comparing' }
HYIMethodType >> = other [
	"Structural equality: same argument types (in order) and the same return type."

	^ (other isKindOf: HYIMethodType) and: [ argTypes = other argTypes and: [ returnType = other returnType ] ]
]

{ #category : 'accessing' }
HYIMethodType >> argTypes [
	"Answers the Array of ArgType tau, positional (one per formal parameter)."

	^ argTypes
]

{ #category : 'comparing' }
HYIMethodType >> hash [
	"Consistent with =."

	^ argTypes hash bitXor: returnType hash
]

{ #category : 'testing' }
HYIMethodType >> isMethodType [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYIMethodType >> printOn: aStream [
	"Prints as (arg1, arg2, ...) -> ReturnType."

	aStream nextPutAll: '('.
	argTypes do: [ :a | a printOn: aStream ] separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPutAll: ') -> '.
	returnType printOn: aStream
]

{ #category : 'accessing' }
HYIMethodType >> returnType [
	"Answers the ReturnType tau."

	^ returnType
]

{ #category : 'private' }
HYIMethodType >> setArgTypes: anArray returnType: aReturnType [
	"Private initializer, called only from the class-side constructors."

	argTypes := anArray.
	returnType := aReturnType
]
