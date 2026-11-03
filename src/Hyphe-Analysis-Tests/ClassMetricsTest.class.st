"
Tests of ClassMetrics (WMC, DIT, NOC) on WmcTestParent and its two children.
"
Class {
	#name : 'ClassMetricsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
ClassMetricsTest >> testAsDictionary [
	"All the metrics by name"

	| dictionary |
	dictionary := (ClassMetrics on: WmcTestParent) asDictionary.

	self assert: dictionary keys asSet equals: #( #wmc #dit #noc #numberOfMethods ) asSet.
	self assert: (dictionary at: #noc) equals: 2
]

{ #category : 'tests' }
ClassMetricsTest >> testDepthOfTheInheritanceTree [
	"WmcTestChildA < WmcTestParent < Object < ProtoObject: three superclasses"

	self assert: (ClassMetrics on: WmcTestChildA) dit equals: 3.
	self assert: (ClassMetrics on: WmcTestParent) dit equals: 2.
	self assert: (ClassMetrics on: ProtoObject) dit equals: 0
]

{ #category : 'tests' }
ClassMetricsTest >> testNumberOfChildren [
	"Two direct subclasses, none for a leaf"

	self assert: (ClassMetrics on: WmcTestParent) noc equals: 2.
	self assert: (ClassMetrics on: WmcTestChildB) noc equals: 0
]

{ #category : 'tests' }
ClassMetricsTest >> testWmcIgnoresInheritedMethods [
	"A class without method has 0, the methods of its superclass are not its own"

	self assert: (ClassMetrics on: WmcTestChildA) wmc equals: 0
]

{ #category : 'tests' }
ClassMetricsTest >> testWmcOfTheInstanceSide [
	"first is a return and a send (2), second is two sends (2)"

	self assert: (ClassMetrics on: WmcTestParent) wmc equals: 4
]

{ #category : 'tests' }
ClassMetricsTest >> testWmcWithTheClassSide [
	"make adds a return and a send"

	| metrics |
	metrics := ClassMetrics on: WmcTestParent.
	metrics includeClassSide: true.

	self assert: metrics wmc equals: 6.
	self assert: metrics numberOfMethods equals: 3
]
