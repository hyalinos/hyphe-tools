"
Lazily-memoized, invocation-scoped table answering whether new/basicNew is guaranteed
unoverridden between a class and Object. One instance is built per tool invocation and shared
read-only across all method checks in that invocation.
"
Class {
	#name : 'ARTINewSafetyTable',
	#superclass : 'Object',
	#instVars : [
		'table'
	],
	#category : 'Hyphe-ReturnTypeAST-Safety',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Safety'
}

{ #category : 'private' }
ARTINewSafetyTable >> classOverridesNewOrBasicNew: aClass [

	^ (aClass class includesSelector: #new) or: [
		  aClass class includesSelector: #basicNew ]
]

{ #category : 'computing' }
ARTINewSafetyTable >> computeSafetyFor: aClass [
	"computed top-down (Object first), memoized once per invocation (one table instance
	lives for the whole invocation). A class is safe iff its superclass entry is safe AND the class
	itself does not override new or basicNew. Recursion naturally walks every ancestor up to Object,
	regardless of what the caller originally scoped the table to."

	| superSafe ownOverride result |
	aClass ifNil: [ ^ true ].
	(table includesKey: aClass) ifTrue: [ ^ table at: aClass ].

	superSafe := aClass = Object
		             ifTrue: [ true ]
		             ifFalse: [ self computeSafetyFor: aClass superclass ].
	ownOverride := self classOverridesNewOrBasicNew: aClass.
	result := superSafe and: [ ownOverride not ].

	table at: aClass put: result.
	^ result
]

{ #category : 'initialization' }
ARTINewSafetyTable >> initialize [

	super initialize.
	table := Dictionary new
]

{ #category : 'testing' }
ARTINewSafetyTable >> isSafe: aClass [
	"only check 'ClassName new' should use this table, and only through this method that wraps the computing"

	^ self computeSafetyFor: aClass
]
