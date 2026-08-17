"
Fixture: an Object subclass whose class side overrides #basicNew (rather than
#new), used to confirm the safety table treats a basicNew override as equally unsafe.
"
Class {
	#name : 'ARTIUnsafeFixtureBasicNewClass',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Tests-Fixtures',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Fixtures'
}

{ #category : 'instance creation' }
ARTIUnsafeFixtureBasicNewClass class >> basicNew [

	^ super basicNew
]
