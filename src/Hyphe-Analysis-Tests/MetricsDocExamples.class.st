"
The methods used as examples in the documentation of the metrics (see the document Hyphe Analysis: method and class metrics). Each method is analyzed, never run.
"
Class {
	#name : 'MetricsDocExamples',
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

{ #category : 'examples' }
MetricsDocExamples >> assignments [
	"Three assignments."

	| a b |
	a := b:= 1.
	b := a + 1.
	a := b * 2.
	^ a
]

{ #category : 'examples' }
MetricsDocExamples >> captured [
	"x is captured by the block, result and y are not."

	| x result |
	x := 42.
	result := [ :y | x + y ].
	^ result value: 10
]

{ #category : 'examples' }
MetricsDocExamples >> cascades [
	"One cascade of three messages."

	^ OrderedCollection new
		  add: 1;
		  add: 2;
		  yourself
]

{ #category : 'examples' }
MetricsDocExamples >> nilChecks: x [
	"Three nil checks: isNil, ifNil: and == nil."

	x isNil ifTrue: [ ^ 0 ].
	x ifNil: [ ^ 1 ].
	^ x == nil
]

{ #category : 'examples' }
MetricsDocExamples >> receiverKinds: arg [
	"One send for each kind of receiver."

	| local |
	local := 1.
	arg foo.
	self foo.
	super foo.
	3 foo.
	local foo.
	var1 foo.
	SharedVar foo.
	OrderedCollection new
]

{ #category : 'examples' }
MetricsDocExamples >> referencedClasses [
	"Refers to OrderedCollection, Dictionary and, through the literal 'text', to String."

	^ {
		  OrderedCollection new.
		  Dictionary new.
		  'text' size }
]

{ #category : 'examples' }
MetricsDocExamples >> selfSends [
	"Two of the four sends go to self."

	self foo.
	self bar.
	var1 baz.
	3 qux
]

{ #category : 'examples' }
MetricsDocExamples >> sendsToImplementors [
	"Sends initialize, printString and size, whose implementors are counted."

	self initialize.
	^ self printString size
]

{ #category : 'examples' }
MetricsDocExamples >> statements [
	"Five statements: assignment, new, add:, return, size."

	| x |
	x := OrderedCollection new.
	x add: 3.
	^ x size
]
