"
Methods with a known structure, for the tests of the metrics (receivers of the sends, depth of the blocks, selectors, classes, fan-out...). Each method has the comment of what is expected.
"
Class {
	#name : 'MetricsTestData',
	#superclass : 'Object',
	#instVars : [
		'var1'
	],
	#classVars : [
		'SharedVar'
	],
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'fanou' }
MetricsTestData class >> fanOutClassSide [
	"Fixture of the tests of the metrics (fanou): it is analyzed, never run."

	^ self new
]

{ #category : 'classe' }
MetricsTestData class >> instantiatesItself [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ self new
]

{ #category : 'classe' }
MetricsTestData class >> instantiatesThroughSuper [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ super new
]

{ #category : 'selector' }
MetricsTestData >> cascadeOfSends [
	"Fixture of the tests of the metrics (selector): it is analyzed, never run."

	^ OrderedCollection new
		  add: 1;
		  add: 2;
		  yourself
]

{ #category : 'receiver' }
MetricsTestData >> cascadeSends [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	var1
		foo;
		bar;
		baz
]

{ #category : 'block' }
MetricsTestData >> deepBlocks [
	"Fixture of the tests of the metrics (block): it is analyzed, never run."

	| result |
	result := OrderedCollection new.
	self items do: [ :item | item isValid ifTrue: [ item children do: [ :child | result add: child name ] ] ].
	^ result
]

{ #category : 'fanou' }
MetricsTestData >> fanOutOfNewInstance [
	"Fixture of the tests of the metrics (fanou): it is analyzed, never run."

	OrderedCollection new add: 3
]

{ #category : 'fanou' }
MetricsTestData >> fanOutOfResolvedReceivers [
	"Fixture of the tests of the metrics (fanou): it is analyzed, never run."

	self foo.
	OrderedCollection new.
	3 foo.
	'x' foo
]

{ #category : 'fanou' }
MetricsTestData >> fanOutOfSuper [
	"Fixture of the tests of the metrics (fanou): it is analyzed, never run."

	super initialize
]

{ #category : 'fanou' }
MetricsTestData >> fanOutWithUnresolvedReceivers [
	"Fixture of the tests of the metrics (fanou): it is analyzed, never run."

	| t |
	t foo.
	t bar.
	self baz
]

{ #category : 'classe' }
MetricsTestData >> instantiatesFromTheInstanceSide [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ self class new
]

{ #category : 'receiver' }
MetricsTestData >> mixedSends [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	self foo.
	var1 bar.
	3 baz
]

{ #category : 'block' }
MetricsTestData >> nestedBlocks [
	"Fixture of the tests of the metrics (block): it is analyzed, never run."

	| matrix |
	matrix := #( #( 1 2 ) #( 3 4 ) ).
	matrix do: [ :row | row do: [ :cell | Transcript show: cell printString ] ]
]

{ #category : 'block' }
MetricsTestData >> noBlocks [
	"Fixture of the tests of the metrics (block): it is analyzed, never run."

	| x |
	x := 3 + 4.
	^ x printString
]

{ #category : 'receiver' }
MetricsTestData >> noSends [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	^ 1
]

{ #category : 'block' }
MetricsTestData >> oneBlock [
	"Fixture of the tests of the metrics (block): it is analyzed, never run."

	| result |
	result := OrderedCollection new.
	#( 1 2 3 ) do: [ :each | result add: each * 2 ].
	^ result
]

{ #category : 'classe' }
MetricsTestData >> referencesConstants [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ nil isNil or: [ true ]
]

{ #category : 'classe' }
MetricsTestData >> referencesLiterals [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ 3 + 'abc' size + #( 1 2 ) size
]

{ #category : 'classe' }
MetricsTestData >> referencesNoClass [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ self
]

{ #category : 'classe' }
MetricsTestData >> referencesOneClass [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ OrderedCollection new
]

{ #category : 'classe' }
MetricsTestData >> referencesTheSameClassTwice [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	OrderedCollection new.
	^ OrderedCollection new: 3
]

{ #category : 'classe' }
MetricsTestData >> referencesTwoClasses [
	"Fixture of the tests of the metrics (classe): it is analyzed, never run."

	^ {
		  OrderedCollection new.
		  Dictionary new }
]

{ #category : 'selector' }
MetricsTestData >> repeatedSends [
	"Fixture of the tests of the metrics (selector): it is analyzed, never run."

	self foo.
	self foo.
	self bar.
	3 + 4.
	5 + 6
]

{ #category : 'receiver' }
MetricsTestData >> sendsToArguments: a and: b [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	a foo.
	a bar.
	b baz
]

{ #category : 'receivers' }
MetricsTestData >> sendsToClassVariables [
	"Fixture of the tests of the metrics (receivers): it is analyzed, never run."

	SharedVar foo
]

{ #category : 'receiver' }
MetricsTestData >> sendsToGlobals [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	OrderedCollection new.
	Smalltalk at: #x
]

{ #category : 'receiver' }
MetricsTestData >> sendsToInstanceVariables [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	var1 foo.
	var1 bar
]

{ #category : 'receiver' }
MetricsTestData >> sendsToLiterals [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	3 foo.
	'x' bar.
	#sym baz.
	#( 1 2 ) size.
	nil isNil
]

{ #category : 'receiver' }
MetricsTestData >> sendsToLocals [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	| t |
	t := OrderedCollection new.
	t add: 1.
	[ :each | each foo ] value: t
]

{ #category : 'receiver' }
MetricsTestData >> sendsToMessageResults [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	self foo bar
]

{ #category : 'receiver' }
MetricsTestData >> sendsToSelf [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	self foo.
	self bar: 1
]

{ #category : 'receiver' }
MetricsTestData >> sendsToSuper [
	"Fixture of the tests of the metrics (receiver): it is analyzed, never run."

	super initialize.
	super printString
]

{ #category : 'block' }
MetricsTestData >> siblingBlocks [
	"Fixture of the tests of the metrics (block): it is analyzed, never run."

	#( 1 ) do: [ :a | a foo ].
	#( 2 ) do: [ :b | b bar ]
]

{ #category : 'block' }
MetricsTestData >> siblingsInABlock [
	"Fixture of the tests of the metrics (block): it is analyzed, never run."

	#( 1 ) do: [ :a |
			a do: [ :b | b foo ].
			a do: [ :c | c bar ] ]
]
