"
Task 9: adapters from the tools living in this image (ASTInferencer=ARTI, ConstraintAnalysis/J2Inferer=CTI, NameHeuristics=ARTH per AGENT_BRIEF's mapping, plus RoelTyper and Offline Test Profiling -- both external tools this project does not own) into tagged HYI TypeResults usable as a HYISigma toolsBlock. RoelTyper and Offline Test Profiling answer with real Pharo Class/Metaclass objects rather than HTMType -- classToHTM: wraps those before they go through the same convertHTM: pipeline as ARTI/ARTH/CTI. Both are guarded (Smalltalk at:ifAbsent:) so this class compiles and simply contributes nothing from either if it is not loaded. RoelTyper is class-scoped like the other three tools and is included in buildForClass:; Offline Test Profiling is package-scoped (it runs a whole package's test suite as one unit) and lives in its own addOfflineProfilerResultsForPackage:into: entry point instead -- call that once per package, not from buildForClass:. LLM-based sources still have no counterpart in this image. Both known frictions from AGENT_BRIEF still apply: the tools report return types only (Sigma cells stay return-type-shaped throughout, Task 7/8's own decision, so this is not actually a mismatch here); a tool may report Foo where the truth is Foo class -- corrected here via each result's own classSide flag, not trusted blindly.
"
Class {
	#name : 'HYIToolAdapter',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'tool integration' }
HYIToolAdapter class >> addARTHResultsFor: aClass into: aDictionary [
	"Runs ARTH over aClass and merges (~) every result into aDictionary, keyed the same way Sigma is -- ARTH's report includes unmatched selectors too (Unknown), which just dissolve harmlessly on merge."

	| report |
	report := ARTHClassifier classifyClass: aClass.
	report results do: [ :m |
			| tau key result |
			tau := self convertHTM: m expectedType.
			key := self keyFor: m className classSide: m classSide selector: m selector.
			result := self wrapConverted: tau realStability: HYIGuessed value.
			self mergeInto: aDictionary key: key result: result ]
]

{ #category : 'tool integration' }
HYIToolAdapter class >> addARTIResultsFor: aClass into: aDictionary [
	"Runs ARTI over aClass and merges (~) every result into aDictionary -- a method ARTI itself excludes (primitive/empty) simply never gets an entry from this call."

	| report |
	report := ARTIReturnTypeInferrer inferClass: aClass.
	report results do: [ :m |
			| tau key result |
			tau := self convertHTM: m type.
			key := self keyFor: m className classSide: m classSide selector: m selector.
			result := self wrapConverted: tau realStability: (self artiStabilityFor: tau).
			self mergeInto: aDictionary key: key result: result ]
]

{ #category : 'cti' }
HYIToolAdapter class >> addCTIResultsFor: aClass into: aDictionary [
	"CTI is interprocedural: inferClass: pulls in its whole reachable universe. Only entries actually declared on aClass (or aClass class) are kept -- the rest are CTI's own working set, not results for our scope."

	| engine own |
	engine := CTIInferer inferClass: aClass.
	#( #false #true ) do: [ :ignored |  ].
	(Array with: aClass with: aClass class) do: [ :behavior |
			own := engine methodInfos at: behavior ifAbsent: [ nil ].
			own ifNotNil: [
					own keysAndValuesDo: [ :sel :info |
							| tau key result |
							tau := self convertHTM: (engine typeFor: info returnVar minBits).
							key := self keyFor: aClass name classSide: behavior isMeta selector: sel.
							result := self wrapConverted: tau realStability: HYIObserved value.
							self mergeInto: aDictionary key: key result: result ] ] ]
]

{ #category : 'as yet unclassified' }
HYIToolAdapter class >> addOfflineProfilerResultsForPackage: aPackageName into: aDictionary [
	"Runs Offline Test Profiling (HypheReturnsCollectorMethodNodes, Hyphe's own real
	 orchestrator's tool, not owned by this project either) over aPackageName's own test
	 suite once, and merges (~) every observed method's real runtime return class into
	 aDictionary. Deliberately package-scoped, unlike addARTIResultsFor:into:/
	 addARTHResultsFor:into:/addCTIResultsFor:into:/addRoelTyperResultsFor:into: -- this
	 tool instruments and runs a whole package's tests as one unit, so there is no
	 meaningful cheap way to scope it to a single class; call this once per package (e.g.
	 from a caller that knows it's about to build results for every class in a package),
	 not from buildForClass: (which would otherwise re-run the whole suite on every single
	 class it's asked about). Guarded via Smalltalk at:ifAbsent: so this compiles and
	 simply contributes nothing if Offline Test Profiling isn't loaded; the collector
	 itself already carries its own per-test timeout (runTestCase:selector:) so a single
	 hung test can't block this either."

	| collectorClass collector result |
	collectorClass := Smalltalk at: #HypheReturnsCollectorMethodNodes ifAbsent: [ ^ self ].
	collector := collectorClass new.
	result := [ collector processPackages: (Array with: aPackageName) ]
		          on: Error
		          do: [ :e | ^ self ].

	result collections do: [ :item |
			| tau key resultVariant classSide |
			[
				classSide := item receiverClass isKindOf: Metaclass.
				tau := self convertHTM: (self classToHTM: item returnClass).
				key := self
					       keyFor: (classSide
							        ifTrue: [ item receiverClass soleInstance name ]
							        ifFalse: [ item receiverClass name ])
					       classSide: classSide
					       selector: item methodSelector.
				resultVariant := self wrapConverted: tau realStability: HYIObserved value.
				self mergeInto: aDictionary key: key result: resultVariant ]
				on: Error
				do: [ :e |  ] ]
]

{ #category : 'as yet unclassified' }
HYIToolAdapter class >> addRoelTyperResultsFor: aClass into: aDictionary [
	"Runs RoelTyper (TypeCollector, an external tool from a different project) over aClass
	 and merges (~) every instance-side method's return type into aDictionary -- scope
	 matches Hyphe's own TypeCollector class>>runHypheInference:, instance-side only.
	 Guarded via Smalltalk at:ifAbsent: so this compiles and simply contributes nothing if
	 RoelTyper isn't loaded, and runs in its own forked process with a wall-clock budget
	 (externalToolTimeoutSeconds) so one heavily duck-typed class can't hang a whole Sigma
	 sweep -- RoelTyper's own interface search (rootsUnderstanding:) can still be slow on
	 such a class even after fixing the O(methods^2) re-extraction bug that used to make it
	 hang outright."

	| toolClass semaphore packaged timedOut worker |
	toolClass := Smalltalk at: #TypeCollector ifAbsent: [ ^ self ].
	semaphore := Semaphore new.
	packaged := nil.
	worker := [
		          [ packaged := toolClass typeInstvarsOfClass: aClass ]
			          on: Error
			          do: [ :e | packaged := nil ].
		          semaphore signal ] fork.
	timedOut := semaphore waitTimeoutSeconds: self externalToolTimeoutSeconds.
	timedOut ifTrue: [
			worker terminate.
			^ self ].
	packaged ifNil: [ ^ self ].

	aClass methods do: [ :compiledMethod |
			| extractedType classes tau key result |
			extractedType := packaged at: ('_' , compiledMethod selector , '>>^') asSymbol ifAbsent: [ nil ].
			extractedType ifNotNil: [
					classes := extractedType types.
					classes isEmpty ifFalse: [
							tau := self convertHTM: (HTMType union: (classes collect: [ :c | self classToHTM: c ])).
							key := self keyFor: aClass name classSide: false selector: compiledMethod selector.
							result := self wrapConverted: tau realStability: HYIObserved value.
							self mergeInto: aDictionary key: key result: result ] ] ]
]

{ #category : 'tool integration' }
HYIToolAdapter class >> artiStabilityFor: aTau [
	"ARTI's own Stability mapping: Fixed-S if the tau is (or is a union containing) Self, Fixed-NS for every other shape ARTI can produce -- classes, instances, literals, TypeVar, or Bottom (whose wrapping is decided separately by wrapConverted:realStability:, not here)."

	(aTau isSelfRef or: [ aTau isUnion and: [ aTau members anySatisfy: [ :m | m isSelfRef ] ] ]) ifTrue: [ ^ HYIFixedS value ].
	^ HYIFixedNS value
]

{ #category : 'as yet unclassified' }
HYIToolAdapter class >> buildForClass: aClass [
	"Convenience one-shot: asks ARTI, ARTH, CTI, and RoelTyper about every method of
	 aClass and merges their answers into one Dictionary, keyed by HYISigmaKey. Each
	 tool's failure is caught independently so one tool erroring doesn't blank out the
	 other three's evidence. Offline Test Profiling is NOT included here -- it's
	 package-scoped, not class-scoped (see addOfflineProfilerResultsForPackage:into:'s own
	 comment for why); call that separately, once per package, if you want its evidence
	 too. NOTE: this always starts each key from HYITypeVariant unknown, so a tool's bare
	 Bottom answer never survives here even when it's the only real evidence -- see the
	 Merge Rule Matrix notes for why that's specific to this accumulation, not to ~
	 itself."

	| dict |
	dict := Dictionary new.
	[ self addARTIResultsFor: aClass into: dict ]
		on: Error
		do: [ :e |  ].
	[ self addARTHResultsFor: aClass into: dict ]
		on: Error
		do: [ :e |  ].
	[ self addCTIResultsFor: aClass into: dict ]
		on: Error
		do: [ :e |  ].
	[ self addRoelTyperResultsFor: aClass into: dict ]
		on: Error
		do: [ :e |  ].
	^ dict
]

{ #category : 'converting' }
HYIToolAdapter class >> classToHTM: aClassOrMetaclass [
	"Wrap a raw Pharo Class/Metaclass -- RoelTyper's and Offline Test Profiling's own
	 native answer shape, neither tool knows about Hyphe-TypeModel -- as the matching
	 HTMType, so their evidence can go through the same convertHTM: pipeline ARTI/ARTH/CTI
	 already use."

	(aClassOrMetaclass isKindOf: Metaclass) ifTrue: [ ^ HTMType metaclass: aClassOrMetaclass soleInstance name asSymbol ].
	^ HTMType classRef: aClassOrMetaclass name asSymbol
]

{ #category : 'conversion' }
HYIToolAdapter class >> convertHTM: anHTMType [
	"Hyphe-TypeModel -> this tool's tau grammar (Sec 2.2). HTMTypeVar maps to Top per the pinned default (TypeVar/apply not implemented). HTMUnknown maps to bare Top -- callers decide the wrapping Stability (always Unknown when the tau is Top, per Task 1's invariant)."

	(anHTMType isKindOf: HTMBottom) ifTrue: [ ^ HYIBottom value ].
	(anHTMType isKindOf: HTMUnknown) ifTrue: [ ^ HYITop value ].
	(anHTMType isKindOf: HTMSelf) ifTrue: [ ^ HYISelfRef value ].
	(anHTMType isKindOf: HTMSelfClass) ifTrue: [ ^ HYISelfClassRef value ].
	(anHTMType isKindOf: HTMTypeVar) ifTrue: [ ^ HYITop value ].
	(anHTMType isKindOf: HTMMetaclass) ifTrue: [ ^ HYIStructNominal nominal: anHTMType className asString , ' class' ].
	(anHTMType isKindOf: HTMClassRef) ifTrue: [ ^ HYIStructNominal nominal: anHTMType className asString ].
	(anHTMType isKindOf: HTMUnion) ifTrue: [ ^ HYIUnion fromMembers: (anHTMType types collect: [ :t | self convertHTM: t ]) ].
	^ HYITop value
]

{ #category : 'converting' }
HYIToolAdapter class >> externalToolTimeoutSeconds [
	"Wall-clock budget for one call into an external tool (RoelTyper, Offline Test
	 Profiling) that this adapter doesn't control the internals of. Mirrors the same
	 defense-in-depth added to those tools' own Hyphe integration
	 (TypeCollector class>>maxSecondsPerClass,
	 HypheReturnsCollectorMethodNodes>>maxSecondsPerTest) -- kept as this adapter's own
	 constant rather than reading theirs, so this doesn't assume a particular version of
	 either external tool's own API."

	^ 20
]

{ #category : 'tool integration' }
HYIToolAdapter class >> keyFor: aClassName classSide: isClassSide selector: aSelector [
	"Builds the same HYISigmaKey shape Sigma itself uses -- folding ' class' into the class-name string for a class-side method, so tool evidence and Sigma's own cells key identically."

	^ HYISigmaKey
		  class: (isClassSide
				   ifTrue: [ aClassName asString , ' class' ]
				   ifFalse: [ aClassName asString ])
		  selector: aSelector
]

{ #category : 'tool integration' }
HYIToolAdapter class >> mergeInto: aDictionary key: aKey result: aResult [
	"Folds one more piece of tool evidence into aDictionary via ~, starting from Unknown the first time a key is seen."

	aDictionary at: aKey put: (aDictionary at: aKey ifAbsent: [ HYITypeVariant unknown ]) ~ aResult
]

{ #category : 'tool integration' }
HYIToolAdapter class >> toolsBlockFor: aDictionary [
	"Wraps a pre-built (e.g. via buildForClass:) evidence Dictionary as a Sigma-compatible toolsBlock -- answers Unknown for any key the dictionary doesn't have an entry for."

	^ [ :key | aDictionary at: key ifAbsent: [ HYITypeVariant unknown ] ]
]

{ #category : 'conversion' }
HYIToolAdapter class >> wrapConverted: aTau realStability: aStability [
	"Uniform rule across all three adapters: a Top payload is ALWAYS wrapped Unknown (Task 1's invariant -- a tool's own confidence label is moot once the payload itself carries no information), a Bottom payload is ALWAYS bare (never tagged); only a real, concrete payload gets the tool's own designated Stability."

	aTau isTop ifTrue: [ ^ HYITypeVariant unknown ].
	aTau isBottom ifTrue: [ ^ HYIBottom value ].
	^ HYITypeVariant tau: aTau stability: aStability
]
