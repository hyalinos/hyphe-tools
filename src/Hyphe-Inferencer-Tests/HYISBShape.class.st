"
Shape Sandbox: the root of a small real-code hierarchy built to exercise every Task 7/8 typing rule plus dataflow and polymorphism across a class hierarchy, instead of one-liner/^0 fixtures.
"
Class {
	#name : 'HYISBShape',
	#superclass : 'Object',
	#instVars : [
		'label'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'geometry' }
HYISBShape >> announceArea [
	"Bottom via a cascade part (Task 8's propagation table): on a bare HYISBShape, self area is Bottom and sits as the FIRST cascade part -- yourself is never actually reached at runtime."

	^ self
		  area;
		  yourself
]

{ #category : 'geometry' }
HYISBShape >> area [
	"The abstract-method idiom, written as the bare statement the reachability walk actually detects as Bottom (a ^-wrapped self subclassResponsibility is NOT detected -- found live, see the project memory). Overridden with real arithmetic by HYISBCircle/HYISBSquare; inherited unchanged by HYISBUnknownShape."

	self subclassResponsibility
]

{ #category : 'converting' }
HYISBShape >> asShape [
	"var-self, written as the idiomatic Smalltalk 'already this type' conversion rather than a bare identity stub."

	^ self
]

{ #category : 'geometry' }
HYISBShape >> captureArea [
	"Bottom via an assignment RHS (Task 8's propagation table): on a bare HYISBShape, self area is Bottom, assigned to a local before being returned."

	| x |
	x := self area.
	^ x
]

{ #category : 'geometry' }
HYISBShape >> describe [
	"Defined once, on the root: self here is Fixed-S(HYISBShape) -- self and its subclasses -- so this is the polymorphic-dispatch flagship case, merging HYISBShape's own Bottom with HYISBCircle/HYISBSquare's real arithmetic and HYISBUnknownShape's inherited Bottom."

	^ self area
]

{ #category : 'geometry' }
HYISBShape >> describeArea [
	"Bottom via an argument position (Task 8's propagation table): on a bare HYISBShape, self area is Bottom, passed as wrap:'s argument."

	^ self wrap: self area
]

{ #category : 'converting' }
HYISBShape >> identifyAfterLabel [
	"Cascade: self label (a real ivar read, discarded) then self asShape -- only the LAST part's result (Fixed-S(Self)) survives, with real dataflow on the discarded part instead of a second disconnected literal."

	^ self
		  label;
		  asShape
]

{ #category : 'geometry' }
HYISBShape >> impossible: aFlag [
	"Both branches terminate (Task 8): no reachable non-Bottom outcome at all -- the union collapses to pure Bottom, not Fixed (+) Bottom."

	aFlag
		ifTrue: [ self error: 'a' ]
		ifFalse: [ self error: 'b' ]
]

{ #category : 'initialization' }
HYISBShape >> initialize [
	"assign-ivar, site 1 of 2 (paired with label:) -- both declared on HYISBShape itself, so both land in the same Theta bucket and merge."

	label := 'unlabeled'
]

{ #category : 'accessing' }
HYISBShape >> label [
	"var-ivar: reads Theta's bucket for HYISBShape, merged from initialize and label:'s writes."

	^ label
]

{ #category : 'accessing' }
HYISBShape >> label: aString [
	"assign-ivar, site 2 of 2 (paired with initialize)."

	label := aString
]

{ #category : 'accessing' }
HYISBShape >> renamedTo: aString [
	"Keyword send used purely for its Theta side effect (self label: aString, return value discarded), then a second, different self-sent method (self label) observes that effect -- real two-hop interprocedural dataflow in one method."

	self label: aString.
	^ self label
]

{ #category : 'geometry' }
HYISBShape >> wrap: x [
	"Trivial identity helper, used only so describeArea has an argument position to put a Bottom-producing expression into."

	^ x
]
