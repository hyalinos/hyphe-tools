"
ARTIType is the abstract root of the AST-based return-type inference result grammar:
ClassRef(className) | Metaclass(className) | Self | Self class | Bottom | TypeVar(N) | Unknown | Union(...).
Subclasses implement '=' / hash / printOn: so results can be compared and de-duplicated.
"
Class {
	#name : 'ARTIType',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'comparing' }
ARTIType >> = other [

	^ self class = other class
]

{ #category : 'comparing' }
ARTIType >> hash [

	^ self class hash
]

{ #category : 'testing' }
ARTIType >> isUnion [

	^ false
]
