"
A class with two children and methods with known statement counts, to test the class metrics: one statement-count of 2 (return and send), one of 2.
"
Class {
	#name : 'WmcTestParent',
	#superclass : 'Object',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'testin' }
WmcTestParent class >> make [
	"Fixture of the tests of the class metrics (testin): it is analyzed, never run."

	^ self new
]

{ #category : 'testin' }
WmcTestParent >> first [
	"Fixture of the tests of the class metrics (testin): it is analyzed, never run."

	^ self foo
]

{ #category : 'testin' }
WmcTestParent >> second [
	"Fixture of the tests of the class metrics (testin): it is analyzed, never run."

	self a.
	self b
]
