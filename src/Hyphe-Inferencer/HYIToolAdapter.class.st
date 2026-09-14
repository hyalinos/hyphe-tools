"
Task 9: adapters from the three tools already living in this image (ASTInferencer=ARTI, ConstraintAnalysis/J2Inferer=CTI, NameHeuristics=ARTH per AGENT_BRIEF's mapping) into tagged HYI TypeResults usable as a HYISigma toolsBlock. RoelTyper/OfflineProfiler/LLM-based sources have no counterpart in this image -- left as documented gaps, per AGENT_BRIEF's own milestone plan ('tasks 5, 9 stubbed to fixed data' for the first pass; here 9 is real for the 3 available sources and stubbed (Unknown(Top)) for the rest). Both known frictions from AGENT_BRIEF apply: the tools report return types only (Sigma cells stay return-type-shaped throughout, Task 7/8's own decision, so this isn't actually a mismatch here); a tool may report Foo where the truth is Foo class -- corrected here via each result's own classSide flag, not trusted blindly.
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

{ #category : 'tool integration' }
HYIToolAdapter class >> artiStabilityFor: aTau [
	"ARTI's own Stability mapping: Fixed-S if the tau is (or is a union containing) Self, Fixed-NS for every other shape ARTI can produce -- classes, instances, literals, TypeVar, or Bottom (whose wrapping is decided separately by wrapConverted:realStability:, not here)."

	(aTau isSelfRef or: [ aTau isUnion and: [ aTau members anySatisfy: [ :m | m isSelfRef ] ] ]) ifTrue: [ ^ HYIFixedS value ].
	^ HYIFixedNS value
]

{ #category : 'tool integration' }
HYIToolAdapter class >> buildForClass: aClass [
	"Convenience one-shot: asks all three tools about every method of aClass and merges their answers into one Dictionary, keyed by HYISigmaKey. Each tool's failure is caught independently so one tool erroring doesn't blank out the other two's evidence. NOTE: this always starts each key from HYITypeVariant unknown, so a tool's bare Bottom answer never survives here even when it's the only real evidence -- see the Merge Rule Matrix notes for why that's specific to this accumulation, not to ~ itself."

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
	^ dict
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
