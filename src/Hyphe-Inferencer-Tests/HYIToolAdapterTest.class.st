"
Task 9: tool adapter tests, using the real ARTI/ARTH/CTI tools already in this image against HYITyperFixture.
"
Class {
	#name : 'HYIToolAdapterTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYIToolAdapterTest >> testARTHProducesGuessedOrUnknownNeverFixedOrObserved [
	"ARTH's real per-method answers, run through the adapter, are always tagged Guessed (or dissolve to Unknown) -- never Fixed or Observed, which belong to the other two tools."

	| dict |
	dict := Dictionary new.
	HYIToolAdapter addARTHResultsFor: HYITyperFixture into: dict.
	dict valuesDo: [ :r |
		r isTypeVariant ifTrue: [ self assert: (r entries allSatisfy: [ :e | e key isGuessed or: [ e key isUnknown ] ]) ] ]
]

{ #category : 'tests' }
HYIToolAdapterTest >> testARTIDetectsSelfAsFixedS [
	"ARTI's real answer for returnsSelf (^ self), converted by the adapter, comes out as genuine Fixed-S(Self) -- artiStabilityFor:'s Self-detection working on a real tool result, not a hand-built one."

	| dict result |
	dict := Dictionary new.
	HYIToolAdapter addARTIResultsFor: HYITyperFixture into: dict.
	result := dict at: (HYISigmaKey class: 'HYITyperFixture' selector: #returnsSelf).
	self assert: result = (HYITypeVariant fixedS: HYISelfRef value)
]

{ #category : 'tests' }
HYIToolAdapterTest >> testARTIProducesFixedResults [
	"ARTI's real answer for a dynamic array literal, converted by the adapter, comes out as genuine Fixed-NS(Array)."

	| dict |
	dict := Dictionary new.
	HYIToolAdapter addARTIResultsFor: HYITyperFixture into: dict.
	self assert: (dict at: (HYISigmaKey class: 'HYITyperFixture' selector: #dynArray)) entries first key isFixed.
	self assert: (dict at: (HYISigmaKey class: 'HYITyperFixture' selector: #dynArray))
		= (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Array'))
]

{ #category : 'tests' }
HYIToolAdapterTest >> testCTIProducesObservedOrUnknownNeverFixedOrGuessed [
	"CTI's real per-method answers, run through the adapter, are always tagged Observed (or dissolve to Unknown) -- never Fixed or Guessed."

	| dict |
	dict := Dictionary new.
	HYIToolAdapter addCTIResultsFor: HYITyperFixture into: dict.
	dict valuesDo: [ :r |
		r isTypeVariant ifTrue: [ self assert: (r entries allSatisfy: [ :e | e key isObserved or: [ e key isUnknown ] ]) ] ]
]

{ #category : 'tests' }
HYIToolAdapterTest >> testCombinedBuilderMergesAllThreeSourcesViaTilde [
	"buildForClass: really does merge all three tools' real answers together via ~, and ARTI's Fixed answer survives even when the other two tools have nothing to say about that same method."

	| dict |
	dict := HYIToolAdapter buildForClass: HYITyperFixture.
	self assert: dict notEmpty.
	self
		assert: (dict at: (HYISigmaKey class: 'HYITyperFixture' selector: #dynArray))
			= (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Array'))
		description: 'ARTI''s Fixed-NS(Array) should survive merging even where ARTH/CTI have no opinion'
]

{ #category : 'tests' }
HYIToolAdapterTest >> testEndToEndWiringRealToolsIntoSigma [
	"The full real pipeline, end to end: real ARTI/ARTH/CTI evidence wired as Sigma's toolsBlock, a real HYITyper as bodyBlock -- our own AST answer (SmallInteger) and ARTI's own answer (Integer) narrow together via the F-NS subtype rule rather than conflicting."

	| dict sigma typer idx result |
	idx := HYIDefinerIndex buildFromImage.
	dict := HYIToolAdapter buildForClass: HYITyperFixture.
	sigma := HYISigma bodyBlock: nil.
	typer := HYITyper sigma: sigma definerIndex: idx.
	sigma setToolsBlock: (HYIToolAdapter toolsBlockFor: dict) bodyBlock: typer asSigmaBodyBlock.
	result := sigma run: (HYISigmaKey class: 'HYITyperFixture' selector: #simpleLiteral).
	self deny: result isConflict.
	self
		assert: result entries first key isFixed
		description: 'reconstruction (Fixed-NS(SmallInteger)) and ARTI (Fixed-NS(Integer)) agree via the F-NS narrowing rule'
]
