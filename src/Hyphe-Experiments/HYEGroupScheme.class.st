"
A way to split methods in groups according to a measure of the method. statementCount: 1 statement, 2-3, 4-8, more than 8 (the effect of the number of statements). returnPoints: 0, 1, 2, 3 or more return points (the effect of the number of returns). groupFor: gives the group of a value, measure: the value for a compiled method.
"
Class {
	#name : 'HYEGroupScheme',
	#superclass : 'Object',
	#instVars : [
		'name',
		'groups',
		'metricName',
		'metricBlock'
	],
	#category : 'Hyphe-Experiments-Grouping',
	#package : 'Hyphe-Experiments',
	#tag : 'Grouping'
}

{ #category : 'instance creation' }
HYEGroupScheme class >> name: aName metric: aMetricName block: aBlock groups: someGroups [
	"Create a scheme: the block gives the measure of a compiled method"

	^ self new
		  setName: aName
		  metric: aMetricName
		  block: aBlock
		  groups: someGroups;
		  yourself
]

{ #category : 'instance creation' }
HYEGroupScheme class >> returnPoints [
	"Four groups by number of return points, i.e. explicit returns (see ReturnCounter): 0, 1, 2, 3 or more"

	^ self
		  name: 'returnPoints'
		  metric: 'countReturn'
		  block: [ :method | ReturnCounter new returnInMethod: method ]
		  groups: {
				  (HYEMethodGroup
					   name: 'G1'
					   label: '0 return points'
					   lower: 0
					   upper: 0).
				  (HYEMethodGroup
					   name: 'G2'
					   label: '1 return point'
					   lower: 1
					   upper: 1).
				  (HYEMethodGroup
					   name: 'G3'
					   label: '2 return points'
					   lower: 2
					   upper: 2).
				  (HYEMethodGroup
					   name: 'G4'
					   label: '>= 3 return points'
					   lower: 3
					   upper: nil) }
]

{ #category : 'instance creation' }
HYEGroupScheme class >> statementCount [
	"Four groups by number of statements (see StatementCounter): 1, 2-3, 4-8, more than 8"

	^ self
		  name: 'statementCount'
		  metric: 'count'
		  block: [ :method | StatementCounter countStatementsIn: method ]
		  groups: {
				  (HYEMethodGroup
					   name: 'G1'
					   label: '1 statement'
					   lower: 1
					   upper: 1).
				  (HYEMethodGroup
					   name: 'G2'
					   label: '2-3 statements'
					   lower: 2
					   upper: 3).
				  (HYEMethodGroup
					   name: 'G3'
					   label: '4-8 statements'
					   lower: 4
					   upper: 8).
				  (HYEMethodGroup
					   name: 'G4'
					   label: '> 8 statements'
					   lower: 9
					   upper: nil) }
]

{ #category : 'grouping' }
HYEGroupScheme >> groupFor: aNumber [
	"Answer the group a value belongs to, nil if there is none"

	^ groups detect: [ :group | group includes: aNumber ] ifNone: [ nil ]
]

{ #category : 'grouping' }
HYEGroupScheme >> groupNamed: aName [
	"Answer the group with this short name (G1...)"

	^ groups detect: [ :group | group name = aName ]
]

{ #category : 'accessing' }
HYEGroupScheme >> groups [
	"Answer the groups, in order"

	^ groups
]

{ #category : 'grouping' }
HYEGroupScheme >> measure: aCompiledMethod [
	"Answer the value of the measure for a method"

	^ metricBlock value: aCompiledMethod
]

{ #category : 'accessing' }
HYEGroupScheme >> metricName [
	"Answer the name of the measure, also the name of its column in the files"

	^ metricName
]

{ #category : 'accessing' }
HYEGroupScheme >> name [
	"Answer the name of the scheme"

	^ name
]

{ #category : 'initialization' }
HYEGroupScheme >> setName: aName metric: aMetricName block: aBlock groups: someGroups [
	"Set the parts of the scheme"

	name := aName.
	metricName := aMetricName.
	metricBlock := aBlock.
	groups := someGroups asOrderedCollection
]
