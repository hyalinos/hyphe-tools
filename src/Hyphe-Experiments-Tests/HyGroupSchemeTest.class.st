"
Tests of the two group schemes of the experiments: by number of statements and by number of return points.
"
Class {
	#name : 'HyGroupSchemeTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Grouping',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Grouping'
}

{ #category : 'tests' }
HyGroupSchemeTest >> testGroupsAreEqualByValue [
	"Two schemes of the same kind have interchangeable groups"

	self assert: HyGroupScheme statementCount groups first equals: HyGroupScheme statementCount groups first.
	self deny: HyGroupScheme statementCount groups first = HyGroupScheme returnPoints groups first.
	self assert: (HyGroupScheme statementCount groupNamed: 'G3') label equals: '4-8 statements'
]

{ #category : 'tests' }
HyGroupSchemeTest >> testMeasures [
	"statements and returns of a known method: ^ self foo is a return and a send"

	| method |
	method := WmcTestParent >> #first.

	self assert: (HyGroupScheme statementCount measure: method) equals: 2.
	self assert: (HyGroupScheme returnPoints measure: method) equals: 1
]

{ #category : 'tests' }
HyGroupSchemeTest >> testMetricNames [
	"The column of the measure in the files"

	self assert: HyGroupScheme statementCount metricName equals: 'count'.
	self assert: HyGroupScheme returnPoints metricName equals: 'countReturn'
]

{ #category : 'tests' }
HyGroupSchemeTest >> testReturnPointsGroups [
	"0, 1, 2, 3 or more return points"

	| scheme |
	scheme := HyGroupScheme returnPoints.

	self assert: (scheme groupFor: 0) name equals: 'G1'.
	self assert: (scheme groupFor: 1) name equals: 'G2'.
	self assert: (scheme groupFor: 2) name equals: 'G3'.
	self assert: (scheme groupFor: 3) name equals: 'G4'.
	self assert: (scheme groupFor: 13) name equals: 'G4'
]

{ #category : 'tests' }
HyGroupSchemeTest >> testStatementCountGroups [
	"1 statement, 2-3, 4-8, more than 8"

	| scheme |
	scheme := HyGroupScheme statementCount.

	self assert: (scheme groupFor: 1) name equals: 'G1'.
	self assert: (scheme groupFor: 2) name equals: 'G2'.
	self assert: (scheme groupFor: 3) name equals: 'G2'.
	self assert: (scheme groupFor: 4) name equals: 'G3'.
	self assert: (scheme groupFor: 8) name equals: 'G3'.
	self assert: (scheme groupFor: 9) name equals: 'G4'.
	self assert: (scheme groupFor: 500) name equals: 'G4'.
	self assert: (scheme groupFor: 0) isNil
]
