"
Metrics of a class (Chidamber and Kemerer): WMC, the weighted methods per class, here the sum of the statement counts of its methods (see StatementCounter) - the instance side methods, and the class side ones if includeClassSide is true; DIT, the depth of the inheritance tree (the number of superclasses, 0 for ProtoObject); NOC, the number of children, the direct subclasses. They give context to the metrics of a single method. Use: (ClassMetrics on: OrderedCollection) wmc; or asDictionary for all of them.
"
Class {
	#name : 'ClassMetrics',
	#superclass : 'Object',
	#instVars : [
		'theClass',
		'includeClassSide'
	],
	#category : 'Hyphe-Analysis-Metrics',
	#package : 'Hyphe-Analysis',
	#tag : 'Metrics'
}

{ #category : 'instance creation' }
ClassMetrics class >> on: aClass [
	"Create the metrics of a class (the instance side methods count for WMC)"

	^ self new
		  setClass: aClass;
		  yourself
]

{ #category : 'metrics' }
ClassMetrics >> asDictionary [
	"Answer the metrics as a dictionary name -> value"

	^ Dictionary new
		  at: #wmc put: self wmc;
		  at: #dit put: self dit;
		  at: #noc put: self noc;
		  at: #numberOfMethods put: self numberOfMethods;
		  yourself
]

{ #category : 'metrics' }
ClassMetrics >> dit [
	"Answer the number of superclasses of the class"

	^ theClass allSuperclasses size
]

{ #category : 'accessing' }
ClassMetrics >> includeClassSide [
	"Answer whether the methods of the class side count for WMC"

	^ includeClassSide
]

{ #category : 'accessing' }
ClassMetrics >> includeClassSide: aBoolean [
	"Tell whether the methods of the class side must count for WMC"

	includeClassSide := aBoolean
]

{ #category : 'metrics' }
ClassMetrics >> noc [
	"Answer the number of direct subclasses of the class"

	^ theClass subclasses size
]

{ #category : 'metrics' }
ClassMetrics >> numberOfMethods [
	"Answer the number of methods the class defines (the number-of-methods count that WMC weights)"

	^ includeClassSide
		  ifTrue: [ theClass localMethods size + theClass class localMethods size ]
		  ifFalse: [ theClass localMethods size ]
]

{ #category : 'initialization' }
ClassMetrics >> setClass: aClass [
	"Set the class and count the instance side methods only"

	theClass := aClass.
	includeClassSide := false
]

{ #category : 'accessing' }
ClassMetrics >> theClass [
	"Answer the class measured"

	^ theClass
]

{ #category : 'metrics' }
ClassMetrics >> wmc [
	"Answer the sum of the statement counts of the methods defined by the class (not inherited ones)"

	| methods |
	methods := includeClassSide
		           ifTrue: [ theClass localMethods , theClass class localMethods ]
		           ifFalse: [ theClass localMethods ].
	^ methods inject: 0 into: [ :sum :method | sum + (StatementCounter countStatementsIn: method) ]
]
