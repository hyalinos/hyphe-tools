Class {
	#name : 'CTIVar',
	#superclass : 'Object',
	#instVars : [
		'minBits',
		'maxBits',
		'msgs',
		'subtypes',
		'supertypes',
		'name',
		'isSend',
		'linkClients',
		'blockInfo'
	],
	#category : 'Hyphe-ReturnTypeConstraint',
	#package : 'Hyphe-ReturnTypeConstraint'
}

{ #category : 'adding types' }
CTIVar >> addLinkClient: aLink [

	linkClients ifNil: [ linkClients := OrderedCollection new ].
	linkClients add: aLink
]

{ #category : 'adding types' }
CTIVar >> addMessage: aSelector [

	msgs ifNil: [ msgs := Set new ].
	msgs add: aSelector
]

{ #category : 'adding types' }
CTIVar >> addSubtype: other [

	subtypes ifNil: [ subtypes := Set new ].
	(subtypes includes: other) ifFalse: [
			subtypes add: other.
			other addSupertypeOnly: self ]
]

{ #category : 'adding types' }
CTIVar >> addSupertypeOnly: other [

	supertypes ifNil: [ supertypes := Set new ].
	supertypes add: other
]

{ #category : 'accessing' }
CTIVar >> blockInfo [

	^ blockInfo
]

{ #category : 'accessing' }
CTIVar >> blockInfo: aBlockInfo [

	blockInfo := aBlockInfo
]

{ #category : 'initialization' }
CTIVar >> initialize [

	super initialize.
	minBits := 0.
	maxBits := 0.
	isSend := false
]

{ #category : 'accessing' }
CTIVar >> isSend [

	^ isSend
]

{ #category : 'accessing' }
CTIVar >> isSend: aBool [

	isSend := aBool
]

{ #category : 'accessing' }
CTIVar >> linkClients [

	^ linkClients ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
CTIVar >> maxBits [

	^ maxBits
]

{ #category : 'accessing' }
CTIVar >> maxBits: aBits [

	maxBits := aBits
]

{ #category : 'accessing' }
CTIVar >> minBits [

	^ minBits
]

{ #category : 'accessing' }
CTIVar >> minBits: aBits [

	minBits := aBits
]

{ #category : 'accessing' }
CTIVar >> msgs [

	^ msgs ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
CTIVar >> name [

	^ name ifNil: [ 't' ]
]

{ #category : 'accessing' }
CTIVar >> name: aString [

	name := aString
]

{ #category : 'printing' }
CTIVar >> printOn: aStream [

	aStream nextPutAll: self name
]

{ #category : 'accessing' }
CTIVar >> subtypes [

	^ subtypes ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
CTIVar >> supertypes [

	^ supertypes ifNil: [ #(  ) ]
]
