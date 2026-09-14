"
Task 4: Sigma store tests. Done-when (TASKS.md): mutually recursive methods terminate and produce a result rather than looping; a cell whose tools' answer is Observed(X) and whose first-pass body answer is Unknown(Top) retains Observed(X); the fixpoint terminates on a package-sized input.
"
Class {
	#name : 'HYISigmaTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYISigmaTest >> testBodyBlockIsRecomputedOnLaterPasses [
	"R_body is genuinely recomputed each fixpoint pass (not cached like R_tools) -- this is how information propagates across passes for recursive groups."

	| key sigma bodyCalls |
	key := HYISigmaKey class: 'X' selector: #foo.
	bodyCalls := 0.
	sigma := HYISigma bodyBlock: [ :s :k |
			         bodyCalls := bodyCalls + 1.
			         s reconstruct: k ].
	sigma run: key.
	self assert: bodyCalls >= sigma passCount description: 'the body must be recomputed fresh on every pass that revisits the key'
]

{ #category : 'tests' }
HYISigmaTest >> testFixpointRespectsMaxPassesSafetyCapAndStillTerminates [
	"Not a real non-terminating case (widening guarantees termination) -- just checks
	the driver itself halts within maxPasses rather than looping forever."

	| key sigma |
	key := HYISigmaKey class: 'X' selector: #foo.
	sigma := HYISigma bodyBlock: [ :s :k | s reconstruct: k ].
	sigma run: key.
	self assert: sigma passCount <= HYISigma maxPasses
]

{ #category : 'tests' }
HYISigmaTest >> testFixpointTerminatesOnAPackageSizedRing [
	"A 60-key mutual-recursion ring (each key's body just asks for the next) terminates well before maxPasses and settles every key -- Task 4's Done-when, 'the fixpoint terminates on a package-sized input'."

	| n keys sigma result |
	n := 60.
	keys := (1 to: n) collect: [ :i | HYISigmaKey class: 'Ring' selector: ('k' , i printString) asSymbol ].
	sigma := HYISigma bodyBlock: [ :s :k |
			         | idx |
			         idx := keys indexOf: k.
			         s reconstruct: (keys at: idx \\ n + 1) ].
	result := sigma run: keys first.
	self assert: result notNil.
	self assert: sigma passCount < HYISigma maxPasses description: 'must converge before hitting the safety cap'.
	self assert: (keys allSatisfy: [ :k | sigma hasCellFor: k ])
]

{ #category : 'tests' }
HYISigmaTest >> testInProgressCellAnswersBottomUnconditionally [
	"Direct test of the settled Sec 4.1 rule, independent of any recursion shape."

	| key sigma capturedDuringComputation |
	key := HYISigmaKey class: 'X' selector: #foo.
	sigma := HYISigma bodyBlock: [ :s :k |
			         capturedDuringComputation := s reconstruct: k.
			         HYITypeVariant unknown ].
	sigma reconstruct: key.
	self assert: capturedDuringComputation = HYIBottom value
]

{ #category : 'tests' }
HYISigmaTest >> testMutuallyRecursiveMethodsTerminateAndProduceAResult [
	"Two keys that each ask for the other terminate with a real (non-Conflict) result for both, rather than looping forever or getting stuck at Bottom."

	| keyA keyB sigma resultA resultB |
	keyA := HYISigmaKey class: 'X' selector: #foo.
	keyB := HYISigmaKey class: 'X' selector: #bar.
	sigma := HYISigma bodyBlock: [ :s :k |
			         k = keyA
				         ifTrue: [ s reconstruct: keyB ]
				         ifFalse: [ s reconstruct: keyA ] ].
	resultA := sigma run: keyA.
	resultB := sigma cellAt: keyB.
	self assert: resultA notNil.
	self assert: resultB notNil.
	self deny: resultA isConflict.
	self deny: resultB isConflict
]

{ #category : 'tests' }
HYISigmaTest >> testObservedToolsWithUnknownBodyRetainsObserved [
	"Exact TASKS.md Task 4 Done-when wording."

	| key sigma si result |
	si := HYIStructNominal nominal: 'SmallInteger'.
	key := HYISigmaKey class: 'X' selector: #foo.
	sigma := HYISigma toolsBlock: [ :k | HYITypeVariant observed: si ] bodyBlock: [ :s :k | HYITypeVariant unknown ].
	result := sigma run: key.
	self assert: result = (HYITypeVariant observed: si)
]

{ #category : 'tests' }
HYISigmaTest >> testSelfRecursionTerminates [
	"A key that asks for itself (the degenerate one-member recursive group) terminates via the in-progress->Bottom guard rather than infinitely recursing."

	| key sigma result |
	key := HYISigmaKey class: 'X' selector: #fact.
	sigma := HYISigma bodyBlock: [ :s :k | s reconstruct: k ].
	result := sigma run: key.
	self assert: result notNil
]

{ #category : 'tests' }
HYISigmaTest >> testSigmaKeyEqualityAndPrinting [
	"Two independently-constructed but structurally identical keys are = and hash-consistent; a metaclass's key ('Foo class') is a genuinely different key from the instance side's, with no separate classSide field needed."

	| k1 k2 |
	k1 := HYISigmaKey class: 'Foo' selector: #bar.
	k2 := HYISigmaKey class: 'Foo' selector: #bar.
	self deny: k1 == k2.
	self assert: k1 = k2.
	self assert: k1 hash equals: k2 hash.
	self assert: k1 printString equals: 'Foo>>#bar'.
	self
		deny: k1 = (HYISigmaKey class: 'Foo class' selector: #bar)
		description: 'a metaclass is an ordinary class -- distinct key, no side field'
]

{ #category : 'tests' }
HYISigmaTest >> testToolsBlockIsCalledExactlyOnceEvenAcrossMultiplePasses [
	"R_tools is asked for at most once per key, ever, regardless of how many fixpoint passes revisit that key -- toolsCache, not recomputation, backs every later request."

	| key keyOther sigma toolCalls |
	key := HYISigmaKey class: 'X' selector: #foo.
	keyOther := HYISigmaKey class: 'X' selector: #bar.
	toolCalls := 0.
	sigma := HYISigma
		         toolsBlock: [ :k |
				         toolCalls := toolCalls + 1.
				         HYITypeVariant unknown ]
		         bodyBlock: [ :s :k |
				         k = key
					         ifTrue: [ s reconstruct: keyOther ]
					         ifFalse: [ s reconstruct: key ] ].
	sigma run: key.
	self assert: sigma passCount > 1 description: 'the scenario should genuinely take multiple passes to be a meaningful test'.
	self assert: toolCalls equals: 2
]

{ #category : 'tests' }
HYISigmaTest >> testWideningCollapsesAUnionOverTheWidthCap [
	"A union that has grown past widthCap (8) is forced down to Unknown(Top) by widen: -- Task 4's termination guarantee against unbounded growth across fixpoint passes."

	| result |
	result := (2 to: 9)
		          inject: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C1'))
		          into: [ :acc :i | acc branchUnion: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C' , i printString)) ].
	self assert: result entries first value members size equals: 9.
	self assert: (HYISigma new widen: result) = HYITypeVariant unknown
]

{ #category : 'tests' }
HYISigmaTest >> testWideningIsDrivenByTheSigmaCellWriteNotJustTheHelper [
	"An end-to-end scenario: a chain of keys whose tools keep contributing a new
	Observed type, so the accumulated union at the root must eventually widen."

	| n keys sigma result |
	n := 12.
	keys := (1 to: n) collect: [ :i | HYISigmaKey class: 'Chain' selector: ('k' , i printString) asSymbol ].
	sigma := HYISigma
		         toolsBlock: [ :k | HYITypeVariant observed: (HYIStructNominal nominal: 'T' , (keys indexOf: k) printString) ]
		         bodyBlock: [ :s :k |
				         | idx |
				         idx := keys indexOf: k.
				         idx = n
					         ifTrue: [ HYITypeVariant unknown ]
					         ifFalse: [ s reconstruct: (keys at: idx + 1) ] ].
	result := sigma run: keys first.
	self deny: result isConflict.
	self
		assert: (result = HYITypeVariant unknown or: [
					 result isTypeVariant and: [
						 result entries first value isUnion not or: [ result entries first value members size <= HYISigma widthCap ] ] ])
		description: 'result must either have widened to Unknown(Top) or stayed within the cap'
]

{ #category : 'tests' }
HYISigmaTest >> testWideningLeavesAUnionAtExactlyTheCapUnchanged [
	"A union exactly at widthCap (8 members) is left untouched -- widen: only fires strictly past the cap, not at it."

	| result |
	result := (2 to: 8)
		          inject: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C1'))
		          into: [ :acc :i | acc branchUnion: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C' , i printString)) ].
	self assert: result entries first value members size equals: 8.
	self assert: (HYISigma new widen: result) = result
]
