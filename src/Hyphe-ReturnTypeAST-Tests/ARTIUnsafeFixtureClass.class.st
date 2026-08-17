"
Fixture: an Object subclass whose class side overrides #new, used by
ARTINewSafetyTableTest and by check-7 fixtures on ARTIFixtures to exercise the 'unsafe' case.
"
Class {
	#name : 'ARTIUnsafeFixtureClass',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Tests-Fixtures',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Fixtures'
}

{ #category : 'instance creation' }
ARTIUnsafeFixtureClass class >> new [

	^ super new
]
