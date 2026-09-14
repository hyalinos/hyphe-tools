"
Shape Sandbox fixture -- HYISBShape subclass, overrides area (real arithmetic on its own ivar side) and describe (super send, the classic override-and-extend shape).
"
Class {
	#name : 'HYISBSquare',
	#superclass : 'HYISBShape',
	#instVars : [
		'side'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'geometry' }
HYISBSquare >> area [
	"Overrides HYISBShape's abstract area with real arithmetic on its own ivar side."

	^ side * side
]

{ #category : 'geometry' }
HYISBSquare >> cornerCountIfValid: aFlag [
	"One branch reachable and Fixed, the other Bottom -- domain-flavored twin of HYITyperFixture>>errorBranch:, expected Fixed-NS(SmallInteger) (+) Bottom."

	aFlag
		ifTrue: [ ^ 4 ]
		ifFalse: [ self error: 'invalid square' ]
]

{ #category : 'geometry' }
HYISBSquare >> describe [
	"Super send: delegates to the inherited dispatcher (HYISBShape>>describe), which in turn self-sends area and, via substSelf, resolves back to THIS class's own override -- the classic override-and-extend shape."

	^ super describe
]

{ #category : 'converting' }
HYISBSquare >> rootShape [
	"var-super: bare super as a value, not a send -- rare in real code (see r-super for the idiomatic super-send case) but included since the spec names it as its own rule distinct from super-send."

	^ super
]
