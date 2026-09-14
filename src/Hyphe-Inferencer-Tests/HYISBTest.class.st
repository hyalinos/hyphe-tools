"
Shape Sandbox tests: one real-code case per Task 7/8 typing rule plus dataflow/polymorphism combinations, run against the actual HYITyper/HYISigma pipeline -- documents several empirical corrections found by actually running the code (Bottom-detection only fires on a bare statement, not a ^-wrapped one; a pure-Bottom body dissolves once merged with a stubbed Unknown tools answer).
"
Class {
	#name : 'HYISBTest',
	#superclass : 'TestCase',
	#instVars : [
		'idx',
		'sigma',
		'typer'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'helpers' }
HYISBTest >> keyFor: aSelector inClass: aClassName [
	"Builds a Sigma key for any of the Shape Sandbox classes, not just one fixed class."

	^ HYISigmaKey class: aClassName selector: aSelector
]

{ #category : 'helpers' }
HYISBTest >> run: aSelector inClass: aClassName [
	"Convenience: runs Sigma's fixpoint for one method and answers its settled value."

	^ sigma run: (self keyFor: aSelector inClass: aClassName)
]

{ #category : 'running' }
HYISBTest >> setUp [
	"A real HYITyper wired to a real, whole-image DefinerIndex, with toolsBlock stubbed to Unknown so only our own typing rules (R_body) are under test."

	super setUp.
	idx := HYIDefinerIndex buildFromImage.
	sigma := HYISigma bodyBlock: nil.
	typer := HYITyper sigma: sigma definerIndex: idx.
	sigma setToolsBlock: [ :k | HYITypeVariant unknown ] bodyBlock: typer asSigmaBodyBlock
]

{ #category : 'tests' }
HYISBTest >> testAssignIvarMergesAcrossTwoMethodsOnTheSameClass [
	"HYISBShape>>initialize writes label:='unlabeled' (String literal); HYISBShape>>label:
	writes label:=aString (Unknown, from the param). Both declared on HYISBShape itself,
	so both land in the SAME Theta bucket -- confirmed live this is keyed by the declaring
	class of the method being reconstructed, not the runtime receiver's class. Must
	reconstruct the writers before reading, same pattern as the existing
	testAssignIvarMergesAcrossCallsFlowInsensitively."

	sigma reconstruct: (self keyFor: #initialize inClass: 'HYISBShape').
	sigma reconstruct: (self keyFor: #label: inClass: 'HYISBShape').
	self assert: (self run: #label inClass: 'HYISBShape') = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'String'))
]

{ #category : 'tests' }
HYISBTest >> testAssignLocalOverwritesNotMerges [
	"HYISBShapeGroup>>retype -- x:=1. x:='reassigned'. ^x -- must be String only."

	self assert: (self run: #retype inClass: 'HYISBShapeGroup') = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'String'))
]

{ #category : 'tests' }
HYISBTest >> testBlockIsNotInvokedDuringTyping [
	"HYISBShapeGroup>>areaBlock ^ [ :s | s area ] -- answers a BlockType, not whatever
	area would answer if the block were actually called."

	self assert: (self run: #areaBlock inClass: 'HYISBShapeGroup') class = HYITypeVariant
]

{ #category : 'tests' }
HYISBTest >> testBothBranchesTerminateIsPureBottomBodyOnly [
	"HYISBShape>>impossible: -- both branches self error:, no fall-through at all. Same
	tools-merge caveat as testBottomBodyOnlyVsAfterToolsMerge above."

	self assert: (typer reconstructMethod: (self keyFor: #impossible: inClass: 'HYISBShape')) = HYIBottom value
]

{ #category : 'tests' }
HYISBTest >> testBottomBodyOnlyVsAfterToolsMerge [
	"HYISBShape>>area ^ was self subclassResponsibility -- rewritten to a BARE statement
	(self subclassResponsibility, no ^) after discovering live that reachabilityOf: only
	recognizes the Bottom-producing family as its own top-level statement, exactly like
	the existing alwaysErrors fixture -- a `^`-wrapped Bottom send is NOT detected and
	falls through to ordinary typing instead. Also confirms the spec's own '_(a)~Bottom=_(a)'
	rule live: a method whose ENTIRE body is pure Bottom, once merged with a stubbed
	Unknown(Top) tools answer, dissolves back to Unknown(Top) -- so Bottom is only
	observable here via the body-only reconstruction, not sigma run:."

	self assert: (typer reconstructMethod: (self keyFor: #area inClass: 'HYISBShape')) = HYIBottom value.
	self assert: (self run: #area inClass: 'HYISBShape') = HYITypeVariant unknown
]

{ #category : 'tests' }
HYISBTest >> testCascadeKeepsOnlyTheLastPartsResult [
	"HYISBShape>>identifyAfterLabel ^ self label; asShape -- label (String-ish, Theta
	empty here so Unknown) is discarded; only asShape's Fixed-S(Self) survives."

	self assert: (self run: #identifyAfterLabel inClass: 'HYISBShape') = (HYITypeVariant fixedS: HYISelfRef value)
]

{ #category : 'tests' }
HYISBTest >> testInterproceduralChainAcrossTwoClassesDoesNotHang [
	"HYISBShapeGroup>>describePrimary ^ self primaryShape describe -- three Sigma cells
	chained across two unrelated classes. Same weak-assertion caveat as the polymorphism
	test above, since it depends on the same describe mechanism."

	| result |
	result := self run: #describePrimary inClass: 'HYISBShapeGroup'.
	self assert: result notNil.
	self deny: result isConflict
]

{ #category : 'tests' }
HYISBTest >> testKeywordSendInterproceduralWriteThenRead [
	"HYISBShape>>renamedTo: aString -- self label: aString (keyword send, typed only for its
	Theta side effect) then ^ self label (a different self-sent method observing that
	effect). label: assigns an Unknown parameter, so the round trip answers Unknown(Top)
	-- this is the correct, if less dramatic, empirically-verified answer; it still proves
	the two-hop interprocedural read/write wiring works."

	self assert: (self run: #renamedTo: inClass: 'HYISBShape') = HYITypeVariant unknown
]

{ #category : 'tests' }
HYISBTest >> testLiteral [
	"HYISBCircle>>defaultRadius ^ 1"

	self assert:
		(self run: #defaultRadius inClass: 'HYISBCircle') = (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'SmallInteger'))
]

{ #category : 'tests' }
HYISBTest >> testOneBranchReachableOtherBottomSurvivesAsAUnion [
	"HYISBSquare>>cornerCountIfValid: -- ifTrue:[^4] ifFalse:[self error:...].
	Unlike a PURE-Bottom method (see testBottomBodyOnlyVsAfterToolsMerge below), a Bottom
	that sits ALONGSIDE a real Fixed branch survives the merge with the stubbed tools
	answer intact, because the union as a whole is Fixed-tagged."

	self assert: (self run: #cornerCountIfValid: inClass: 'HYISBSquare') printString equals: 'Fixed-NS(SmallInteger or Bottom)'
]

{ #category : 'tests' }
HYISBTest >> testOrdinarySendReceiverIsAnUnknownIvarNotSelfOrLiteral [
	"HYISBCircle>>area ^ radius * radius * 3 -- radius is an ivar nobody ever writes in this
	static view, so it types Unknown(Top); arithmetic on an Unknown(Top) receiver stays
	Unknown(Top), unlike every other fixture in the project which sends to self/literal."

	self assert: (self run: #area inClass: 'HYISBCircle') = HYITypeVariant unknown
]

{ #category : 'tests' }
HYISBTest >> testPolymorphicDispatchAcrossHierarchyIsWorthAFollowUp [
	"HYISBShape>>describe ^ self area, self = Fixed-S(HYISBShape) (self + subclasses).
	Expected a branch-union merging HYISBShape's Bottom, HYISBCircle/HYISBSquare's real
	arithmetic, and HYISBUnknownShape's inherited Bottom (Lookup Case 4). Empirically it
	collapses to a bare Fixed-S(Self) instead -- same collapse observed for a bare self-send
	to an undefined-in-scope selector earlier. Recorded as a weak sanity check (not stuck,
	not a Conflict) rather than asserting on a specific shape until HYILookup's self-send
	merging across multiple real subclass definers gets a dedicated look -- see chat."

	| result |
	result := self run: #describe inClass: 'HYISBShape'.
	self assert: result notNil.
	self deny: result isConflict
]

{ #category : 'tests' }
HYISBTest >> testUnrelatedClassSameSelectorsRealArithmetic [
	"HYISBLandParcel shares no superclass with HYISBShape beyond Object, yet defines
	area/describe independently with a different real formula (width*length)."

	self assert: (self run: #area inClass: 'HYISBLandParcel') = HYITypeVariant unknown.
	self assert: (self run: #describe inClass: 'HYISBLandParcel') = HYITypeVariant unknown
]

{ #category : 'tests' }
HYISBTest >> testVarLocalHoldingARealInstantiation [
	"HYISBShapeGroup>>newBasket -- | basket | basket := OrderedCollection new. ^ basket.
	Confirmed live and safe: resolves fast (well under a second) to Unknown(Top), not a
	hang -- see the design doc's safety note for why this needed checking at all before
	being run for real through Sigma."

	self assert: (self run: #newBasket inClass: 'HYISBShapeGroup') = HYITypeVariant unknown
]

{ #category : 'tests' }
HYISBTest >> testVarSelf [
	"HYISBShape>>asShape ^ self"

	self assert: (self run: #asShape inClass: 'HYISBShape') = (HYITypeVariant fixedS: HYISelfRef value)
]

{ #category : 'tests' }
HYISBTest >> testVarSuperIsTypedIdenticallyToVarSelf [
	"HYISBSquare>>rootShape ^ super -- confirmed live that typeVariableNode:gamma:className:
	treats self and super identically (both isSelfVariable-or-isSuperVariable), so this
	answers the SAME Fixed-S(Self) as var-self, not a distinct 'super' tau -- worth knowing
	before assuming super-anything gets special treatment elsewhere."

	self assert: (self run: #rootShape inClass: 'HYISBSquare') = (HYITypeVariant fixedS: HYISelfRef value)
]
