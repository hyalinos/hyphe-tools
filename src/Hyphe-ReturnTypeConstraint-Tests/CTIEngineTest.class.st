Class {
	#name : 'CTIEngineTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeConstraint-Tests',
	#package : 'Hyphe-ReturnTypeConstraint-Tests'
}

{ #category : 'tests' }
CTIEngineTest >> testBasicNewHeuristicCanBeDisabled [

	| u inf cfg info |
	u := CTIUniverse new.
	u buildFromImage.
	cfg := CTIConfig new.
	cfg basicNewHeuristic: false.
	inf := CTIInferer new.
	inf universe: u.
	inf config: cfg.
	inf run: (OrderedCollection with: CTIDemoBox -> #makeShape).
	info := inf methodInfoFor: CTIDemoBox selector: #makeShape.
	self assert: (inf classNamesFor: info returnVar minBits) asArray isEmpty
]

{ #category : 'tests' }
CTIEngineTest >> testBlockBranchesProduceUnion [
	"Was testBlockBranchesAreCurrentlyUnmodeled: block support (composite
	type variable + value-send resolution in drainLinkQueue) now wires both
	branches of a conditional into a real union, as long as call sites
	provide evidence for both receiver classes - here callPick/callPick2
	call pick: with true and false respectively."

	| inf info |
	inf := CTIInferer inferClass: CTIDemoBranch.
	info := inf methodInfoFor: CTIDemoBranch selector: #pick:.
	self assert: (inf classNamesFor: info returnVar minBits) asArray equals: #( #ByteString #SmallInteger )
]

{ #category : 'tests' }
CTIEngineTest >> testBlockEvaluationHeuristicCanBeDisabled [

	| u inf cfg seeds info |
	u := CTIUniverse new.
	u buildFromImage.
	cfg := CTIConfig new.
	cfg blockEvaluationHeuristic: false.
	inf := CTIInferer new.
	inf universe: u.
	inf config: cfg.
	seeds := OrderedCollection new.
	CTIDemoBranch selectors do: [ :s | seeds add: CTIDemoBranch -> s ].
	inf run: seeds.
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
	self assert: lines first equals: 'Package,Class,ClassSide,Selector,Type'.
	self assert: lines size > 1.
	file ensureDelete
]

{ #category : 'tests' }
CTIEngineTest >> testConfigurationPresenterDirtyTracking [

	| p |
	p := CTIConfigurationPresenter new.
	self deny: p isDirty.
	p basicNewCheck state: false.
	self assert: p isDirty.
	p doSave.
	self deny: p isDirty.
	p basicNewCheck state: true.
	self assert: p isDirty.
	p doCancel.
	self deny: p isDirty.
	self deny: p basicNewCheck state "reverted to the saved value, which was false"
]

{ #category : 'tests' }
CTIEngineTest >> testHeuristicsDefaultToEnabled [

	| cfg |
	cfg := CTIConfig new.
	cfg allHeuristicNames do: [ :sel | self assert: (cfg perform: sel) ]
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
CTIEngineTest >> testTypeForUsesSharedTypeModel [

	| inf info |
	inf := CTIInferer inferClass: CTIDemoBranch.
	info := inf methodInfoFor: CTIDemoBranch selector: #pick:.
	self assert: (inf typeFor: info returnVar minBits) printString equals: (HTMType union: {
				 (HTMType classRef: #ByteString).
				 (HTMType classRef: #SmallInteger) }) printString
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
