Class {
	#name : 'HTMTypeVar',
	#superclass : 'HTMType',
	#instVars : [
		'n'
	],
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'instance creation' }
HTMTypeVar class >> position: anInteger [

	^ self new
		  n: anInteger;
		  yourself
]

{ #category : 'comparing' }
HTMTypeVar >> = other [

	^ (other isKindOf: HTMTypeVar) and: [ n = other n ]
]

{ #category : 'accessing' }
HTMTypeVar >> argumentIndex [

	^ n
]

{ #category : 'comparing' }
HTMTypeVar >> hash [

	^ n hash
]

{ #category : 'accessing' }
HTMTypeVar >> n [

	^ n
]

{ #category : 'accessing' }
HTMTypeVar >> n: anInteger [

	n := anInteger
]

{ #category : 'printing' }
HTMTypeVar >> printOn: aStream [

	aStream
		nextPutAll: 'TypeVar(';
		print: n;
		nextPut: $)
]

{ #category : 'accessing' }
HTMTypeVar >> setArgumentIndex: anInteger [

	n := anInteger
]
