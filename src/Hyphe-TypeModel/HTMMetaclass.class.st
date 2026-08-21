Class {
	#name : 'HTMMetaclass',
	#superclass : 'HTMType',
	#instVars : [
		'className'
	],
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'instance creation' }
HTMMetaclass class >> named: aName [

	^ self new
		  className: aName asSymbol;
		  yourself
]

{ #category : 'comparing' }
HTMMetaclass >> = other [

	^ (other isKindOf: HTMMetaclass) and: [ className = other className ]
]

{ #category : 'accessing' }
HTMMetaclass >> className [

	^ className
]

{ #category : 'accessing' }
HTMMetaclass >> className: aSymbol [

	className := aSymbol
]

{ #category : 'comparing' }
HTMMetaclass >> hash [

	^ className hash bitXor: 16r5EAF
]

{ #category : 'printing' }
HTMMetaclass >> printOn: aStream [

	aStream
		nextPutAll: 'Metaclass(';
		nextPutAll: className asString;
		nextPut: $)
]

{ #category : 'accessing' }
HTMMetaclass >> setClassName: aSymbol [

	className := aSymbol
]
