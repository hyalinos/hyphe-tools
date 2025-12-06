Class {
	#name : 'TestProfilerTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
TestProfilerTest >> dummyMethod [

	| a b |
	a = 1.
	b := a toString.

	self assert: b = '1'
]
