"
Task 6 Lookup fixture -- unrelated to HYILookupFixtureRoot/Child beyond Object, independently defines the same selectors (value, hyiFixtureMarker) so Lookup's union-of-unrelated-classes case has real, non-inherited content.
"
Class {
	#name : 'HYILookupFixtureOther',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixture' }
HYILookupFixtureOther >> hyiFixtureMarker [
	"Independently defined, unrelated to Root/Child beyond Object -- Lookup's union-of-unrelated-classes case."

	^ 0
]

{ #category : 'fixture' }
HYILookupFixtureOther >> value [
	"Independently defined, unrelated to Root/Child beyond Object -- Lookup's union-of-unrelated-classes case."

	^ 0
]
