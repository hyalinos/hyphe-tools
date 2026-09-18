"
Merge Rule Matrix tests: verifies HYITypeResult's ~ operator fed by real, raw ARTI/ARTH/CTI answers (via HYIToolAdapter's own conversion utilities, not its buildForClass: accumulator) -- one test per reachable merge-table cell, including cells (Bottom as an operand) the accumulator itself can never produce.
"
Class {
	#name : 'HYIMMTest',
	#superclass : 'TestCase',
	#instVars : [
		'artiReports',
		'ctiInferers'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'helpers' }
HYIMMTest >> arthRawFor: aSelector [
	"ARTH's real, raw name-only answer -- needs no class or compiled method at all, since ARTH classifies purely by selector text."

	| classification tau |
	classification := ARTHClassifier classify: aSelector classSide: false.
	tau := HYIToolAdapter convertHTM: classification expectedType.
	^ HYIToolAdapter wrapConverted: tau realStability: HYIGuessed value
]

{ #category : 'helpers' }
HYIMMTest >> artiRawFor: aSelector inClass: aClassName [
	"ARTI's real, raw per-method answer -- Bottom bare, everything else wrapped Fixed-S/Fixed-NS -- exactly what HYIToolAdapter addARTIResultsFor:into: would merge in, but returned standalone instead of accumulated."

	| report match tau |
	report := self artiReportFor: aClassName.
	match := report results detect: [ :r | r selector = aSelector ] ifNone: [ ^ HYITypeVariant unknown ].
	tau := HYIToolAdapter convertHTM: match type.
	^ HYIToolAdapter wrapConverted: tau realStability: (HYIToolAdapter artiStabilityFor: tau)
]

{ #category : 'helpers' }
HYIMMTest >> artiReportFor: aClassName [
	"Caches ARTI's real report per class name, so the same class isn't re-analyzed for every selector queried against it."

	^ artiReports at: aClassName ifAbsentPut: [
			  | cls |
			  cls := Smalltalk at: aClassName asSymbol.
			  ARTIReturnTypeInferrer inferMethods: (cls selectors collect: [ :sel | cls >> sel ]) ]
]

{ #category : 'helpers' }
HYIMMTest >> ctiInfererFor: aClassName [
	"Caches CTI's real inferer per class name, so the same class isn't re-analyzed for every selector queried against it."

	^ ctiInferers at: aClassName ifAbsentPut: [ CTIInferer inferClass: (Smalltalk at: aClassName asSymbol) ]
]

{ #category : 'helpers' }
HYIMMTest >> ctiRawFor: aSelector inClass: aClassName [
	"CTI's real, raw per-method answer."

	| inf info tau |
	inf := self ctiInfererFor: aClassName.
	info := inf methodInfoFor: (Smalltalk at: aClassName asSymbol) selector: aSelector.
	tau := HYIToolAdapter convertHTM: (inf typeFor: info returnVar minBits).
	^ HYIToolAdapter wrapConverted: tau realStability: HYIObserved value
]

{ #category : 'helpers' }
HYIMMTest >> mergedFor: aSelector inClass: aClassName [
	"The same-method 3-way merge, in the same ARTI~ARTH~CTI order HYIToolAdapter buildForClass: uses."

	^ (self artiRawFor: aSelector inClass: aClassName) ~ (self arthRawFor: aSelector)
	  ~ (self ctiRawFor: aSelector inClass: aClassName)
]

{ #category : 'running' }
HYIMMTest >> setUp [
	"Fresh per-class caches for this test's real ARTI/CTI reports."

	super setUp.
	artiReports := Dictionary new.
	ctiInferers := Dictionary new
]

{ #category : 'tests' }
HYIMMTest >> testC1EveryoneAgrees [
	"HYIMMTicket>>title ^ 'untitled ticket' -- ARTI/ARTH/CTI all land on String (CTI: ByteString, a subtype)."

	self assert: (self mergedFor: #title inClass: 'HYIMMTicket') = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'String'))
]

{ #category : 'tests' }
HYIMMTest >> testC2WrongGuessIsIgnored [
	"HYIMMTicket>>isArchived -- `is` prefix guesses Boolean, but the real body returns a String. Guessed never even gets a subtype check against Fixed."

	self assert:
		(self mergedFor: #isArchived inClass: 'HYIMMTicket') = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'String'))
]

{ #category : 'tests' }
HYIMMTest >> testC3GuessMeetsAWideObservationIrreducibly [
	"HYIMMTicket>>priority ^ self computeUrgencyScore (^3+4) -- CTI can't narrow arithmetic past an 11-member Number-family Union, which is NOT `=` to the bare ClassRef(Number) ARTH guessed even though Number is one of its members -- so this is an irreducible 2-entry answer, not a clean confirm (corrected after checking live -- the original design doc predicted O(a)~G(a)->O(a))."

	self
		assert: (self mergedFor: #priority inClass: 'HYIMMTicket') printString
		equals:
		'Observed(BoxedFloat64 or Float or Fraction or Integer or LargeInteger or LargeNegativeInteger or LargePositiveInteger or Number or ScaledDecimal or SmallFloat64 or SmallInteger), Guessed(Number)'
]

{ #category : 'tests' }
HYIMMTest >> testC4GuessAndObservationFlatlyDisagree [
	"HYIMMTicket>>key ^ self internalNumericId (^42) -- key is a trusted String pattern, but the real value is a bare-literal SmallInteger CTI resolves exactly. Genuinely two-headed answer."

	self assert: (self mergedFor: #key inClass: 'HYIMMTicket') printString equals: 'Observed(SmallInteger), Guessed(String)'
]

{ #category : 'tests' }
HYIMMTest >> testC5EveryoneAgreesAgain [
	"HYIMMTicket>>defaultStatusName ^ 'open' -- matches the default[A-Z].*Name regex; CTI's earlier oddity (extra class in cornerCountIfValid:'s union) does NOT recur here, corrected after checking live (the original design doc speculated this might be a genuine Conflict)."

	self assert:
		(self mergedFor: #defaultStatusName inClass: 'HYIMMTicket') = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'String'))
]

{ #category : 'tests' }
HYIMMTest >> testC7GuessedAlone [
	"HYIMMTicket>>wantsNotification -- `wants` prefix guesses Boolean; the body (an infinitely self-recursive helper) gives neither ARTI nor CTI anything to say."

	self assert:
		(self mergedFor: #wantsNotification inClass: 'HYIMMTicket') = (HYITypeVariant guessed: (HYIStructNominal nominal: 'Boolean'))
]

{ #category : 'tests' }
HYIMMTest >> testC8ObservedAloneIsAUnion [
	"HYISBCircle>>area ^ radius * radius * 3 -- borrowed from Shape Sandbox: no naming pattern, no ARTI answer, CTI alone gives the same wide Number-family Union as testC3."

	self assert: (self mergedFor: #area inClass: 'HYISBCircle') class = HYITypeVariant.
	self assert: (self mergedFor: #area inClass: 'HYISBCircle') entries first key isObserved
]

{ #category : 'tests' }
HYIMMTest >> testC9NobodyKnowsAnything [
	"HYIMMTicket>>reconcileState -- matches no ARTH pattern; body is unclassifiable by both static tools."

	self assert: (self mergedFor: #reconcileState inClass: 'HYIMMTicket') = HYITypeVariant unknown
]

{ #category : 'tests' }
HYIMMTest >> testD1BottomDissolvesIntoGuessed [
	"Your original example: ARTI's real raw Bottom for the abstract HYISBShape>>area, merged directly against ARTH's real raw Guessed(String) for #title -- no accumulator, no shared key, just the ~ operator on two authentic tool outputs. _(a)~Bottom=_(a)."

	self assert: (self artiRawFor: #area inClass: 'HYISBShape') ~ (self arthRawFor: #title)
		= (HYITypeVariant guessed: (HYIStructNominal nominal: 'String'))
]

{ #category : 'tests' }
HYIMMTest >> testD2BottomDissolvesIntoObserved [
	"Same rule, the Observed side this time."

	self assert: (self artiRawFor: #area inClass: 'HYISBShape') ~ (self ctiRawFor: #internalNumericId inClass: 'HYIMMTicket')
		= (HYITypeVariant observed: (HYIStructNominal nominal: 'SmallInteger'))
]

{ #category : 'tests' }
HYIMMTest >> testD3EngineeredFixedSFixedNSConflict [
	"Two real ARTI answers about two DIFFERENT facts, deliberately pitted against each other -- the one row this project's real 3-tool setup can never produce naturally (only ARTI ever emits Fixed, one answer per method), reproduced here honestly as an engineered case, not a claim it happens in production."

	self
		assert: ((self artiRawFor: #asShape inClass: 'HYISBShape') ~ (self artiRawFor: #title inClass: 'HYIMMTicket')) printString
		equals: 'Conflict(Self, String)'
]

{ #category : 'tests' }
HYIMMTest >> testD4EngineeredFixedNSFixedNSConflict [
	"Two unrelated concrete Fixed-NS answers from two different real methods, same engineered caveat as D3."

	self
		assert:
		((self artiRawFor: #title inClass: 'HYIMMTicket') ~ (self artiRawFor: #defaultRadius inClass: 'HYISBCircle')) printString
		equals: 'Conflict(String, Integer)'
]

{ #category : 'tests' }
HYIMMTest >> testD5FixedSurvivesARealSubtypeObservation [
	"A genuine SmallInteger<:Integer pair from two real methods' real answers -- ARTI itself never naturally reports an abstract ancestor for one method's own literal, so this is engineered across methods rather than a single-method case."

	self assert:
		(self artiRawFor: #defaultRadius inClass: 'HYISBCircle') ~ (self ctiRawFor: #internalNumericId inClass: 'HYIMMTicket')
		= (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Integer'))
]
