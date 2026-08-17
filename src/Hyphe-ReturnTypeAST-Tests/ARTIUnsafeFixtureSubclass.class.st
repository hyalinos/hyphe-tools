"
Fixture: a subclass of ARTIUnsafeFixtureClass that itself overrides nothing, used to
confirm that safety-table unsafety propagates down to a non-overriding subclass (REQ-S2).
"
Class {
	#name : 'ARTIUnsafeFixtureSubclass',
	#superclass : 'ARTIUnsafeFixtureClass',
	#category : 'Hyphe-ReturnTypeAST-Tests-Fixtures',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Fixtures'
}
