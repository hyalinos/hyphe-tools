Class {
	#name : 'HTMType',
	#superclass : 'Object',
	#category : 'Hyphe-TypeModel',
	#package : 'Hyphe-TypeModel'
}

{ #category : 'instance creation' }
HTMType class >> bottom [

	^ HTMBottom new
]

{ #category : 'instance creation' }
HTMType class >> classRef: aClassNameOrSymbol [

	^ HTMClassRef new
		  className: aClassNameOrSymbol asSymbol;
		  yourself
]

{ #category : 'instance creation' }
HTMType class >> metaclass: aClassNameOrSymbol [

	^ HTMMetaclass new
		  className: aClassNameOrSymbol asSymbol;
		  yourself
]

{ #category : 'instance creation' }
HTMType class >> self [

	^ HTMSelf new
]

{ #category : 'instance creation' }
HTMType class >> selfClass [

	^ HTMSelfClass new
]

{ #category : 'instance creation' }
HTMType class >> typeVar: anInteger [

	^ HTMTypeVar new
		  n: anInteger;
		  yourself
]

{ #category : 'instance creation' }
HTMType class >> union: aCollectionOfTypes [

	| flat |
	flat := OrderedCollection new.
	aCollectionOfTypes do: [ :t |
			t isUnion
				ifTrue: [ flat addAll: t types ]
				ifFalse: [ flat add: t ] ].
	flat := flat asSet asOrderedCollection.
	flat isEmpty ifTrue: [ ^ self unknown ].
	flat size = 1 ifTrue: [ ^ flat first ].
	^ HTMUnion new
		  types: (flat asSortedCollection: [ :a :b | a asString <= b asString ]) asOrderedCollection;
		  yourself
]

{ #category : 'instance creation' }
HTMType class >> unknown [

	^ HTMUnknown new
]

{ #category : 'printing' }
HTMType >> asString [

	^ String streamContents: [ :s | self printOn: s ]
]

{ #category : 'testing' }
HTMType >> isBottom [

	^ false
]

{ #category : 'testing' }
HTMType >> isUnion [

	^ false
]

{ #category : 'testing' }
HTMType >> isUnknown [

	^ false
]
