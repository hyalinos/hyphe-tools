"
Shape Sandbox fixture -- HYISBShape subclass, overrides area with real arithmetic on its own ivar radius (an Unknown-typed receiver, unlike every other fixture's self/literal sends).
"
Class {
	#name : 'HYISBCircle',
	#superclass : 'HYISBShape',
	#instVars : [
		'radius'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'geometry' }
HYISBCircle >> area [
	"Ordinary message send whose receiver is an ivar (radius, Unknown -- nobody ever writes it in this static view), not self or a literal like every other fixture's sends."

	^ radius * radius * 3
]

{ #category : 'accessing' }
HYISBCircle >> defaultRadius [
	"A plain literal return, domain-named -- a second, independent instance of the literal rule alongside HYITyperFixture>>simpleLiteral."

	^ 1
]
