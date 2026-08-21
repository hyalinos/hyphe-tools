Class {
	#name : 'HTMSelfClass',
	#superclass : 'HTMType',
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'comparing' }
HTMSelfClass >> = other [

	^ other isKindOf: HTMSelfClass
]

{ #category : 'comparing' }
HTMSelfClass >> hash [

	^ HTMSelfClass hash
]

{ #category : 'printing' }
HTMSelfClass >> printOn: aStream [

	aStream nextPutAll: 'Self class'
]
