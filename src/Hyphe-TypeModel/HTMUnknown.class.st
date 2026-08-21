Class {
	#name : 'HTMUnknown',
	#superclass : 'HTMType',
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'comparing' }
HTMUnknown >> = other [

	^ other isKindOf: HTMUnknown
]

{ #category : 'comparing' }
HTMUnknown >> hash [

	^ HTMUnknown hash
]

{ #category : 'testing' }
HTMUnknown >> isUnknown [

	^ true
]

{ #category : 'printing' }
HTMUnknown >> printOn: aStream [

	aStream nextPutAll: 'Unknown'
]
