Class {
	#name : 'LOCCounterTest',
	#superclass : 'TestCase',
	#instVars : [
		'counter'
	],
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'running' }
LOCCounterTest >> setUp [
	super setUp.
	counter := LOCCounter new
]

{ #category : 'running' }
LOCCounterTest >> testSimpleMethod [
	"Test basic LOC calculation for a simple method"
	
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #simpleMethod.
	
	self assert: loc equals: 3
]
