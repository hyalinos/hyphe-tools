"
Task 12: ground-truth corpus + scoring, broken down by Stability tag per TASKS.md's Done-when. The ground-truth corpus is a small, hand-read real package (not synthetic fixtures) so the comparison in the final report is against actually-existing code; see the evaluation script for the corpus and how each ground-truth entry was determined.
"
Class {
	#name : 'HYIEvaluationHarness',
	#superclass : 'Object',
	#classInstVars : [
		'Runs'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'scoring' }
HYIEvaluationHarness class >> classifyResult: aTypeResult against: groundTruthClassName [
	"#noAnswer (Unknown(Top)), #conflict, #exact (payload's class name matches, or is 'Self' and the payload is Fixed-S(Self)), #consistent (ground truth is a subclass of the payload's class -- a correct but imprecise supertype), #wrong (anything else)."

	| tau |
	aTypeResult isConflict ifTrue: [ ^ #conflict ].
	aTypeResult isCand ifTrue: [ ^ #conflict ].
	(aTypeResult isTypeVariant and: [ aTypeResult isSingle ]) ifFalse: [ ^ #wrong ].
	tau := aTypeResult entries first value.
	tau isTop ifTrue: [ ^ #noAnswer ].
	tau isBottom ifTrue: [ ^ #wrong ].
	(groundTruthClassName = 'Self' and: [ tau isSelfRef ]) ifTrue: [ ^ #exact ].
	tau isSelfRef ifTrue: [ ^ #wrong ].
	tau isStructNominal ifFalse: [ ^ #wrong ].
	tau nominal = groundTruthClassName ifTrue: [ ^ #exact ].
	(HYIExpander resolveClassNamed: groundTruthClassName) ifNotNil: [ :gt |
		(HYIExpander resolveClassNamed: tau nominal) ifNotNil: [ :reported | (gt inheritsFrom: reported) ifTrue: [ ^ #consistent ] ] ].
	^ #wrong
]

{ #category : 'run history' }
HYIEvaluationHarness class >> clearRuns [
	"Discards the whole recorded-run history -- the live-image side of results storage (results-disk-and-memory-sync), not something evaluation itself calls."

	Runs := OrderedCollection new
]

{ #category : 'run history' }
HYIEvaluationHarness class >> latestRun [
	"Answers the most recently recorded HYIEvaluationRun, or nil if none has been recorded yet."

	^ self runs isEmpty
		  ifTrue: [ nil ]
		  ifFalse: [ self runs last ]
]

{ #category : 'run history' }
HYIEvaluationHarness class >> latestRunNamed: aLabel [
	"Answers the most recent run recorded under aLabel (searching newest-first), or nil if no run has that label."

	^ self runs reversed detect: [ :r | r label = aLabel ] ifNone: [ nil ]
]

{ #category : 'run history' }
HYIEvaluationHarness class >> recordRun: aHYIEvaluationRun [
	"Appends a completed run to the live-image history and answers it back, for chaining."

	self runs add: aHYIEvaluationRun.
	^ aHYIEvaluationRun
]

{ #category : 'runs' }
HYIEvaluationHarness class >> runs [
	"All recorded evaluation runs, oldest first -- live in the image, queryable on the fly without re-running the evaluation or reading a file back in."

	^ Runs ifNil: [ Runs := OrderedCollection new ]
]

{ #category : 'scoring' }
HYIEvaluationHarness class >> stabilityTierOf: aTypeResult [
	"Breaks a scored result down by which Stability tag produced it -- #conflict/#cand for those shapes, #other for anything not a single-entry TypeVariant, otherwise the tag's own class name as a Symbol (e.g. #HYIFixedNS)."

	aTypeResult isConflict ifTrue: [ ^ #conflict ].
	aTypeResult isCand ifTrue: [ ^ #cand ].
	(aTypeResult isTypeVariant and: [ aTypeResult isSingle ]) ifFalse: [ ^ #other ].
	^ aTypeResult entries first key class name asSymbol
]

{ #category : 'scoring' }
HYIEvaluationHarness class >> tally: aCollectionOfSymbols [
	"Counts classifyResult:against:'s five possible verdicts (#exact/#consistent/#wrong/#noAnswer/#conflict) across a collection of them, always including all five keys (zeroed) even if a verdict never occurred."

	| tally |
	tally := Dictionary new.
	#( #exact #consistent #wrong #noAnswer #conflict ) do: [ :k | tally at: k put: 0 ].
	aCollectionOfSymbols do: [ :s | tally at: s put: (tally at: s) + 1 ].
	^ tally
]
