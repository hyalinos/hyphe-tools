"
Methods used as examples in the documentation of the CFG metrics. They are compiled, never run: their complexity is fixed by the tests of HyCFGMetricsTest.
"
Class {
	#name : 'HyCFGDocExamples',
	#superclass : 'Object',
	#category : 'Hyphe-CFG-Tests-Structure',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Structure'
}

{ #category : 'examples' }
HyCFGDocExamples >> booleanOperators: x [
	"Complexity 1: and: is not a branch of the CFG"

	^ x > 0 and: [ x < 10 ]
]

{ #category : 'examples' }
HyCFGDocExamples >> everything: items [
	"Complexity 4: a loop, a conditional and a handler"

	items do: [ :e | e isNil ifTrue: [ ^ 1 ] ].
	[ self foo ]
		on: Error
		do: [ :ex | self bar ].
	^ 2
]

{ #category : 'examples' }
HyCFGDocExamples >> loopWithConditional: items [
	"Complexity 3: one loop and one conditional"

	items do: [ :e | e isNil ifTrue: [ ^ e ] ].
	^ nil
]

{ #category : 'examples' }
HyCFGDocExamples >> oneConditional: x [
	"Complexity 2: one conditional"

	x > 0 ifTrue: [ ^ 'positive' ].
	^ 'not positive'
]

{ #category : 'examples' }
HyCFGDocExamples >> straightLine [
	"Complexity 1: no decision"

	| a |
	a := 3.
	^ a + 1
]

{ #category : 'examples' }
HyCFGDocExamples >> withHandler [
	"Complexity 2: one exception handler"

	^ [ self foo ]
		  on: Error
		  do: [ :ex | 0 ]
]
