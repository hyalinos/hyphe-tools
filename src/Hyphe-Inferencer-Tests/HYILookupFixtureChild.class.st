"
Task 6 Lookup fixture -- subclass of HYILookupFixtureRoot, overrides value and hyiFixtureMarker so Lookup's self-send/Case-4 union has a real override to find, not just an inherited answer.
"
Class {
	#name : 'HYILookupFixtureChild',
	#superclass : 'HYILookupFixtureRoot',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixture' }
HYILookupFixtureChild >> hyiFixtureMarker [
	"Overrides Root's own -- a real override for self-send Lookup to find, not just an inherited answer."

	^ 0
]

{ #category : 'fixture' }
HYILookupFixtureChild >> value [
	"Overrides Root's own -- a real override for self-send Lookup to find, not just an inherited answer."

	^ 0
]
