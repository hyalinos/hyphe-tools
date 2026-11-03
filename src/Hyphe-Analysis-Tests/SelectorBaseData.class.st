"
Implements a selector that no other class of the image implements, to test the analysis of the implementors and of the overrides: SelectorBaseData is the base, SelectorChildData overrides, SelectorOtherData is unrelated.
"
Class {
	#name : 'SelectorBaseData',
	#superclass : 'Object',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'testin' }
SelectorBaseData >> hypheUniqueSelectorX [
	"Fixture of the tests of the selector analysis (testin): it is analyzed, never run."

	^ 1
]
