Class {
	#name : 'CTIMethodInfo',
	#superclass : 'Object',
	#instVars : [
		'selfVar',
		'paramVars',
		'returnVar',
		'targetClass',
		'selector',
		'generated'
	],
	#category : 'Hyphe-ReturnTypeConstraint',
	#package : 'Hyphe-ReturnTypeConstraint'
}

{ #category : 'accessing' }
CTIMethodInfo >> generated [

	^ generated
]

{ #category : 'accessing' }
CTIMethodInfo >> generated: aBool [

	generated := aBool
]

{ #category : 'initialization' }
CTIMethodInfo >> initialize [

	super initialize.
	generated := false
]

{ #category : 'accessing' }
CTIMethodInfo >> paramVars [

	^ paramVars
]

{ #category : 'accessing' }
CTIMethodInfo >> paramVars: coll [

	paramVars := coll
]

{ #category : 'accessing' }
CTIMethodInfo >> returnVar [

	^ returnVar
]

{ #category : 'accessing' }
CTIMethodInfo >> returnVar: v [

	returnVar := v
]

{ #category : 'accessing' }
CTIMethodInfo >> selector [

	^ selector
]

{ #category : 'accessing' }
CTIMethodInfo >> selector: s [

	selector := s
]

{ #category : 'accessing' }
CTIMethodInfo >> selfVar [

	^ selfVar
]

{ #category : 'accessing' }
CTIMethodInfo >> selfVar: v [

	selfVar := v
]

{ #category : 'accessing' }
CTIMethodInfo >> targetClass [

	^ targetClass
]

{ #category : 'accessing' }
CTIMethodInfo >> targetClass: c [

	targetClass := c
]
