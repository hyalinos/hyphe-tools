"
Type ::= Metaclass(className): the metaclass of a concrete class, e.g. Metaclass(Integer)
for a method whose return value IS the class Integer itself (a bare read of that global).
"
Class {
	#name : 'ARTIMetaclass',
	#superclass : 'ARTIType',
	#instVars : [
		'className'
	],
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'instance creation' }
ARTIMetaclass class >> named: aSymbolOrString [

	^ self new
		  setClassName: aSymbolOrString asSymbol;
		  yourself
]

{ #category : 'comparing' }
ARTIMetaclass >> = other [

	^ (other isKindOf: ARTIMetaclass) and: [ className = other className ]
]

{ #category : 'accessing' }
ARTIMetaclass >> className [

	^ className
]

{ #category : 'comparing' }
ARTIMetaclass >> hash [

	^ ARTIMetaclass hash bitXor: className hash
]

{ #category : 'printing' }
ARTIMetaclass >> printOn: aStream [

	aStream
		nextPutAll: 'Metaclass(';
		nextPutAll: className asString;
		nextPut: $)
]

{ #category : 'private' }
ARTIMetaclass >> setClassName: aSymbol [

	className := aSymbol
]
