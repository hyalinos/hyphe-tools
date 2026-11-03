"
Tests of HyOutcomeTally: counts and rates.
"
Class {
	#name : 'HyOutcomeTallyTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Comparison',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Comparison'
}

{ #category : 'helpers' }
HyOutcomeTallyTest >> tallyOf: someOutcomes [
	"Answer a tally with the outcomes"

	| tally |
	tally := HyOutcomeTally new.
	someOutcomes do: [ :outcome | tally add: outcome ].
	^ tally
]

{ #category : 'tests' }
HyOutcomeTallyTest >> testCounts [
	"Each outcome is counted"

	| tally |
	tally := self tallyOf: #( #correct #correct #partial #incorrect #abstained #excluded #excluded #excluded ).

	self assert: tally correct equals: 2.
	self assert: tally partial equals: 1.
	self assert: tally incorrect equals: 1.
	self assert: tally abstained equals: 1.
	self assert: tally excluded equals: 3.
	self assert: tally answered equals: 4.
	self assert: tally evaluated equals: 5
]

{ #category : 'tests' }
HyOutcomeTallyTest >> testNothingAnswered [
	"No answer: the rates are undefined (nil), not an error"

	| tally |
	tally := self tallyOf: #( #abstained #abstained #excluded ).

	self assert: tally accuracy isNil.
	self assert: tally accuracyWithPartial isNil.
	self assert: tally coverage equals: 0.
	self assert: (self tallyOf: #(  )) coverage isNil
]

{ #category : 'tests' }
HyOutcomeTallyTest >> testPrintString [
	"The counts are printed"

	self assert: ((self tallyOf: #( #correct )) printString includesSubstring: 'correct=1')
]

{ #category : 'tests' }
HyOutcomeTallyTest >> testRates [
	"Accuracy over the answers, with partial answers, coverage over the evaluated methods"

	| tally |
	tally := self tallyOf: #( #correct #correct #partial #incorrect #abstained #excluded ).

	self assert: tally accuracy equals: 1 / 2.
	self assert: tally accuracyWithPartial equals: 3 / 4.
	self assert: tally coverage equals: 4 / 5
]
