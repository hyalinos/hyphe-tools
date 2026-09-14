"
Task 6: Lookup tests. Done-when (TASKS.md): a self-send, a super-send, a send on a known class, a send on a union of observed classes, a send on Unknown(Top) and a send on a Conflict receiver each produce the shape the specification prescribes; a send whose receiver is Observed never produces a Fixed result. Uses HYILookupFixtureRoot/Child/Other (real classes, so expand()/AllDefiners has something real to walk) with a STUBBED Sigma (Task 6 tests navigation/weakening, not Task 7/8's body-typing).
"
Class {
	#name : 'HYILookupTest',
	#superclass : 'TestCase',
	#instVars : [
		'idx',
		'sigma',
		'lookup',
		'si',
		'bool',
		'str'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYILookupTest >> setUp [
	"A stubbed Sigma whose bodyBlock answers canned, per-(class,selector) results for the real Lookup fixture classes -- Lookup is what's under test here, not the typer."

	super setUp.
	idx := HYIDefinerIndex buildFromImage.
	si := HYIStructNominal nominal: 'SmallInteger'.
	bool := HYIStructNominal nominal: 'Boolean'.
	str := HYIStructNominal nominal: 'String'.
	sigma := HYISigma bodyBlock: [ :s :k |
			         | cn sel |
			         cn := k className.
			         sel := k selector.
			         (cn = 'HYILookupFixtureRoot' and: [ sel = #value ])
				         ifTrue: [ HYITypeVariant fixedNS: si ]
				         ifFalse: [
						         (cn = 'HYILookupFixtureChild' and: [ sel = #value ])
							         ifTrue: [ HYITypeVariant fixedNS: bool ]
							         ifFalse: [
									         (cn = 'HYILookupFixtureOther' and: [ sel = #value ])
										         ifTrue: [ HYITypeVariant fixedNS: str ]
										         ifFalse: [
												         (cn = 'HYILookupFixtureRoot' and: [ sel = #whoAmI ])
													         ifTrue: [ HYITypeVariant fixedS: HYISelfRef value ]
													         ifFalse: [
															         sel = #hyiFixtureMarker
																         ifTrue: [ HYITypeVariant fixedNS: (HYIStructNominal nominal: cn) ]
																         ifFalse: [ HYITypeVariant unknown ] ] ] ] ] ].
	lookup := HYILookup sigma: sigma definerIndex: idx
]

{ #category : 'tests' }
HYILookupTest >> testBottomReceiverShortCircuitsToBottom [
	"A Bottom receiver (an unreachable expression) short-circuits Lookup to Bottom without attempting any real class resolution."

	self assert: (lookup lookup: HYIBottom value selector: #value startClass: nil) = HYIBottom value
]

{ #category : 'tests' }
HYILookupTest >> testCandidateClassesFiltersNonNominalMembers [
	"A receiver tau that mixes a nominal class with Bottom (e.g. from an earlier (+))
	must still find the real class and ignore the non-nominal member."

	| receiver result |
	receiver := HYITypeVariant fixedNS: (HYIUnion left: (HYIStructNominal nominal: 'HYILookupFixtureRoot') right: HYIBottom value).
	result := lookup lookup: receiver selector: #value startClass: nil.
	self assert: result = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYILookupTest >> testConflictReceiverProducesCandOfBothSidesIndependently [
	"A Conflict receiver dissolves into a Cand of the lookup performed independently on each of the two conflicting sides."

	| receiver result |
	receiver := HYIConflict
		            left: (HYIStructNominal nominal: 'HYILookupFixtureRoot')
		            right: (HYIStructNominal nominal: 'HYILookupFixtureOther').
	result := lookup lookup: receiver selector: #value startClass: nil.
	self assert: result isCand.
	self
		assert: result hypotheses asSet
		equals: (Set withAll: (Array with: (HYITypeVariant fixedNS: si) with: (HYITypeVariant fixedNS: str)))
]

{ #category : 'tests' }
HYILookupTest >> testKnownSingleClassReceiverIsDirectNotCandWrapped [
	"Case 3 (a send on a known single class): the answer comes back directly, never wrapped in a trivial one-hypothesis Cand."

	| result |
	result := lookup
		          lookup: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'HYILookupFixtureRoot'))
		          selector: #value
		          startClass: nil.
	self deny: result isCand.
	self assert: result = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYILookupTest >> testLookupNeverYieldsConflictItself [
	"Lookup collects candidates (Cand), it never merges them with ~ -- so lookup
	itself must never manufacture a fresh Conflict (an INPUT Conflict receiver
	is handled by Case 4 and dissolves into a Cand of its members)."

	| receiver result |
	receiver := HYIConflict
		            left: (HYIStructNominal nominal: 'HYILookupFixtureRoot')
		            right: (HYIStructNominal nominal: 'HYILookupFixtureOther').
	result := lookup lookup: receiver selector: #value startClass: nil.
	self deny: result isConflict
]

{ #category : 'tests' }
HYILookupTest >> testObservedReceiverNeverProducesAFixedResult [
	"Exact TASKS.md Task 6 Done-when wording."

	| receiver result |
	receiver := HYITypeVariant observed: (HYIStructNominal nominal: 'HYILookupFixtureRoot').
	result := lookup lookup: receiver selector: #value startClass: nil.
	self assert: result isTypeVariant.
	self deny: (result entries anySatisfy: [ :e | e key isFixed ])
]

{ #category : 'tests' }
HYILookupTest >> testSelfReceiverWithoutStartClassRaises [
	"A self-send (Fixed-S(Self) receiver) requires a startClass to resolve substSelf against -- omitting it is a programming error, not something Lookup silently guesses around."

	self should: [ lookup lookup: (HYITypeVariant fixedS: HYISelfRef value) selector: #value startClass: nil ] raise: Error
]

{ #category : 'tests' }
HYILookupTest >> testSelfSendFindsOwnOverride [
	"Case 1 (self-send): starting from HYILookupFixtureChild finds ITS OWN override of value, not Root's."

	| result |
	result := lookup lookup: (HYITypeVariant fixedS: HYISelfRef value) selector: #value startClass: 'HYILookupFixtureChild'.
	self assert: result = (HYITypeVariant fixedNS: bool)
]

{ #category : 'tests' }
HYILookupTest >> testSelfSendPropagatesUnresolvedSelfWhenBodyReturnsSelf [
	"target(R_a) = Self for a self/super receiver -- substSelf is a genuine no-op,
	so an unresolved Self stays Self rather than being collapsed to a concrete class."

	| result |
	result := lookup lookup: (HYITypeVariant fixedS: HYISelfRef value) selector: #whoAmI startClass: 'HYILookupFixtureRoot'.
	self assert: result = (HYITypeVariant fixedS: HYISelfRef value)
]

{ #category : 'tests' }
HYILookupTest >> testSelfSendWithNoDefinerAnywhereFallsBackToUnknown [
	"A self-send to a selector nothing in the image defines degrades gracefully to Unknown, rather than erroring."

	| result |
	result := lookup
		          lookup: (HYITypeVariant fixedS: HYISelfRef value)
		          selector: #thisSelectorSurelyDoesNotExist123
		          startClass: 'HYILookupFixtureRoot'.
	self assert: result = HYITypeVariant unknown
]

{ #category : 'tests' }
HYILookupTest >> testSuperSendSkipsOwnOverrideAndFindsAncestor [
	"Direction matters: from a super-send inside Child, startClass = superclass(Child) = Root,
	so Child's own override of #value must be skipped."

	| result |
	result := lookup lookup: (HYITypeVariant fixedS: HYISelfRef value) selector: #value startClass: 'HYILookupFixtureRoot'.
	self assert: result = (HYITypeVariant fixedNS: si)
]

{ #category : 'tests' }
HYILookupTest >> testUnionOfObservedClassesProducesCandOfWeakenedEntries [
	"Case 4 (union of observed classes): a send whose receiver is Observed never produces a Fixed result -- each branch's answer is weakened (min-tag) down to Observed even though the underlying lookup found a Fixed one."

	| receiver result |
	receiver := HYITypeVariant observed:
		            (HYIUnion
			             left: (HYIStructNominal nominal: 'HYILookupFixtureRoot')
			             right: (HYIStructNominal nominal: 'HYILookupFixtureOther')).
	result := lookup lookup: receiver selector: #value startClass: nil.
	self assert: result isCand.
	self
		assert: result hypotheses asSet
		equals: (Set withAll: (Array with: (HYITypeVariant observed: si) with: (HYITypeVariant observed: str)))
]

{ #category : 'tests' }
HYILookupTest >> testUnknownReceiverWithFewDefinersProducesRealCandOverAllDefiners [
	"An Unknown(Top) receiver with only a few real AllDefiners for the selector produces a genuine Cand over every one of them -- a real 'could be any of these classes' hypothesis set, not a forced Unknown."

	| result expected |
	result := lookup lookup: HYITypeVariant unknown selector: #hyiFixtureMarker startClass: nil.
	self assert: result isCand.
	expected := Set withAll: (Array
			             with: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'HYILookupFixtureRoot'))
			             with: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'HYILookupFixtureChild'))
			             with: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'HYILookupFixtureOther'))).
	self assert: result hypotheses asSet equals: expected
]

{ #category : 'tests' }
HYILookupTest >> testUnknownReceiverWithTooManyDefinersCollapsesToUnknownTop [
	"#value has well over 100 real definers image-wide -- exceeds the width cap (8)."

	| result |
	self assert: (idx allDefiners: #value) size > HYISigma widthCap.
	result := lookup lookup: HYITypeVariant unknown selector: #value startClass: nil.
	self assert: result = HYITypeVariant unknown
]
