"
A collection of ARTHPattern rules plus the conflict-resolution policy for when several patterns match the same selector: the highest #specificityRank wins (never 'first in the list'). #trusted builds the catalog seeded from the 19 patterns in the 'Trusted heuristics -- final list' section of selector-frequency-analysis.md -- every pattern there passed all three checks documented in that file: (1) determinate sample size >= 30, (2) agreement rate >= 90% ('trusted') or 80-90% ('trusted with caveat'), (3) package-concentration check (no single package dominating the determinate matches).
"
Class {
	#name : 'ARTHPatternCatalog',
	#superclass : 'Object',
	#instVars : [
		'patterns'
	],
	#category : 'Hyphe-ReturnTypeHeuristic',
	#package : 'Hyphe-ReturnTypeHeuristic'
}

{ #category : 'instance creation' }
ARTHPatternCatalog class >> trusted [
	"The catalog seeded from the 19 patterns in the 'Trusted heuristics -- final list' section\n\tof selector-frequency-analysis.md. Rebuilt fresh on every call (19 lightweight objects --\n\tnot worth caching and risking stale state across image changes)."

	^ self new
		  addPattern: (ARTHPattern
				   prefix: #isPrefixBoolean
				   text: 'is'
				   type: #Boolean
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 1802
						    agreementRatePercent: 98.2
						    topSharePercent: 6.6
						    note:
							    'Most reliable Boolean prefix; mismatches are almost entirely Bottom (abstract is... methods with subclassResponsibility bodies), not real counterexamples. 210 packages.'));
		  addPattern: (ARTHPattern
				   prefix: #hasPrefixBoolean
				   text: 'has'
				   type: #Boolean
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 126
						    agreementRatePercent: 94.4
						    topSharePercent: 11.9
						    note: 'Second most reliable Boolean prefix. 49 packages.'));
		  addPattern: (ARTHPattern
				   exact: #equalsBoolean
				   text: '='
				   type: #Boolean
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 29
						    agreementRatePercent: 93.1
						    topSharePercent: 27.6
						    note: '13 packages.'));
		  addPattern: (ARTHPattern
				   exact: #priorityNumber
				   text: 'priority'
				   type: #Number
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 70
						    agreementRatePercent: 100.0
						    topSharePercent: 31.4
						    note: '26 packages.'));
		  addPattern: (ARTHPattern
				   regex: #defaultNameDescriptionTitleString
				   text: '^default[A-Z].*(Name|Description|Title)$'
				   type: #String
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 360
						    agreementRatePercent: 98.6
						    topSharePercent: 8.3
						    note:
							    'Combined regex chosen specifically because it excludes ruleName, which looked similar but is package-concentrated. 54 packages.'));
		  addPattern: (ARTHPattern
				   exact: #titleString
				   text: 'title'
				   type: #String
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 102
						    agreementRatePercent: 96.1
						    topSharePercent: 32.4
						    note: '24 packages.'));
		  addPattern: (ARTHPattern
				   exact: #defaultMenuIconNameString
				   text: 'defaultMenuIconName'
				   type: #String
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 107
						    agreementRatePercent: 99.1
						    topSharePercent: 14.0
						    note: '20 packages.'));
		  addPattern: (ARTHPattern
				   exact: #defaultIconNameString
				   text: 'defaultIconName'
				   type: #String
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 95
						    agreementRatePercent: 95.8
						    topSharePercent: 18.9
						    note: '21 packages.'));
		  addPattern: (ARTHPattern
				   exact: #descriptionString
				   text: 'description'
				   type: #String
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 213
						    agreementRatePercent: 95.3
						    topSharePercent: 15.5
						    note:
							    'Surfaced by the unfiltered full sweep, not an obvious type-revealing name. 57 packages.'));
		  addPattern: (ARTHPattern
				   exact: #orderNumber
				   text: 'order'
				   type: #Number
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 68
						    agreementRatePercent: 91.2
						    topSharePercent: 22.1
						    note: 'Surfaced by the unfiltered full sweep. 20 packages.'));
		  addPattern: (ARTHPattern
				   exact: #keyString
				   text: 'key'
				   type: #String
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 50
						    agreementRatePercent: 92.0
						    topSharePercent: 38.0
						    note: 'Surfaced by the unfiltered full sweep. 11 packages.'));
		  addPattern: (ARTHPattern
				   exact: #shouldInheritSelectorsBoolean
				   text: 'shouldInheritSelectors'
				   type: #Boolean
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 40
						    agreementRatePercent: 100.0
						    topSharePercent: 12.5
						    note: '22 packages.'));
		  addPattern: (ARTHPattern
				   exact: #manuallyResolvedDependenciesArray
				   text: 'manuallyResolvedDependencies'
				   type: #Array
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 53
						    agreementRatePercent: 100.0
						    topSharePercent: 3.8
						    note:
							    'Same underlying 53 methods as the manually prefix pattern below. 52 packages -- excellent spread.'));
		  addPattern: (ARTHPattern
				   prefix: #manuallyPrefixArray
				   text: 'manually'
				   type: #Array
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 53
						    agreementRatePercent: 100.0
						    topSharePercent: 3.8
						    note:
							    'Broader prefix superset of manuallyResolvedDependencies; kept as a separate pattern in case other manually* selectors exist elsewhere. 52 packages.'));
		  addPattern: (ARTHPattern
				   suffix: #positiveSuffixArray
				   text: 'Positive'
				   type: #Array
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 188
						    agreementRatePercent: 91.0
						    topSharePercent: 5.9
						    note: '77 packages -- excellent spread.'));
		  addPattern: (ARTHPattern
				   prefix: #wantsPrefixBoolean
				   text: 'wants'
				   type: #Boolean
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 50
						    agreementRatePercent: 100.0
						    topSharePercent: 18.0
						    note: '21 packages.'));
		  addPattern: (ARTHPattern
				   suffix: #resumableSuffixBoolean
				   text: 'Resumable'
				   type: #Boolean
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 34
						    agreementRatePercent: 91.2
						    topSharePercent: 20.6
						    note: '18 packages.'));
		  addPattern: (ARTHPattern
				   exactKeyword: #handlesMouseDownBoolean
				   text: 'handlesMouseDown:'
				   type: #Boolean
				   tier: #trusted
				   calibration: (ARTHCalibrationMetadata
						    n: 32
						    agreementRatePercent: 100.0
						    topSharePercent: 12.5
						    note:
							    'First empirical confirmation of the handles[A-Z].* family proposed early in the calibration work. 19 packages.'));
		  addPattern: (ARTHPattern
				   suffix: #nameSuffixString
				   text: 'Name'
				   type: #String
				   tier: #trustedWithCaveat
				   calibration: (ARTHCalibrationMetadata
						    n: 1844
						    agreementRatePercent: 84.9
						    topSharePercent: 14.2
						    note:
							    'Below the 90% bar but a large, stable sample with a clean 236-package spread. Dominant mismatch is Self (fluent/builder methods), the recurring confound across this whole calibration. Superseded in reliability by the narrower default*Name/Description/Title family and several individual exact selectors above wherever those apply.'));
		  yourself
]

{ #category : 'accessing' }
ARTHPatternCatalog >> addPattern: aPattern [

	patterns add: aPattern
]

{ #category : 'matching' }
ARTHPatternCatalog >> bestMatchFor: aSelector classSide: isClassSide [
	"Returns the ARTHClassification for aSelector: a match against the single most specific\n\tpattern that applies, or a no-match classification if nothing applies. Raises an error\n\t(rather than silently picking one) if two patterns of equal, top specificity disagree on\n\tthe expected type for this selector -- that is a catalog design bug, not a runtime case\n\tto paper over."

	| candidates bestRank winners |
	candidates := patterns select: [ :p |
		              p matches: aSelector classSide: isClassSide ].
	candidates isEmpty ifTrue: [
		^ ARTHClassification noMatchFor: aSelector ].
	bestRank := (candidates collect: [ :p | p specificityRank ]) max.
	winners := candidates select: [ :p | p specificityRank = bestRank ].
	(winners collect: [ :p | p expectedType ]) asSet size > 1 ifTrue: [
			^ self error:
				  'ARTHPatternCatalog: conflicting patterns of equal specificity for selector '
				  , aSelector asString , ': '
				  , (winners collect: [ :p | p identifier ]) printString ].
	^ ARTHClassification matched: winners first selector: aSelector
]

{ #category : 'initialization' }
ARTHPatternCatalog >> initialize [

	patterns := OrderedCollection new
]

{ #category : 'accessing' }
ARTHPatternCatalog >> patterns [

	^ patterns
]

{ #category : 'accessing' }
ARTHPatternCatalog >> size [

	^ patterns size
]

{ #category : 'validation' }
ARTHPatternCatalog >> validate [
	"Descriptive, catalog-wide sanity check: flags any two *distinct* patterns registered with the\n\tsame matchKind and matchText but a different expectedType -- an accidental duplicate/contradictory\n\tregistration. Returns an OrderedCollection of identifier -> identifier pairs (empty if clean).\n\tThis is independent from the per-selector conflict check in #bestMatchFor:classSide: (which can\n\tonly be exercised by an actual selector); this one is exhaustive over the catalog itself."

	| seen conflicts |
	seen := Dictionary new.
	conflicts := OrderedCollection new.
	patterns do: [ :p |
			| key prior |
			key := p matchKind -> p matchText.
			prior := seen at: key ifAbsent: [ nil ].
			(prior notNil and: [ prior expectedType ~= p expectedType ])
				ifTrue: [ conflicts add: prior identifier -> p identifier ].
			seen at: key put: p ].
	^ conflicts
]
