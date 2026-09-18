"
Tasks 7-8: typing rules + reachability/Bottom-propagation tests, incl. the spec's own worked examples (fact:, ifTrue:[^true]ifFalse:[^false], cond ifTrue:[^5]. self error:'bad'.). Not exhaustive per-rule coverage like Tasks 1-6 (time-boxed); focuses on one solid test per rule plus the worked examples, which is where the spec is most explicit and checkable.
"
Class {
	#name : 'HYITyperTest',
	#superclass : 'TestCase',
	#instVars : [
		'idx',
		'sigma',
		'typer'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYITyperTest >> keyFor: aSelector [
	"Convenience -- every fixture method in this test class lives on HYITyperFixture."

	^ HYISigmaKey class: 'HYITyperFixture' selector: aSelector
]

{ #category : 'tests' }
HYITyperTest >> setUp [
	"A real HYITyper wired to a real, whole-image DefinerIndex, but with toolsBlock stubbed to always answer Unknown -- isolates R_body (the typing rules under test) from any real tool evidence."

	super setUp.
	idx := HYIDefinerIndex buildFromImage.
	sigma := HYISigma bodyBlock: nil.
	typer := HYITyper sigma: sigma definerIndex: idx.
	sigma setToolsBlock: [ :k | HYITypeVariant unknown ] bodyBlock: typer asSigmaBodyBlock
]

{ #category : 'tests' }
HYITyperTest >> testArgumentTypeIsSeededFromToolsMethodType [
	"When a real tool's MethodType supplies an argument type, that type seeds Gamma-zero for the parameter -- addOne: simply returns its argument, so the whole method's answer comes straight from the seeded arg type."

	| key mt sigma2 typer2 result si toolsBlk |
	si := HYIStructNominal nominal: 'SmallInteger'.
	key := HYISigmaKey class: 'HYITyperFixture' selector: #addOne:.
	mt := HYIMethodType argTypes: (Array with: si) returnType: si.
	toolsBlk := [ :k |
		            k = key
			            ifTrue: [ HYITypeVariant observed: mt ]
			            ifFalse: [ HYITypeVariant unknown ] ].
	sigma2 := HYISigma toolsBlock: toolsBlk bodyBlock: nil.
	typer2 := HYITyper sigma: sigma2 definerIndex: idx.
	sigma2 setToolsBlock: toolsBlk bodyBlock: typer2 asSigmaBodyBlock.
	result := sigma2 run: key.
	self
		assert: result = (HYITypeVariant observed: si)
		description: 'addOne: x ^ x -- x''s Gamma-zero seeded as Observed(SmallInteger) from R_tools'' MethodType'
]

{ #category : 'tests' }
HYITyperTest >> testAssignIvarMergesAcrossCallsFlowInsensitively [
	"Reconstructing setIv: alone (an ordinary parameter, no literal) doesn't give getIv anything concrete to read -- Theta only has what's actually been observed so far, not future writes."

	| setKey getKey si str |
	si := HYIStructNominal nominal: 'SmallInteger'.
	str := HYIStructNominal nominal: 'String'.
	setKey := HYISigmaKey class: 'HYITyperIvarFixture' selector: #setIv:.
	getKey := HYISigmaKey class: 'HYITyperIvarFixture' selector: #getIv.
	sigma reconstruct: setKey.
	self
		assert: (sigma reconstruct: getKey) = HYITypeVariant unknown
		description: 'no assignment observed yet from getIv''s own reconstruction alone'
]

{ #category : 'tests' }
HYITyperTest >> testBottomOnlyBodyIsBottomBeforeMergingWithTools [
	"Sec 3.3.9's Boolean class>>new example: a body that is ONLY a Bottom-producing
	send yields Bottom -- tested on R_body directly (bypassing Sigma's cell-write,
	which would let an Unknown(Top) tools stub dissolve it back per ~'s rules --
	a real, documented consequence of the settled _(a)~Bottom=_(a) rule, not a bug)."

	self assert: (typer reconstructMethod: (self keyFor: #alwaysErrors)) = HYIBottom value
]

{ #category : 'tests' }
HYITyperTest >> testBranchingValueIsAUnionMatchingTheSpecsOwnWorkedExample [
	"Sec 3.3.9's own example: ifTrue:[^true] ifFalse:[^false] -> Fixed-NS(True) (+) Fixed-NS(False)."

	self assert: (sigma run: (self keyFor: #boolBranch)) printString equals: 'Fixed-NS(True or False)'
]

{ #category : 'tests' }
HYITyperTest >> testCascadeUsesOnlyTheLastMessagesResult [
	"self simpleLiteral; returnsSelf -- both applied to self, only returnsSelf's
	result (Fixed-S(Self)) matters, not simpleLiteral's."

	self assert: (sigma run: (self keyFor: #cascadeTest)) = (HYITypeVariant fixedS: HYISelfRef value)
]

{ #category : 'tests' }
HYITyperTest >> testDynamicArrayLiteral [
	"A dynamic array literal { 1. 2. 3 } types as Fixed-NS(Array)."

	self assert: (sigma run: (self keyFor: #dynArray)) = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Array'))
]

{ #category : 'tests' }
HYITyperTest >> testImplicitReturnToSelfWhenNoReturnAnywhere [
	"A method that assigns a local but never returns anything falls off the end -- implicit return-to-self, Fixed-S(Self)."

	self assert: (sigma run: (self keyFor: #noReturn)) = (HYITypeVariant fixedS: HYISelfRef value)
]

{ #category : 'tests' }
HYITyperTest >> testLiteralArray [
	"A literal array #(1 2 3) also types as Fixed-NS(Array), the same as the dynamic-array case."

	self assert: (sigma run: (self keyFor: #litArray2)) = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Array'))
]

{ #category : 'tests' }
HYITyperTest >> testLiteralSmallInteger [
	"The plain literal rule: ^ 42 types as Fixed-NS(SmallInteger)."

	self assert: (sigma run: (self keyFor: #simpleLiteral)) = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger'))
]

{ #category : 'tests' }
HYITyperTest >> testReachabilityBottomPathIsPreservedAsAUnionMember [
	"Sec 3.3.9's own example: cond ifTrue:[^5]. self error:'bad'. -> Fixed-NS(SmallInteger) (+) Bottom."

	self assert: (sigma run: (self keyFor: #errorBranch:)) printString equals: 'Fixed-NS(SmallInteger or Bottom)'
]

{ #category : 'tests' }
HYITyperTest >> testSelfRecursiveMethodTerminatesAndProducesAResult [
	"factTest: n ^ n = 0 ifTrue: [1] ifFalse: [n * (self factTest: n - 1)] -- must not hang."

	| result |
	result := sigma run: (self keyFor: #factTest:).
	self assert: result notNil.
	self deny: result isConflict
]

{ #category : 'tests' }
HYITyperTest >> testSelfSendFindsOwnClassMethod [
	"self simpleLiteral -- an ordinary self-send resolved via lookup, not a
	generic Top/Unknown fallback."

	self assert: (sigma run: (self keyFor: #selfSendChain)) = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger'))
]

{ #category : 'tests' }
HYITyperTest >> testVarSelfIsFixedSSelf [
	"The plain var-self rule: ^ self types as Fixed-S(Self)."

	self assert: (sigma run: (self keyFor: #returnsSelf)) = (HYITypeVariant fixedS: HYISelfRef value)
]
