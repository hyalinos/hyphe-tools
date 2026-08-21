Class {
	#name : 'CTIUniverse',
	#superclass : 'Object',
	#instVars : [
		'classIndex',
		'indexToClass',
		'size'
	],
	#category : 'Hyphe-ReturnTypeConstraint',
	#package : 'Hyphe-ReturnTypeConstraint'
}

{ #category : 'accessing' }
CTIUniverse >> allMask [

	^ (1 bitShift: size) - 1
]

{ #category : 'building' }
CTIUniverse >> buildFromImage [

	| i |
	i := 0.
	Smalltalk allClasses do: [ :c |
			classIndex at: c put: i.
			indexToClass add: c.
			i := i + 1 ].
	size := i
]

{ #category : 'accessing' }
CTIUniverse >> classAt: anIndex [

	^ indexToClass at: anIndex + 1
]

{ #category : 'accessing' }
CTIUniverse >> indexOf: aClass [

	^ classIndex at: aClass ifAbsent: [ nil ]
]

{ #category : 'initialization' }
CTIUniverse >> initialize [

	super initialize.
	classIndex := Dictionary new.
	indexToClass := OrderedCollection new.
	size := 0
]

{ #category : 'accessing' }
CTIUniverse >> maskFor: aClass [

	| idx |
	idx := self indexOf: aClass.
	idx ifNil: [ ^ 0 ].
	^ 1 bitShift: idx
]

{ #category : 'accessing' }
CTIUniverse >> size [

	^ size
]
