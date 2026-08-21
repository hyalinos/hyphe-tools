"
Tests ARTHPatternCatalog's own machinery: the seeded #trusted catalog's shape (count, no internal conflicts), and the specificity-resolution / conflict-detection policy in #bestMatchFor:classSide: and #validate, exercised on small hand-built catalogs so these tests don't depend on what the 19-pattern seed data happens to contain.
"
Class {
	#name : 'ARTHPatternCatalogTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeHeuristic-Tests',
	#package : 'Hyphe-ReturnTypeHeuristic-Tests'
}

{ #category : 'tests' }
ARTHPatternCatalogTest >> testBestMatchPicksHighestSpecificity [

	| cat shortPrefix longExact result |
	shortPrefix := ARTHPattern
		               prefix: #shortOne
		               text: 'foo'
		               type: (HTMType classRef: #Boolean)
		               tier: #trusted
		               calibration: (ARTHCalibrationMetadata
				                n: 1
				                agreementRatePercent: 1
				                topSharePercent: 1
				                note: 'synthetic').
	longExact := ARTHPattern
		             exact: #longOne
		             text: 'fooBarBaz'
		             type: (HTMType classRef: #Number)
		             tier: #trusted
		             calibration: (ARTHCalibrationMetadata
				              n: 1
				              agreementRatePercent: 1
				              topSharePercent: 1
				              note: 'synthetic').
	cat := ARTHPatternCatalog new
		       addPattern: shortPrefix;
		       addPattern: longExact;
		       yourself.
	result := cat bestMatchFor: #fooBarBaz classSide: false.
	"Both patterns match #fooBarBaz -- the exact pattern (higher specificityRank) must win, not the\n\tprefix, and not simply 'whichever was added first'."
	self assert: result matchedPattern identifier equals: #longOne.
	self assert: result expectedType equals: (HTMType classRef: #Number)
]

{ #category : 'tests' }
ARTHPatternCatalogTest >> testBestMatchRaisesOnGenuineEqualSpecificityConflict [

	| cat p1 p2 |
	p1 := ARTHPattern
		      exact: #p1
		      text: 'ambiguous'
		      type: #Boolean
		      tier: #trusted
		      calibration: (ARTHCalibrationMetadata
				       n: 1
				       agreementRatePercent: 1
				       topSharePercent: 1
				       note: 'synthetic').
	p2 := ARTHPattern
		      exact: #p2
		      text: 'ambiguous'
		      type: #String
		      tier: #trusted
		      calibration: (ARTHCalibrationMetadata
				       n: 1
				       agreementRatePercent: 1
				       topSharePercent: 1
				       note: 'synthetic').
	cat := ARTHPatternCatalog new
		       addPattern: p1;
		       addPattern: p2;
		       yourself.
	self
		should: [ cat bestMatchFor: #ambiguous classSide: false ]
		raise: Error
]

{ #category : 'tests' }
ARTHPatternCatalogTest >> testBestMatchReturnsNoMatchClassificationWhenNothingApplies [

	| cat result |
	cat := ARTHPatternCatalog new.
	result := cat bestMatchFor: #anythingAtAll classSide: false.
	self deny: result hasMatch.
	self assert: result expectedType equals: HTMType unknown.
	self assert: result matchedPattern isNil
]

{ #category : 'tests' }
ARTHPatternCatalogTest >> testTrustedCatalogHasNineteenPatterns [

	self assert: ARTHPatternCatalog trusted size equals: 19
]

{ #category : 'tests' }
ARTHPatternCatalogTest >> testTrustedCatalogHasNoInternalConflicts [

	self assert: ARTHPatternCatalog trusted validate isEmpty
]

{ #category : 'tests' }
ARTHPatternCatalogTest >> testValidateAllowsSameMatchTextWithSameType [

	| cat p1 p2 |
	p1 := ARTHPattern
		      suffix: #p1
		      text: 'Widget'
		      type: #Boolean
		      tier: #trusted
		      calibration: (ARTHCalibrationMetadata
				       n: 1
				       agreementRatePercent: 1
				       topSharePercent: 1
				       note: 'synthetic').
	p2 := ARTHPattern
		      suffix: #p2
		      text: 'Widget'
		      type: #Boolean
		      tier: #trustedWithCaveat
		      calibration: (ARTHCalibrationMetadata
				       n: 1
				       agreementRatePercent: 1
				       topSharePercent: 1
				       note: 'synthetic').
	cat := ARTHPatternCatalog new
		       addPattern: p1;
		       addPattern: p2;
		       yourself.
	self assert: cat validate isEmpty
]

{ #category : 'tests' }
ARTHPatternCatalogTest >> testValidateFlagsDuplicateMatchTextWithContradictingType [

	| cat p1 p2 |
	p1 := ARTHPattern
		      suffix: #p1
		      text: 'Widget'
		      type: #Boolean
		      tier: #trusted
		      calibration: (ARTHCalibrationMetadata
				       n: 1
				       agreementRatePercent: 1
				       topSharePercent: 1
				       note: 'synthetic').
	p2 := ARTHPattern
		      suffix: #p2
		      text: 'Widget'
		      type: #Array
		      tier: #trusted
		      calibration: (ARTHCalibrationMetadata
				       n: 1
				       agreementRatePercent: 1
				       topSharePercent: 1
				       note: 'synthetic').
	cat := ARTHPatternCatalog new
		       addPattern: p1;
		       addPattern: p2;
		       yourself.
	self assert: cat validate size equals: 1
]
