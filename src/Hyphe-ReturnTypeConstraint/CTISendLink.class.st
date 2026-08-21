Class {
	#name : 'CTISendLink',
	#superclass : 'Object',
	#instVars : [
		'receiverVar',
		'argVars',
		'sendVar',
		'selector',
		'linkedMask'
	],
	#category : 'Hyphe-ReturnTypeConstraint',
	#package : 'Hyphe-ReturnTypeConstraint'
}

{ #category : 'accessing' }
CTISendLink >> argVars [

	^ argVars
]

{ #category : 'accessing' }
CTISendLink >> argVars: coll [

	argVars := coll
]

{ #category : 'initialization' }
CTISendLink >> initialize [

	super initialize.
	linkedMask := 0
]

{ #category : 'accessing' }
CTISendLink >> linkedMask [

	^ linkedMask
]

{ #category : 'accessing' }
CTISendLink >> linkedMask: aBits [

	linkedMask := aBits
]

{ #category : 'accessing' }
CTISendLink >> receiverVar [

	^ receiverVar
]

{ #category : 'accessing' }
CTISendLink >> receiverVar: v [

	receiverVar := v
]

{ #category : 'accessing' }
CTISendLink >> selector [

	^ selector
]

{ #category : 'accessing' }
CTISendLink >> selector: s [

	selector := s
]

{ #category : 'accessing' }
CTISendLink >> sendVar [

	^ sendVar
]

{ #category : 'accessing' }
CTISendLink >> sendVar: v [

	sendVar := v
]
