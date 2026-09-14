"
Task 7 fixture for the var-ivar / assign-ivar typing rules -- a single ivar with a plain reader and writer.
"
Class {
	#name : 'HYITyperIvarFixture',
	#superclass : 'Object',
	#instVars : [
		'iv'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixture' }
HYITyperIvarFixture >> getIv [
	"var-ivar: reads the ivar written by setIv:."

	^ iv
]

{ #category : 'fixture' }
HYITyperIvarFixture >> setIv: x [
	"assign-ivar: writes the ivar getIv reads back."

	iv := x
]
