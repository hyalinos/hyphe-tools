Class {
	#name : 'FirdClass',
	#superclass : 'SecondClass',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
FirdClass >> classOverride [
	| x |
	x := 0.
	x := x + 1.
	
]

{ #category : 'as yet unclassified' }
FirdClass >> classOverrideFalse [
	| x |
	x := 0.
	x := x + 1.
	
]

{ #category : 'as yet unclassified' }
FirdClass >> classOverrideTrue [
	^ self class
	
]

{ #category : 'as yet unclassified' }
FirdClass >> classOverrideTrueFirst [
	^ 2 asCharacter
	
]
