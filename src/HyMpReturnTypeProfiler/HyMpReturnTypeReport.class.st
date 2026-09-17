"
Phase 4-5 of the methodology: builds one HyMpMethodProfile per (definingClass, selector) from a flat collection of HyMpObservation, then offers the same data reorganized three ways (by method, by package, by class) as the methodology's own Phase 5 describes -- all three views are just different groupings of the identical underlying profiles, computed on demand rather than duplicated.
"
Class {
	#name : 'HyMpReturnTypeReport',
	#superclass : 'Object',
	#instVars : [
		'profilesByKey'
	],
	#category : 'HyMpReturnTypeProfiler',
	#package : 'HyMpReturnTypeProfiler'
}

{ #category : 'instance creation' }
HyMpReturnTypeReport class >> fromObservations: aCollectionOfObservations [
	"Build a report from a flat collection of HyMpObservation, as produced by HyMpReturnsCollector>>observations."

	| report |
	report := self new.
	report addAllObservations: aCollectionOfObservations.
	^ report
]

{ #category : 'recording' }
HyMpReturnTypeReport >> addAllObservations: aCollectionOfObservations [

	aCollectionOfObservations do: [ :each | self recordObservation: each ]
]

{ #category : 'exporting' }
HyMpReturnTypeReport >> asCsvString [
	"One row per (definingClass, selector, returnClass) triple, following the methodology's Section 14 'Quick Reference' expectation of a flat CSV export: definingClass,selector,returnClass,count,percentage,totalCount"

	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'definingClass,selector,returnClass,count,percentage,totalCount';
		nextPut: Character lf.
	self profiles do: [ :profile |
			profile typeCounts associationsDo: [ :assoc |
					stream
						nextPutAll: profile definingClass name asString;
						nextPut: $,;
						nextPutAll: profile selector asString;
						nextPut: $,;
						nextPutAll: assoc key name asString;
						nextPut: $,;
						print: assoc value;
						nextPut: $,;
						print: (profile percentageFor: assoc key);
						nextPut: $,;
						print: profile totalCount;
						nextPut: Character lf ] ].
	^ stream contents
]

{ #category : 'initialization' }
HyMpReturnTypeReport >> initialize [

	profilesByKey := Dictionary new
]

{ #category : 'querying' }
HyMpReturnTypeReport >> monomorphicProfiles [

	^ self profiles select: [ :each | each isMonomorphic ]
]

{ #category : 'querying' }
HyMpReturnTypeReport >> polymorphicProfiles [

	^ self profiles reject: [ :each | each isMonomorphic ]
]

{ #category : 'accessing' }
HyMpReturnTypeReport >> profileFor: dClass selector: aSelector [
	"Answer the existing profile for (dClass, aSelector), creating it on first request."

	^ profilesByKey at: dClass -> aSelector ifAbsentPut: [ HyMpMethodProfile definingClass: dClass selector: aSelector ]
]

{ #category : 'accessing' }
HyMpReturnTypeReport >> profiles [
	"All method profiles, unordered."

	^ profilesByKey values
]

{ #category : 'grouping' }
HyMpReturnTypeReport >> profilesByClass [
	"Group profiles by their defining class. Answer a Dictionary: Class -> OrderedCollection of HyMpMethodProfile."

	| result |
	result := Dictionary new.
	self profiles do: [ :profile |
			| bucket |
			bucket := result at: profile definingClass ifAbsentPut: [ OrderedCollection new ].
			bucket add: profile ].
	^ result
]

{ #category : 'grouping' }
HyMpReturnTypeReport >> profilesByPackage [
	"Group profiles by the package name of their defining class. Answer a Dictionary: package name (String) -> OrderedCollection of HyMpMethodProfile."

	| result |
	result := Dictionary new.
	self profiles do: [ :profile |
			| pkgName bucket |
			pkgName := profile definingClass package ifNil: [ 'Unknown' ] ifNotNil: [ :pkg | pkg name ].
			bucket := result at: pkgName ifAbsentPut: [ OrderedCollection new ].
			bucket add: profile ].
	^ result
]

{ #category : 'recording' }
HyMpReturnTypeReport >> recordObservation: anObservation [

	(self profileFor: anObservation definingClass selector: anObservation selector) recordReturnClass: anObservation returnClass
]

{ #category : 'accessing' }
HyMpReturnTypeReport >> size [

	^ profilesByKey size
]

{ #category : 'accessing' }
HyMpReturnTypeReport >> totalObservationCount [

	^ self profiles inject: 0 into: [ :sum :each | sum + each totalCount ]
]
