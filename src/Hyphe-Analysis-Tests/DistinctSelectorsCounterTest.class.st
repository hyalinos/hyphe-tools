"
Tests of DistinctSelectorsCounter (NDS).
"
Class {
	#name : 'DistinctSelectorsCounterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
DistinctSelectorsCounterTest >> testAnalysesDoNotAccumulate [
	"The selectors of the previous method are forgotten"

	| counter |
	counter := DistinctSelectorsCounter new.
	counter countIn: MetricsTestData >> #repeatedSends.

	self assert: (counter countIn: MetricsTestData >> #sendsToSelf) equals: 2
]

{ #category : 'tests' }
DistinctSelectorsCounterTest >> testEachMessageOfACascadeCounts [
	"new, add: (twice) and yourself"

	self assert: (DistinctSelectorsCounter new countIn: MetricsTestData >> #cascadeOfSends) equals: 3
]

{ #category : 'tests' }
DistinctSelectorsCounterTest >> testNoSend [
	"A method that sends nothing has 0 selectors"

	self assert: (DistinctSelectorsCounter new countIn: MetricsTestData >> #noSends) equals: 0
]

{ #category : 'tests' }
DistinctSelectorsCounterTest >> testRepeatedSelectorsCountOnce [
	"foo twice, bar, + twice: three distinct selectors"

	self assert: (DistinctSelectorsCounter new countIn: MetricsTestData >> #repeatedSends) equals: 3.
	self assert: (DistinctSelectorsCounter new selectorsIn: MetricsTestData >> #repeatedSends) equals: #( #foo #bar #+ ) asSet
]
