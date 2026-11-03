"
Sends hypheUniqueSelectorX, which three classes implement, and hypheUniqueSelectorY, which nobody does.
"
Class {
	#name : 'SelectorUserData',
	#superclass : 'Object',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'testin' }
SelectorUserData >> use [
	"Fixture of the tests of the selector analysis (testin): it is analyzed, never run."

	self
		hypheUniqueSelectorX;
		hypheUniqueSelectorY
]

{ #category : 'testin' }
SelectorUserData >> useTwice [
	"Fixture of the tests of the selector analysis (testin): it is analyzed, never run."

	self hypheUniqueSelectorX.
	self hypheUniqueSelectorX
]
