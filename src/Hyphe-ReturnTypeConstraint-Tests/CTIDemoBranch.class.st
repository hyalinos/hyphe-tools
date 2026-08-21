Class {
	#name : 'CTIDemoBranch',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeConstraint-Tests',
	#package : 'Hyphe-ReturnTypeConstraint-Tests'
}

{ #category : 'as yet unclassified' }
CTIDemoBranch >> callPick [

	^ self pick: true
]

{ #category : 'as yet unclassified' }
CTIDemoBranch >> callPick2 [

	^ self pick: false
]

{ #category : 'as yet unclassified' }
CTIDemoBranch >> pick: aBoolean [

	^ aBoolean
		  ifTrue: [ 42 ]
		  ifFalse: [ 'hi' ]
]
