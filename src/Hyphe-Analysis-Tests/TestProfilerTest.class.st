Class {
	#name : 'TestProfilerTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'as yet unclassified' }
TestProfilerTest >> dummyMethod [

	| a b |
	a = 1.
	b := a toString.

	self assert: b = '1'
]
