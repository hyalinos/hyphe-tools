Class {
	#name : 'HTMBottom',
	#superclass : 'HTMType',
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'comparing' }
HTMBottom >> = other [

	^ other isKindOf: HTMBottom
]

{ #category : 'comparing' }
HTMBottom >> hash [

	^ HTMBottom hash
]

{ #category : 'testing' }
HTMBottom >> isBottom [

	^ true
]

{ #category : 'printing' }
HTMBottom >> printOn: aStream [

	aStream nextPutAll: 'Bottom'
]
