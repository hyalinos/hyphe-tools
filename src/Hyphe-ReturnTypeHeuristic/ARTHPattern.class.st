"
A single name-based return-type heuristic: 'selectors of this shape conventionally return this type'. Declarative data, not a code branch -- matchKind/matchText describe *how* to compare a selector, expectedType/confidenceTier describe the claim, and calibration (an ARTHCalibrationMetadata) documents the empirical evidence behind the claim from selector-frequency-analysis.md.

matchKind is one of:
  #exact        -- selector string equals matchText verbatim.
  #exactKeyword -- a full keyword selector (e.g. #handlesMouseDown:) equals matchText verbatim.
  #prefix       -- selector starts with matchText, followed by an uppercase letter
                   (camelCase word boundary), e.g. prefix 'is' matches 'isEmpty' but not 'island'.
  #suffix       -- selector ends with matchText. Since every seeded suffix starts with an
                   uppercase letter, the camelCase boundary is guaranteed by the capitalization
                   itself, so a plain #endsWith: check is sufficient.
  #regex        -- selector matches matchText as a regular expression (Pharo #matchesRegex:).
                   Reserved for genuinely compound patterns that don't reduce to exact/prefix/suffix.

scope restricts applicability to #any / #instanceSideOnly / #classSideOnly (all seeded patterns
use #any; the field exists for future class-side-specific conventions).

specificityRank orders patterns for ARTHPatternCatalog>>bestMatchFor:classSide: -- when several
patterns match the same selector, the most specific one wins (exactKeyword > exact > regex > 
prefix/suffix), never a 'first in the list' rule.
"
Class {
	#name : 'ARTHPattern',
	#superclass : 'Object',
	#instVars : [
		'identifier',
		'matchKind',
		'matchText',
		'expectedType',
		'confidenceTier',
		'scope',
		'calibration'
	],
	#category : 'Hyphe-ReturnTypeHeuristic',
	#package : 'Hyphe-ReturnTypeHeuristic'
}

{ #category : 'instance creation' }
ARTHPattern class >> exact: anIdentifier text: aText type: aType tier: aTier calibration: aCalibration [

	^ self
		  identifier: anIdentifier
		  matchKind: #exact
		  matchText: aText
		  expectedType: aType
		  tier: aTier
		  scope: #any
		  calibration: aCalibration
]

{ #category : 'instance creation' }
ARTHPattern class >> exactKeyword: anIdentifier text: aText type: aType tier: aTier calibration: aCalibration [

	^ self
		  identifier: anIdentifier
		  matchKind: #exactKeyword
		  matchText: aText
		  expectedType: aType
		  tier: aTier
		  scope: #any
		  calibration: aCalibration
]

{ #category : 'instance creation' }
ARTHPattern class >> identifier: anIdentifier matchKind: aMatchKind matchText: aMatchText expectedType: aType tier: aTier scope: aScope calibration: aCalibration [

	^ self new
		  setIdentifier: anIdentifier
		  matchKind: aMatchKind
		  matchText: aMatchText
		  expectedType: aType
		  tier: aTier
		  scope: aScope
		  calibration: aCalibration
]

{ #category : 'instance creation' }
ARTHPattern class >> prefix: anIdentifier text: aText type: aType tier: aTier calibration: aCalibration [

	^ self
		  identifier: anIdentifier
		  matchKind: #prefix
		  matchText: aText
		  expectedType: aType
		  tier: aTier
		  scope: #any
		  calibration: aCalibration
]

{ #category : 'instance creation' }
ARTHPattern class >> regex: anIdentifier text: aText type: aType tier: aTier calibration: aCalibration [

	^ self
		  identifier: anIdentifier
		  matchKind: #regex
		  matchText: aText
		  expectedType: aType
		  tier: aTier
		  scope: #any
		  calibration: aCalibration
]

{ #category : 'instance creation' }
ARTHPattern class >> suffix: anIdentifier text: aText type: aType tier: aTier calibration: aCalibration [

	^ self
		  identifier: anIdentifier
		  matchKind: #suffix
		  matchText: aText
		  expectedType: aType
		  tier: aTier
		  scope: #any
		  calibration: aCalibration
]

{ #category : 'matching' }
ARTHPattern >> appliesToClassSide: isClassSide [

	scope = #any ifTrue: [ ^ true ].
	scope = #instanceSideOnly ifTrue: [ ^ isClassSide not ].
	scope = #classSideOnly ifTrue: [ ^ isClassSide ].
	^ true
]

{ #category : 'accessing' }
ARTHPattern >> calibration [

	^ calibration
]

{ #category : 'accessing' }
ARTHPattern >> confidenceTier [

	^ confidenceTier
]

{ #category : 'accessing' }
ARTHPattern >> expectedType [

	^ expectedType
]

{ #category : 'accessing' }
ARTHPattern >> identifier [

	^ identifier
]

{ #category : 'accessing' }
ARTHPattern >> matchKind [

	^ matchKind
]

{ #category : 'accessing' }
ARTHPattern >> matchText [

	^ matchText
]

{ #category : 'matching' }
ARTHPattern >> matches: aSelector classSide: isClassSide [

	| selectorString |
	(self appliesToClassSide: isClassSide) ifFalse: [ ^ false ].
	selectorString := aSelector asString.
	(matchKind = #exact or: [ matchKind = #exactKeyword ]) ifTrue: [
		^ selectorString = matchText ].
	matchKind = #prefix ifTrue: [
		^ self selectorString: selectorString hasCamelCasePrefix: matchText ].
	matchKind = #suffix ifTrue: [ ^ selectorString endsWith: matchText ].
	matchKind = #regex ifTrue: [
		^ selectorString matchesRegex: matchText ].
	^ false
]

{ #category : 'printing' }
ARTHPattern >> printOn: aStream [

	aStream
		nextPutAll: '<';
		nextPutAll: matchKind asString;
		nextPutAll: ' ';
		print: matchText;
		nextPutAll: ' -> ';
		nextPutAll: expectedType asString;
		nextPutAll: ' (';
		nextPutAll: confidenceTier asString;
		nextPutAll: ')>'
]

{ #category : 'accessing' }
ARTHPattern >> scope [

	^ scope
]

{ #category : 'private' }
ARTHPattern >> selectorString: aString hasCamelCasePrefix: aPrefix [

	aString size > aPrefix size ifFalse: [ ^ false ].
	(aString beginsWith: aPrefix) ifFalse: [ ^ false ].
	^ (aString at: aPrefix size + 1) isUppercase
]

{ #category : 'private' }
ARTHPattern >> setIdentifier: anIdentifier matchKind: aMatchKind matchText: aMatchText expectedType: aType tier: aTier scope: aScope calibration: aCalibration [

	identifier := anIdentifier.
	matchKind := aMatchKind.
	matchText := aMatchText.
	expectedType := aType.
	confidenceTier := aTier.
	scope := aScope.
	calibration := aCalibration
]

{ #category : 'matching' }
ARTHPattern >> specificityRank [
	"Higher wins when several patterns match the same selector. Tiers are separated by 1000\n\tso that matchText length (used as a same-tier tie-breaker -- a longer, more specific\n\ttext outranks a shorter one) can never cross into the next tier."

	matchKind = #exactKeyword ifTrue: [ ^ 4000 + matchText size ].
	matchKind = #exact ifTrue: [ ^ 3000 + matchText size ].
	matchKind = #regex ifTrue: [ ^ 2000 + matchText size ].
	(matchKind = #prefix or: [ matchKind = #suffix ]) ifTrue: [
		^ 1000 + matchText size ].
	^ 0
]
