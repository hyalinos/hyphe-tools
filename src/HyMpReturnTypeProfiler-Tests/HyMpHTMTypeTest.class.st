Class {
	#name : 'HyMpHTMTypeTest',
	#superclass : 'TestCase',
	#category : 'HyMpReturnTypeProfiler-Tests',
	#package : 'HyMpReturnTypeProfiler-Tests'
}

{ #category : 'tests' }
HyMpHTMTypeTest >> testEmptyProfileProducesUnknown [

	| profile |
	profile := HyMpMethodProfile definingClass: Object selector: #neverCalled.
	self assert: profile hypheType equals: HTMType unknown
]

{ #category : 'tests' }
HyMpHTMTypeTest >> testMonomorphicProfileProducesPlainClassRef [

	| profile |
	profile := HyMpMethodProfile definingClass: Object selector: #foo.
	profile recordReturnClass: SmallInteger.
	profile recordReturnClass: SmallInteger.
	self assert: profile hypheType equals: (HTMType classRef: #SmallInteger)
]

{ #category : 'tests' }
HyMpHTMTypeTest >> testObservedClassReturnValueBecomesMetaclassNotBogusClassRef [

	| profile |
	profile := HyMpMethodProfile definingClass: Object selector: #classSideReturner.
	profile recordReturnClass: Integer class.
	self assert: profile hypheType equals: (HTMType metaclass: #Integer)
]

{ #category : 'tests' }
HyMpHTMTypeTest >> testPolymorphicProfileProducesUnionOfAllObservedClasses [

	| profile result |
	profile := HyMpMethodProfile definingClass: Object selector: #bar.
	profile recordReturnClass: SmallInteger.
	profile recordReturnClass: String.
	profile recordReturnClass: UndefinedObject.
	result := profile hypheType.
	self assert: result isUnion.
	self
		assert: result members asSet
		equals:
		(Set with: (HTMType classRef: #SmallInteger) with: (HTMType classRef: #String) with: (HTMType classRef: #UndefinedObject))
]

{ #category : 'tests' }
HyMpHTMTypeTest >> testRepeatedSameClassObservationStaysMonomorphicNotUnion [

	| profile |
	profile := HyMpMethodProfile definingClass: Object selector: #foo.
	10 timesRepeat: [ profile recordReturnClass: SmallInteger ].
	self deny: profile hypheType isUnion.
	self assert: profile hypheType equals: (HTMType classRef: #SmallInteger)
]

{ #category : 'tests' }
HyMpHTMTypeTest >> testReportHypheTypeCoversEveryProfiledMethod [

	| report keys |
	report := HyMpReturnTypeReport new.
	report recordObservation: (HyMpObservation new
			 receiverClass: Object
			 definingClass: Object
			 selector: #foo
			 returnClass: SmallInteger).
	report recordObservation: (HyMpObservation new
			 receiverClass: Object
			 definingClass: Object
			 selector: #bar
			 returnClass: String).
	keys := report hypheType keys collect: [ :assoc | assoc value ].
	self assert: keys asSet equals: (Set with: #foo with: #bar)
]

{ #category : 'tests' }
HyMpHTMTypeTest >> testReportHypheTypeForDelegatesToProfile [

	| report |
	report := HyMpReturnTypeReport new.
	report recordObservation: (HyMpObservation new
			 receiverClass: Object
			 definingClass: Object
			 selector: #foo
			 returnClass: SmallInteger).
	report recordObservation: (HyMpObservation new
			 receiverClass: Object
			 definingClass: Object
			 selector: #foo
			 returnClass: String).
	self assert: (report hypheTypeFor: Object selector: #foo) equals: (HTMType union: {
				 (HTMType classRef: #SmallInteger).
				 (HTMType classRef: #String) })
]
