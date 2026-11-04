"
Tests of HYEChiSquareTest against known values of the chi-square distribution and of the test of independence.
"
Class {
	#name : 'HYEChiSquareStatisticTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Analysis',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Analysis'
}

{ #category : 'tests' }
HYEChiSquareStatisticTest >> testEmptyRowsAndColumnsAreIgnored [
	"A group without data does not count as a column"

	| test |
	test := HYEChiSquareTest on: #( #( 10 0 20 ) #( 30 0 40 ) ).

	self assert: test degreesOfFreedom equals: 1.
	self assert: (test statistic closeTo: 50 / 63)
]

{ #category : 'tests' }
HYEChiSquareStatisticTest >> testIndependence [
	"Same proportions everywhere: statistic 0, p 1, V 0"

	| test |
	test := HYEChiSquareTest on: #( #( 5 5 ) #( 5 5 ) ).

	self assert: test statistic equals: 0.
	self assert: (test pValue closeTo: 1.0).
	self assert: test cramersV equals: 0
]

{ #category : 'tests' }
HYEChiSquareStatisticTest >> testNotEnoughDataToTest [
	"One column or one row: nothing can be tested"

	| test |
	test := HYEChiSquareTest on: #( #( 10 0 ) #( 30 0 ) ).

	self assert: test statistic isNil.
	self assert: test pValue isNil.
	self assert: test cramersV isNil.
	self assert: test degreesOfFreedom isNil.
	self deny: (test isSignificantAt: 0.05).
	self assert: (HYEChiSquareTest on: #( #( 0 0 ) #( 0 0 ) )) statistic isNil
]

{ #category : 'tests' }
HYEChiSquareStatisticTest >> testStatisticOfATwoByTwoTable [
	"[[10 20] [30 40]]: 50/63 = 0.794 for 1 degree of freedom, p = 0.373"

	| test |
	test := HYEChiSquareTest on: #( #( 10 20 ) #( 30 40 ) ).

	self assert: (test statistic closeTo: 50 / 63).
	self assert: test degreesOfFreedom equals: 1.
	self assert: test total equals: 100.
	self assert: (test pValue - 0.372998) abs < 1.0e-5.
	self deny: (test isSignificantAt: 0.05)
]

{ #category : 'tests' }
HYEChiSquareStatisticTest >> testStrongDependence [
	"The group decides the result: all correct in two groups, all wrong in the two others"

	| test |
	test := HYEChiSquareTest on: #( #( 2 2 0 0 ) #( 0 0 2 2 ) ).

	self assert: (test statistic closeTo: 8.0).
	self assert: test degreesOfFreedom equals: 3.
	self assert: (test cramersV closeTo: 1.0).
	self assert: (test isSignificantAt: 0.05)
]

{ #category : 'tests' }
HYEChiSquareStatisticTest >> testUpperTailOfKnownCriticalValues [
	"The 5% critical values: 3.841 for 1 degree of freedom, 5.991 for 2, 9.488 for 4, 12.592 for 6"

	self assert: ((HYEChiSquareTest upperTailOf: 3.841458820694124 degreesOfFreedom: 1) closeTo: 0.05).
	self assert: ((HYEChiSquareTest upperTailOf: 5.991464547107979 degreesOfFreedom: 2) closeTo: 0.05).
	self assert: ((HYEChiSquareTest upperTailOf: 9.487729036781154 degreesOfFreedom: 4) closeTo: 0.05).
	self assert: ((HYEChiSquareTest upperTailOf: 12.591587243743977 degreesOfFreedom: 6) closeTo: 0.05)
]

{ #category : 'tests' }
HYEChiSquareStatisticTest >> testUpperTailOfOtherValues [
	"1% points, and the extremes"

	self assert: ((HYEChiSquareTest upperTailOf: 6.6348966010212145 degreesOfFreedom: 1) closeTo: 0.01).
	self assert: ((HYEChiSquareTest upperTailOf: 0 degreesOfFreedom: 3) closeTo: 1.0).
	self assert: (HYEChiSquareTest upperTailOf: 200 degreesOfFreedom: 3) < 1.0e-30
]
