"
Tests for HyMpReturnTypeReport: aggregation from observations, grouping views, CSV export.
"
Class {
	#name : 'HyMpReturnTypeReportTest',
	#superclass : 'TestCase',
	#category : 'HyMpReturnTypeProfiler-Tests',
	#package : 'HyMpReturnTypeProfiler-Tests'
}

{ #category : 'helpers' }
HyMpReturnTypeReportTest >> makeObservation: receiverClass defines: definingClass selector: aSelector returns: returnClass [

	^ HyMpObservation new
		  receiverClass: receiverClass
		  definingClass: definingClass
		  selector: aSelector
		  returnClass: returnClass;
		  yourself
]

{ #category : 'tests' }
HyMpReturnTypeReportTest >> testAsCsvStringHasHeaderAndOneRowPerObservedType [

	| observations report lines |
	observations := OrderedCollection new.
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #x
			 returns: SmallInteger).
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #x
			 returns: Float).
	report := HyMpReturnTypeReport fromObservations: observations.
	lines := report asCsvString lines.
	self assert: lines first equals: 'definingClass,selector,returnClass,count,percentage,totalCount'.
	self assert: lines size equals: 3
]

{ #category : 'tests' }
HyMpReturnTypeReportTest >> testEmptyReport [

	| report |
	report := HyMpReturnTypeReport new.
	self assert: report size equals: 0.
	self assert: report totalObservationCount equals: 0.
	self assert: report profiles isEmpty
]

{ #category : 'tests' }
HyMpReturnTypeReportTest >> testFromObservationsBuildsOneProfilePerDefiningClassAndSelector [

	| observations report profile |
	observations := OrderedCollection new.
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #x
			 returns: SmallInteger).
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #x
			 returns: SmallInteger).
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #x
			 returns: Float).
	report := HyMpReturnTypeReport fromObservations: observations.
	self assert: report size equals: 1.
	self assert: report totalObservationCount equals: 3.
	profile := report profileFor: Point selector: #x.
	self assert: profile totalCount equals: 3.
	self deny: profile isMonomorphic
]

{ #category : 'tests' }
HyMpReturnTypeReportTest >> testInheritedMethodSharesOneProfileAcrossReceiverClasses [
	"Same defining class/selector, different receiver classes (simulating an inherited method) -- must be ONE profile, not one per receiver."

	| observations report |
	observations := OrderedCollection new.
	observations add: (self
			 makeObservation: SmallInteger
			 defines: Integer
			 selector: #printString
			 returns: String).
	observations add: (self
			 makeObservation: LargePositiveInteger
			 defines: Integer
			 selector: #printString
			 returns: String).
	report := HyMpReturnTypeReport fromObservations: observations.
	self assert: report size equals: 1.
	self assert: (report profileFor: Integer selector: #printString) totalCount equals: 2
]

{ #category : 'tests' }
HyMpReturnTypeReportTest >> testMonomorphicAndPolymorphicPartition [

	| observations report |
	observations := OrderedCollection new.
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #x
			 returns: SmallInteger).
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #y
			 returns: SmallInteger).
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #y
			 returns: Float).
	report := HyMpReturnTypeReport fromObservations: observations.
	self assert: report monomorphicProfiles size equals: 1.
	self assert: report polymorphicProfiles size equals: 1.
	self assert: report monomorphicProfiles first selector equals: #x
]

{ #category : 'tests' }
HyMpReturnTypeReportTest >> testProfilesByPackageAndByClass [

	| observations report byPackage byClass |
	observations := OrderedCollection new.
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #x
			 returns: SmallInteger).
	observations add: (self
			 makeObservation: Point
			 defines: Point
			 selector: #y
			 returns: SmallInteger).
	report := HyMpReturnTypeReport fromObservations: observations.
	byPackage := report profilesByPackage.
	byClass := report profilesByClass.
	self assert: (byPackage at: Point package name) size equals: 2.
	self assert: (byClass at: Point) size equals: 2
]
