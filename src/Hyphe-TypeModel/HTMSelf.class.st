Class {
	#name : 'HTMSelf',
	#superclass : 'HTMType',
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'comparing' }
HTMSelf >> = other [

	^ other isKindOf: HTMSelf
]

{ #category : 'comparing' }
HTMSelf >> hash [

	^ HTMSelf hash
]

{ #category : 'printing' }
HTMSelf >> printOn: aStream [

	aStream nextPutAll: 'Self'
]
