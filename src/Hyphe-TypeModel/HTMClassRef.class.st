Class {
	#name : 'HTMClassRef',
	#superclass : 'HTMType',
	#instVars : [
		'className'
	],
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'instance creation' }
HTMClassRef class >> named: aName [

	^ self new
		  className: aName asSymbol;
		  yourself
]

{ #category : 'comparing' }
HTMClassRef >> = other [

	^ (other isKindOf: HTMClassRef) and: [ className = other className ]
]

{ #category : 'accessing' }
HTMClassRef >> className [

	^ className
]

{ #category : 'accessing' }
HTMClassRef >> className: aSymbol [

	className := aSymbol
]

{ #category : 'comparing' }
HTMClassRef >> hash [

	^ className hash
]

{ #category : 'printing' }
HTMClassRef >> printOn: aStream [

	aStream
		nextPutAll: 'ClassRef(';
		nextPutAll: className asString;
		nextPut: $)
]

{ #category : 'accessing' }
HTMClassRef >> setClassName: aSymbol [

	className := aSymbol
]
