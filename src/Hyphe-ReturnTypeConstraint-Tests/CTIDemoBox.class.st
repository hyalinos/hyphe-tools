Class {
	#name : 'CTIDemoBox',
	#superclass : 'Object',
	#instVars : [
		'contents'
	],
	#category : 'Hyphe-ReturnTypeConstraint-Tests',
	#package : 'Hyphe-ReturnTypeConstraint-Tests'
}

{ #category : 'as yet unclassified' }
CTIDemoBox >> fill [

	contents := 42.
	^ contents
]

{ #category : 'as yet unclassified' }
CTIDemoBox >> makeShape [

	| s |
	s := CTIDemoShape new.
	s label: 'hi'.
	^ s
]

{ #category : 'as yet unclassified' }
CTIDemoBox >> useShape [

	| s |
	s := self makeShape.
	^ s describe
]
