"
Tests of MethodMetrics: the value of each metric on methods of MetricsTestData and SelectorUserData, and the CSV export.
"
Class {
	#name : 'MethodMetricsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
MethodMetricsTest >> testAsDictionaryHasAllTheMetrics [
	"One entry per metric name"

	| dictionary |
	dictionary := (MethodMetrics on: MetricsTestData >> #mixedSends) asDictionary.

	self assert: dictionary keys asSet equals: MethodMetrics metricNames asSet.
	self assert: (dictionary at: #statements) equals: 3
]

{ #category : 'tests' }
MethodMetricsTest >> testBlocksAndReturns [
	"deepBlocks: three nested blocks, a return, an assignment... "

	| metrics |
	metrics := MethodMetrics on: MetricsTestData >> #deepBlocks.

	self assert: metrics blocks equals: 3.
	self assert: metrics maxBlockDepth equals: 3.
	self assert: metrics averageBlockDepth equals: 2.0.
	self assert: metrics explicitReturns equals: 1.
	self assert: metrics assignments equals: 1.
	self assert: metrics capturedVariables equals: 1
]

{ #category : 'tests' }
MethodMetricsTest >> testCsvRowMatchesTheHeader [
	"The row has a value per column of the header, starting with package, class and selector"

	| row |
	row := (MethodMetrics on: MetricsTestData >> #mixedSends) csvRow.

	self assert: row size equals: MethodMetrics csvHeader size.
	self assert: (MethodMetrics csvHeader first: 3) equals: #( #package #class #selector ).
	self assert: (row first: 3) equals: { #'Hyphe-Analysis-Tests'. #MetricsTestData. #mixedSends }
]

{ #category : 'tests' }
MethodMetricsTest >> testEveryMetricOfRealMethods [
	"All the metrics can be computed for the methods of a few real classes (no error, no division by zero)"

	| count |
	count := 0.
	{
		OrderedCollection.
		HyCFGBuilder.
		StatementCounter } do: [ :class |
			class methods do: [ :method |
					(MethodMetrics on: method) asDictionary.
					count := count + 1 ] ].

	self assert: count > 50
]

{ #category : 'tests' }
MethodMetricsTest >> testImplementors [
	"use sends two selectors: one implemented by three classes, one by none"

	| metrics |
	metrics := MethodMetrics on: SelectorUserData >> #use.

	self assert: metrics implementorCounts equals: (Dictionary new
			 at: #hypheUniqueSelectorX put: 3;
			 at: #hypheUniqueSelectorY put: 0;
			 yourself).
	self assert: metrics averageImplementors equals: 1.5.
	self assert: metrics maxImplementors equals: 3
]

{ #category : 'tests' }
MethodMetricsTest >> testMethodWithoutSends [
	"The averages are 0, not a division by zero"

	| metrics |
	metrics := MethodMetrics on: MetricsTestData >> #noSends.

	self assert: metrics averageImplementors equals: 0.
	self assert: metrics maxImplementors equals: 0.
	self assert: metrics selfSendRatio equals: 0
]

{ #category : 'tests' }
MethodMetricsTest >> testMixedSends [
	"self foo. var1 bar. 3 baz"

	| metrics |
	metrics := MethodMetrics on: MetricsTestData >> #mixedSends.

	self assert: metrics statements equals: 3.
	self assert: metrics linesOfCode equals: 3.
	self assert: metrics blocks equals: 0.
	self assert: metrics maxBlockDepth equals: 0.
	self assert: metrics averageBlockDepth equals: 0.
	self assert: metrics explicitReturns equals: 0.
	self assert: metrics assignments equals: 0.
	self assert: metrics cascades equals: 0.
	self assert: metrics capturedVariables equals: 0.
	self assert: metrics selfSendRatio equals: 1 / 3.
	self assert: metrics nilDensity equals: 0.
	self assert: metrics classReferences equals: 1.
	self assert: metrics distinctSelectors equals: 3.
	self assert: metrics fanOut equals: 2
]

{ #category : 'tests' }
MethodMetricsTest >> testReceiverProfile [
	"The profile of the receivers"

	self assert: (MethodMetrics on: MetricsTestData >> #sendsToSelf) receiverProfile equals: (ReceiverOriginCounter new
			 analyzeMethod: MetricsTestData >> #sendsToSelf;
			 yourself) profile
]
