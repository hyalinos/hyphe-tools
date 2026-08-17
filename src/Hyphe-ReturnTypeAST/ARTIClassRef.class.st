"
Type ::= ClassRef(className): a concrete class as a method's inferred return type,
e.g. ClassRef(Integer). Two instances are = iff their className is the same Symbol.
"
Class {
	#name : 'ARTIClassRef',
	#superclass : 'ARTIType',
	#instVars : [
		'className'
	],
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'instance creation' }
ARTIClassRef class >> named: aSymbolOrString [

	^ self new
		  setClassName: aSymbolOrString asSymbol;
		  yourself
]

{ #category : 'comparing' }
ARTIClassRef >> = other [

	^ (other isKindOf: ARTIClassRef) and: [ className = other className ]
]

{ #category : 'accessing' }
ARTIClassRef >> className [

	^ className
]

{ #category : 'comparing' }
ARTIClassRef >> hash [

	^ ARTIClassRef hash bitXor: className hash
]

{ #category : 'printing' }
ARTIClassRef >> printOn: aStream [

	aStream
		nextPutAll: 'ClassRef(';
		nextPutAll: className asString;
		nextPut: $)
]

{ #category : 'private' }
ARTIClassRef >> setClassName: aSymbol [

	className := aSymbol
]
