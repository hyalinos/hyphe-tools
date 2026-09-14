"
The single global context Sigma (Sec 3.3.1/3.3.2/3.4): one table, keyed by HYISigmaKey, values are tagged MethodType TypeResults. Filled lazily on demand. A cell under computation answers Bottom to any request that reaches it. A cell is written as R_body ~ R_tools with R_tools computed once (cached forever in toolsCache) and R_body recomputed fresh on every fixpoint pass; a union exceeding the width cap (pinned default N=8, AGENT_BRIEF.md) widens to Unknown(Top) (pinned default). toolsBlock/bodyBlock are caller-supplied strategies (1-arg: key; 2-arg: self,key respectively) -- real tool adapters (Task 9) and body reconstruction (Task 6/7/8) plug in here; this class only implements the store mechanics.
"
Class {
	#name : 'HYISigma',
	#superclass : 'Object',
	#instVars : [
		'cells',
		'inProgress',
		'toolsCache',
		'toolsBlock',
		'bodyBlock',
		'passCount'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYISigma class >> bodyBlock: aBodyBlock [
	"Convenience: no tools at all -- every cell's R_tools is Unknown(Top), which dissolves harmlessly against R_body (Sec 3.2.1's last row)."

	^ self toolsBlock: [ :key | HYITypeVariant unknown ] bodyBlock: aBodyBlock
]

{ #category : 'accessing' }
HYISigma class >> maxCells [
	"Safety budget (Task 4/5's whole-image fan-out risk): once cells has reached this many entries, computeCell: stops doing real work and answers Unknown(Top) for every further key -- found live to be necessary after a self-send fan-out into real, unstubbed kernel code hung the image; see the project's own incident notes."

	^ 3000
]

{ #category : 'configuration' }
HYISigma class >> maxPasses [
	"Lowered from 50 to 8 for the same reason as maxCells -- see its comment. 8 still comfortably covers every case measured so far (all converged in 2 passes; the synthetic 60-node ring test also converged well under 50)."

	^ 8
]

{ #category : 'instance creation' }
HYISigma class >> toolsBlock: aToolsBlock bodyBlock: aBodyBlock [
	"Constructor -- aToolsBlock answers R_tools for a key (e.g. via HYIToolAdapter, or a stub answering Unknown in tests); aBodyBlock answers R_body (normally HYITyper>>asSigmaBodyBlock)."

	^ self new
		  setToolsBlock: aToolsBlock bodyBlock: aBodyBlock;
		  yourself
]

{ #category : 'accessing' }
HYISigma class >> widthCap [
	"How many members a union may grow to before widen: forces it down to Unknown(Top) -- part of Task 4's termination guarantee: unions could otherwise grow without bound as merges accumulate across fixpoint passes."

	^ 8
]

{ #category : 'accessing' }
HYISigma >> cellAt: aKey [
	"Direct, non-computing peek at a cell -- answers nil if aKey has never been computed, unlike reconstruct:/run: which would compute it."

	^ cells at: aKey ifAbsent: [ nil ]
]

{ #category : 'reconstruction' }
HYISigma >> computeCell: aKey [
	"R_tools computed once per (C,sel) and cached forever (never updated afterwards, Sec 3.4); R_body recomputed fresh right here, every time this is called (each fixpoint pass that revisits aKey calls this again via recompute:). Cell write: R_body ~ R_tools, then widen. Past the maxCells safety budget, short-circuits to Unknown(Top) -- still CACHED (found live: leaving it uncached made run:'s final cells-at:-aKey crash whenever the very key requested was itself past the budget) -- see class>>maxCells' comment. R_tools is reconciled down to its return type before merging -- see returnTypeOnly:'s comment.

	The main body is wrapped defensively: an uncaught error partway through (a real-code edge case the typer doesn't handle) must not leave aKey stuck in inProgress forever -- that corrupts every future request for it. Degrades to Unknown(Top) instead."

	| rTools rBody merged result |
	cells size >= self class maxCells ifTrue: [ ^ cells at: aKey put: HYITypeVariant unknown ].
	inProgress add: aKey.
	^ [
		  [
			  rTools := toolsCache at: aKey ifAbsentPut: [ toolsBlock value: aKey ].
			  rBody := bodyBlock value: self value: aKey.
			  merged := rBody ~ (self returnTypeOnly: rTools).
			  (merged isConflict and: [ rBody isConflict not ]) ifTrue: [
				  HYIDiagnostics log: 'R_body ' , rBody printString , ' conflicted with R_tools ' , rTools printString for: aKey ].
			  result := self widen: merged for: aKey.
			  cells at: aKey put: result.
			  result ]
			  on: Error
			  do: [ :e |
					  HYIDiagnostics log: 'reconstruction error, degraded to Unknown(Top): ' , e messageText for: aKey.
					  result := HYITypeVariant unknown.
					  cells at: aKey put: result.
					  result ] ] ensure: [ inProgress remove: aKey ifAbsent: [ ] ]
]

{ #category : 'testing' }
HYISigma >> hasCellFor: aKey [
	"True if aKey already has a settled value in cells, without triggering any computation."

	^ cells includesKey: aKey
]

{ #category : 'accessing' }
HYISigma >> passCount [
	"How many fixpoint passes run: has executed so far."

	^ passCount
]

{ #category : 'reconstruction' }
HYISigma >> recompute: aKey [
	"Force a fresh R_body derivation for aKey even though a cell may already be cached from an earlier fixpoint pass -- this is how information propagates across passes for recursive groups (Sec 3.4): a sibling cycle member that is no longer in-progress now answers with its settled value instead of Bottom."

	^ self computeCell: aKey
]

{ #category : 'reconstruction' }
HYISigma >> reconstruct: aKey [
	"Sec 3.3.1/3.4's reconstruct(C,sel): if Sigma(C,sel) is present, return it (even a value settled by an earlier fixpoint pass). A request that reaches an in-progress cell answers Bottom (settled, Sec 4.1) -- unconditionally, checked BEFORE the cache, since a cell mid-computation cannot yet be 'present' in the settled sense. Otherwise compute it fresh."

	(inProgress includes: aKey) ifTrue: [ ^ HYIBottom value ].
	(cells includesKey: aKey) ifTrue: [ ^ cells at: aKey ].
	^ self computeCell: aKey
]

{ #category : 'reconstruction' }
HYISigma >> returnTypeOnly: aTypeResult [
	"A tool's R_tools may report a full MethodType (Sec 3.3.2), but the cell VALUE stored here is return-type-shaped throughout (R_body is always a bare return type -- see HYITyper>>reconstructMethod:'s comment). Reconciles the two shapes right before merging, so a real tool's argument-type information is used ONLY via toolsOnlyFor: (Gamma-zero seeding), never leaks into the stored cell. If unwrapping surfaces a bare Top return under a non-Unknown stability (a tool reporting args but genuinely no return-type opinion), that entry degrades to Unknown(Top) rather than raising -- Top can only ever legally pair with Unknown (Task 1's invariant)."

	| rebuildEntry entries hasRealEntry |
	rebuildEntry := [ :assoc |
		                | tau |
		                tau := assoc value isMethodType
			                       ifTrue: [ assoc value returnType ]
			                       ifFalse: [ assoc value ].
		                (tau isTop and: [ assoc key isUnknown not ])
			                ifTrue: [ HYIUnknown value -> HYITop value ]
			                ifFalse: [ assoc key -> tau ] ].
	aTypeResult isTypeVariant ifFalse: [ ^ aTypeResult ].
	entries := aTypeResult entries collect: rebuildEntry.
	entries size = 1 ifTrue: [ ^ HYITypeVariant tau: entries first value stability: entries first key ].
	hasRealEntry := entries anySatisfy: [ :e | e key isUnknown not ].
	hasRealEntry ifTrue: [ entries := entries reject: [ :e | e key isUnknown ] ].
	entries size = 1 ifTrue: [ ^ HYITypeVariant tau: entries first value stability: entries first key ].
	^ HYITypeVariant
		  tau: entries first value
		  stability: entries first key
		  tau: entries last value
		  stability: entries last key
]

{ #category : 'reconstruction' }
HYISigma >> run: aKey [
	"The fixpoint driver (Sec 3.4): reconstruct aKey (populating whatever it transitively touches), then repeatedly recompute every key seen so far, comparing successive Sigma snapshots, until identical (or the safety cap is hit). Answers Sigma(aKey) once stable."

	| previous stable keysThisPass |
	self reconstruct: aKey.
	passCount := 1.
	stable := false.
	[ stable or: [ passCount >= self class maxPasses ] ] whileFalse: [
			previous := cells copy.
			keysThisPass := cells keys asSortedCollection: [ :a :b | a printString <= b printString ].
			keysThisPass do: [ :k | self recompute: k ].
			passCount := passCount + 1.
			stable := cells = previous ].
	^ cells at: aKey
]

{ #category : 'private' }
HYISigma >> setToolsBlock: aToolsBlock bodyBlock: aBodyBlock [
	"Private initializer (also re-callable to rewire both blocks after construction) -- resets all of Sigma's state: cells, the in-progress cycle-guard set, the tools-answer cache, and the pass counter."

	toolsBlock := aToolsBlock.
	bodyBlock := aBodyBlock.
	cells := Dictionary new.
	inProgress := Set new.
	toolsCache := Dictionary new.
	passCount := 0
]

{ #category : 'accessing' }
HYISigma >> toolsCallCount [
	"How many distinct keys toolsBlock has actually been asked about -- since each answer is cached forever, this only grows, never shrinks."

	^ toolsCache size
]

{ #category : 'reconstruction' }
HYISigma >> toolsOnlyFor: aKey [
	"Sec 3.3.2's Gamma-zero for method arguments needs each argument's tool-reported type BEFORE the body is typed; R_tools is available before R_body by construction (computeCell: fetches it first), so a bodyBlock may ask for it directly rather than triggering a full reconstruct:."

	^ toolsCache at: aKey ifAbsentPut: [ toolsBlock value: aKey ]
]

{ #category : 'reconstruction' }
HYISigma >> widen: aTypeResult [
	"Sec 3.4: a union over more than N members (pinned default N=8) collapses -- pinned default: to Unknown(Top), not bare Top, so it dissolves harmlessly in a later ~ rather than competing with real evidence."

	aTypeResult isTypeVariant ifFalse: [ ^ aTypeResult ].
	(aTypeResult entries anySatisfy: [ :e | (self widthOf: e value) > self class widthCap ]) ifTrue: [ ^ HYITypeVariant unknown ].
	^ aTypeResult
]

{ #category : 'reconstruction' }
HYISigma >> widen: aTypeResult for: aKey [
	"Sec 3.4: a union over more than N members (pinned default N=8) collapses -- pinned default: to Unknown(Top), not bare Top, so it dissolves harmlessly in a later ~ rather than competing with real evidence. Logs to HYIDiagnostics (Task 11) when it actually fires."

	aTypeResult isTypeVariant ifFalse: [ ^ aTypeResult ].
	(aTypeResult entries anySatisfy: [ :e | (self widthOf: e value) > self class widthCap ]) ifTrue: [
			HYIDiagnostics
				log: 'widened ' , aTypeResult printString , ' (over ' , self class widthCap printString , ' members) to Unknown(Top)'
				for: aKey.
			^ HYITypeVariant unknown ].
	^ aTypeResult
]

{ #category : 'accessing' }
HYISigma >> widthOf: aTau [
	"How many members a tau's top-level union has (1 for a non-union tau) -- used by widen: to decide whether a union has grown past widthCap."

	aTau isUnion ifTrue: [ ^ aTau members size ].
	^ 1
]
