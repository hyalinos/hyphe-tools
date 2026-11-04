"
Tests of the two group schemes of the experiments: by number of statements and by number of return points.
"
Class {
	#name : 'HYEGroupSchemeTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Grouping',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Grouping'
}

{ #category : 'tests' }
HYEGroupSchemeTest >> testGroupsAreEqualByValue [
	"Two schemes of the same kind have interchangeable groups"

	self assert: HYEGroupScheme statementCount groups first equals: HYEGroupScheme statementCount groups first.
	self deny: HYEGroupScheme statementCount groups first = HYEGroupScheme returnPoints groups first.
	self assert: (HYEGroupScheme statementCount groupNamed: 'G3') label equals: '4-8 statements'
]

{ #category : 'tests' }
HYEGroupSchemeTest >> testMeasures [
	"statements and returns of a known method: ^ self foo is a return and a send"

	| method |
	method := WmcTestParent >> #first.

	self assert: (HYEGroupScheme statementCount measure: method) equals: 2.
	self assert: (HYEGroupScheme returnPoints measure: method) equals: 1
]

{ #category : 'tests' }
HYEGroupSchemeTest >> testMetricNames [
	"The column of the measure in the files"

	self assert: HYEGroupScheme statementCount metricName equals: 'count'.
	self assert: HYEGroupScheme returnPoints metricName equals: 'countReturn'
]

{ #category : 'tests' }
HYEGroupSchemeTest >> testReturnPointsGroups [
	"0, 1, 2, 3 or more return points"

	| scheme |
	scheme := HYEGroupScheme returnPoints.

	self assert: (scheme groupFor: 0) name equals: 'G1'.
	self assert: (scheme groupFor: 1) name equals: 'G2'.
	self assert: (scheme groupFor: 2) name equals: 'G3'.
	self assert: (scheme groupFor: 3) name equals: 'G4'.
	self assert: (scheme groupFor: 13) name equals: 'G4'
]

{ #category : 'tests' }
HYEGroupSchemeTest >> testStatementCountGroups [
	"1 statement, 2-3, 4-8, more than 8"

	| scheme |
	scheme := HYEGroupScheme statementCount.

	self assert: (scheme groupFor: 1) name equals: 'G1'.
	self assert: (scheme groupFor: 2) name equals: 'G2'.
	self assert: (scheme groupFor: 3) name equals: 'G2'.
	self assert: (scheme groupFor: 4) name equals: 'G3'.
	self assert: (scheme groupFor: 8) name equals: 'G3'.
	self assert: (scheme groupFor: 9) name equals: 'G4'.
	self assert: (scheme groupFor: 500) name equals: 'G4'.
	self assert: (scheme groupFor: 0) isNil
]
