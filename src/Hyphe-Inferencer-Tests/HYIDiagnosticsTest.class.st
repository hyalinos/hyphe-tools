"
Task 11 (scoped-down): the shared trace log records widening, pruning, tag-lowering and Conflict-receiver dissolution.
"
Class {
	#name : 'HYIDiagnosticsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYIDiagnosticsTest >> testConflictReceiverDissolutionIsLogged [
	"Looking up on a Conflict receiver leaves a trace entry recording that dissolution happened -- otherwise this would be invisible from the final answer alone."

	| idx lookup |
	HYIDiagnostics reset.
	idx := HYIDefinerIndex buildFromImage.
	lookup := HYILookup sigma: (HYISigma bodyBlock: [ :s :k | HYITypeVariant unknown ]) definerIndex: idx.
	lookup
		lookup:
		(HYIConflict left: (HYIStructNominal nominal: 'HYILookupFixtureRoot') right: (HYIStructNominal nominal: 'HYILookupFixtureOther'))
		selector: #value
		startClass: nil.
	self assert: (HYIDiagnostics trace anySatisfy: [ :l | l includesSubstring: 'dissolved' ])
]

{ #category : 'tests' }
HYIDiagnosticsTest >> testPruningIsLogged [
	"Merging against a Cand and pruning one of its hypotheses leaves a trace entry recording which evidence was pruned."

	HYIDiagnostics reset.
	HYITypeResult merge: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Bool')) with: (HYICand with: (Array
				  with: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'A'))
				  with: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'Bool')))).
	self assert: (HYIDiagnostics trace anySatisfy: [ :l | l includesSubstring: 'pruned' ])
]

{ #category : 'tests' }
HYIDiagnosticsTest >> testWideningIsLogged [
	"widen: forcing a too-wide union down to Unknown(Top) leaves a trace entry recording that it fired, and for which key."

	HYIDiagnostics reset.
	(2 to: 9)
		inject: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C1'))
		into: [ :acc :i | acc branchUnion: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C' , i printString)) ].
	HYISigma new
		widen: ((2 to: 9)
				 inject: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C1'))
				 into: [ :acc :i | acc branchUnion: (HYITypeVariant fixedNS: (HYIStructNominal nominal: 'C' , i printString)) ])
		for: (HYISigmaKey class: 'X' selector: #foo).
	self assert: HYIDiagnostics trace notEmpty.
	self assert: (HYIDiagnostics trace anySatisfy: [ :l | l includesSubstring: 'widened' ])
]
