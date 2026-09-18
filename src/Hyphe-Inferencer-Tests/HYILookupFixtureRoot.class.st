"
Controlled hierarchy for HYILookupTest -- real classes for expand()/AllDefiners to walk; the actual Sigma type content used in tests is stubbed (Task 6 tests Lookup's navigation/weakening, not Task 7/8's body-typing rules).
"
Class {
	#name : 'HYILookupFixtureRoot',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixture' }
HYILookupFixtureRoot >> hyiFixtureMarker [
	"Also independently defined, unrelated, on HYILookupFixtureOther -- exercises Lookup's union-of-unrelated-classes case."

	^ 0
]

{ #category : 'fixture' }
HYILookupFixtureRoot >> value [
	"Overridden by HYILookupFixtureChild and independently redefined by HYILookupFixtureOther -- exercises Lookup's self-send/Case-4 union and the unrelated-classes case together."

	^ 0
]

{ #category : 'fixture' }
HYILookupFixtureRoot >> whoAmI [
	"A plain var-self case, kept in the Lookup fixture family for convenience."

	^ self
]
