Class {
	#name : 'HTMUnion',
	#superclass : 'HTMType',
	#instVars : [
		'types'
	],
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'instance creation' }
HTMUnion class >> withMembers: aCollection [

	^ HTMType union: aCollection
]

{ #category : 'comparing' }
HTMUnion >> = other [

	^ (other isKindOf: HTMUnion) and: [ types asSet = other types asSet ]
]

{ #category : 'comparing' }
HTMUnion >> hash [

	^ types asSet hash
]

{ #category : 'testing' }
HTMUnion >> isUnion [

	^ true
]

{ #category : 'accessing' }
HTMUnion >> members [

	^ types
]

{ #category : 'printing' }
HTMUnion >> printOn: aStream [

	aStream nextPutAll: 'Union('.
	types do: [ :t | t printOn: aStream ] separatedBy: [ aStream nextPutAll: ', ' ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
HTMUnion >> setMembers: aCollection [

	types := aCollection
]

{ #category : 'accessing' }
HTMUnion >> types [

	^ types
]

{ #category : 'accessing' }
HTMUnion >> types: aCollection [

	types := aCollection
]
