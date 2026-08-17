"
Tests for ARTINewSafetyTable (REQ-T1) against the ARTI*Fixture* classes: safe/unsafe
via new, unsafe via basicNew, unsafety propagating to a non-overriding subclass, and memoization.
"
Class {
	#name : 'ARTINewSafetyTableTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTINewSafetyTableTest >> testClassOverridingBasicNewIsUnsafe [

	self deny:
		(ARTINewSafetyTable new isSafe: ARTIUnsafeFixtureBasicNewClass)
]

{ #category : 'tests' }
ARTINewSafetyTableTest >> testClassOverridingNewIsUnsafe [

	self deny: (ARTINewSafetyTable new isSafe: ARTIUnsafeFixtureClass)
]

{ #category : 'tests' }
ARTINewSafetyTableTest >> testObjectItselfIsTheTopOfTheComputation [
	"REQ-S2: computed top-down, Object first."

	self assert: (ARTINewSafetyTable new isSafe: Object)
]

{ #category : 'tests' }
ARTINewSafetyTableTest >> testPlainClassWithNoOverridesIsSafe [

	self assert: (ARTINewSafetyTable new isSafe: ARTISafeFixtureClass)
]

{ #category : 'tests' }
ARTINewSafetyTableTest >> testResultIsMemoizedAcrossCallsOnTheSameTable [

	| table |
	table := ARTINewSafetyTable new.
	self
		assert: (table isSafe: ARTISafeFixtureClass)
		equals: (table isSafe: ARTISafeFixtureClass).
	self assert: (table isSafe: ARTISafeFixtureClass)
]

{ #category : 'tests' }
ARTINewSafetyTableTest >> testTableIsScopedPerInvocationNotShared [
	"Two separately-created tables don't share mutable state."

	| t1 t2 |
	t1 := ARTINewSafetyTable new.
	t2 := ARTINewSafetyTable new.
	self deny: t1 == t2.
	self
		assert: (t1 isSafe: ARTISafeFixtureClass)
		equals: (t2 isSafe: ARTISafeFixtureClass)
]

{ #category : 'tests' }
ARTINewSafetyTableTest >> testUnsafetyPropagatesDownToNonOverridingSubclass [
	"REQ-S2: false propagates from an unsafe superclass entry even when the subclass itself
	doesn't override anything."

	self deny: (ARTINewSafetyTable new isSafe: ARTIUnsafeFixtureSubclass)
]
