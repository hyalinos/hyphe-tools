Class {
	#name : 'CTIEngineTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeConstraint-Tests',
	#package : 'Hyphe-ReturnTypeConstraint-Tests'
}

{ #category : 'tests' }
CTIEngineTest >> testBlockBranchesAreCurrentlyUnmodeled [
	"Known limitation: block literals carry no type information yet, so a
	conditional whose branches return different concrete types infers nothing
	rather than a union. This test documents the gap - when block support
	lands, this assertion should start failing and needs updating to expect
	#(#ByteString #SmallInteger)."

	| inf info |
	inf := CTIInferer inferClass: CTIDemoBranch.
	info := inf methodInfoFor: CTIDemoBranch selector: #pick:.
	self assert: (inf classNamesFor: info returnVar minBits) asArray isEmpty
]

{ #category : 'tests' }
CTIEngineTest >> testCSVExportHasRealLineBreaks [
	"Regression test: printCSVTo: must emit LF, not a bare CR - Stream>>cr
	writes x0D alone, which most CSV readers (and Unix line-counting tools)
	do not treat as a line break."

	| inf file lines |
	inf := CTIInferer inferClass: CTIDemoBox.
	file := FileLocator temp / 'cti-test-export.csv'.
	inf printCSVTo: file.
	lines := file contents lines.
	self assert: lines first equals: 'Package,Class,ClassSide,Selector,Type,MinCount'.
	self assert: lines size > 1.
	file ensureDelete
]

{ #category : 'tests' }
CTIEngineTest >> testImplementorIndexCreditsInheritedSelectors [
	"Regression test: buildImplementorIndex must count a class as an
	implementor of a selector it only inherits, not just selectors it
	ownredeclares - True/False inherit #storeOn: from Boolean/Object without
	overriding it, and must still show up as implementors."

	| u inf bits |
	u := CTIUniverse new.
	u buildFromImage.
	inf := CTIInferer new.
	inf universe: u.
	inf buildImplementorIndex.
	bits := inf implementorsOf: #storeOn:.
	self assert: (bits bitAnd: (u maskFor: True)) ~= 0.
	self assert: (bits bitAnd: (u maskFor: False)) ~= 0
]

{ #category : 'tests' }
CTIEngineTest >> testLiteralSeedsMinClass [

	| inf info |
	inf := CTIInferer inferClass: CTIDemoBox.
	info := inf methodInfoFor: CTIDemoBox selector: #fill.
	self assert: (inf classNamesFor: info returnVar minBits) asArray equals: #( #SmallInteger )
]

{ #category : 'tests' }
CTIEngineTest >> testNewPrimitiveSeedsConcreteClass [

	| inf info |
	inf := CTIInferer inferClass: CTIDemoBox.
	info := inf methodInfoFor: CTIDemoBox selector: #makeShape.
	self assert: (inf classNamesFor: info returnVar minBits) asArray equals: #( #CTIDemoShape )
]

{ #category : 'tests' }
CTIEngineTest >> testParameterPassingAndInstanceVariableChain [

	| inf info |
	inf := CTIInferer inferClass: CTIDemoBox.
	info := inf methodInfoFor: CTIDemoBox selector: #useShape.
	self assert: (inf classNamesFor: info returnVar minBits) asArray equals: #( #ByteString )
]

{ #category : 'tests' }
CTIEngineTest >> testUniverseIndexIsUniquePerClass [

	| u classes |
	u := CTIUniverse new.
	u buildFromImage.
	classes := Smalltalk allClasses.
	self assert: u size equals: classes size.
	self assert: (u maskFor: CTIDemoBox) ~= (u maskFor: CTIDemoShape)
]
