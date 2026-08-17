"
Type ::= TypeVar(N): the same type as the method's Nth formal argument (1-based), unmodified
-- the method simply answers back one of its own parameters.
"
Class {
	#name : 'ARTITypeVarType',
	#superclass : 'ARTIType',
	#instVars : [
		'argumentIndex'
	],
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'instance creation' }
ARTITypeVarType class >> position: anInteger [

	^ self new
		  setArgumentIndex: anInteger;
		  yourself
]

{ #category : 'comparing' }
ARTITypeVarType >> = other [

	^ (other isKindOf: ARTITypeVarType) and: [
		  argumentIndex = other argumentIndex ]
]

{ #category : 'accessing' }
ARTITypeVarType >> argumentIndex [

	^ argumentIndex
]

{ #category : 'comparing' }
ARTITypeVarType >> hash [

	^ ARTITypeVarType hash bitXor: argumentIndex hash
]

{ #category : 'printing' }
ARTITypeVarType >> printOn: aStream [

	aStream
		nextPutAll: 'TypeVar(';
		print: argumentIndex;
		nextPut: $)
]

{ #category : 'private' }
ARTITypeVarType >> setArgumentIndex: anInteger [

	argumentIndex := anInteger
]
