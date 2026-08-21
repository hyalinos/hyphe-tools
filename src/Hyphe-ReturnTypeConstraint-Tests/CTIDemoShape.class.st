Class {
	#name : 'CTIDemoShape',
	#superclass : 'Object',
	#instVars : [
		'label'
	],
	#category : 'Hyphe-ReturnTypeConstraint-Tests',
	#package : 'Hyphe-ReturnTypeConstraint-Tests'
}

{ #category : 'as yet unclassified' }
CTIDemoShape >> describe [

	^ self label
]

{ #category : 'as yet unclassified' }
CTIDemoShape >> label [

	^ label
]

{ #category : 'as yet unclassified' }
CTIDemoShape >> label: aString [

	label := aString
]
