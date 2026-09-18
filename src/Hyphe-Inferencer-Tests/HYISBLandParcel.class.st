"
Shape Sandbox fixture -- unrelated to HYISBShape beyond Object, independently defines area/describe with a different real formula (width*length), giving Lookup's unrelated-classes-same-selector case real, distinct content.
"
Class {
	#name : 'HYISBLandParcel',
	#superclass : 'Object',
	#instVars : [
		'width',
		'length'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'geometry' }
HYISBLandParcel >> area [
	"Independently defines the same selector as HYISBShape's family, with a real, different formula -- Lookup's unrelated-classes-same-selector case with real content, not a matching pair of ^0s."

	^ width * length
]

{ #category : 'geometry' }
HYISBLandParcel >> describe [
	"Mirrors HYISBShape>>describe's shape (delegates to area) on a completely unrelated class."

	^ self area
]

{ #category : 'initialization' }
HYISBLandParcel >> width: w length: l [
	"Sets both ivars area/describe read."

	width := w.
	length := l
]
