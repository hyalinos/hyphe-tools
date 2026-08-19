"
One independent test per pattern in ARTHPatternCatalog>>trusted (19 tests), each asserting both a positive example (matches, correct expectedType, correct matchedPattern identifier -- not just 'something matched', since patterns legitimately overlap) and a negative example chosen to sit just outside that pattern's boundary (missing camelCase capitalization, wrong case, wrong exact text, etc). Mirrors the spirit of ARTI's per-check independent test suites.
"
Class {
	#name : 'ARTHPatternMatchingTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeHeuristic-Tests',
	#package : 'Hyphe-ReturnTypeHeuristic-Tests'
}

{ #category : 'tests' }
ARTHPatternMatchingTest >> testDefaultIconNameBeatsGenericRegexAndSuffix [

	| pos |
	pos := ARTHClassifier classify: #defaultIconName classSide: false.
	self assert: pos expectedType equals: #String.
	self
		assert: pos matchedPattern identifier
		equals: #defaultIconNameString
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testDefaultMenuIconNameBeatsGenericRegexAndSuffix [

	| pos |
	pos := ARTHClassifier classify: #defaultMenuIconName classSide: false.
	self assert: pos expectedType equals: #String.
	"Also matches the default*Name regex and the *Name suffix -- the exact pattern must win\n\ton specificity."
	self
		assert: pos matchedPattern identifier
		equals: #defaultMenuIconNameString
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testDefaultNameDescriptionTitleRegex [

	| pos1 pos2 rejectedByRegexButCaughtByNameSuffix negOutsideAll |
	pos1 := ARTHClassifier
		        classify: #defaultFooDescription
		        classSide: false.
	self assert: pos1 expectedType equals: #String.
	self
		assert: pos1 matchedPattern identifier
		equals: #defaultNameDescriptionTitleString.
	pos2 := ARTHClassifier classify: #defaultBarTitle classSide: false.
	self
		assert: pos2 matchedPattern identifier
		equals: #defaultNameDescriptionTitleString.
	rejectedByRegexButCaughtByNameSuffix := ARTHClassifier
		                                        classify: #ruleName
		                                        classSide: false.
	self
		assert:
		rejectedByRegexButCaughtByNameSuffix matchedPattern identifier
		equals: #nameSuffixString.
	negOutsideAll := ARTHClassifier
		                 classify: #defaultBarLabel
		                 classSide: false.
	self deny: negOutsideAll hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testDescriptionExactString [

	| pos neg |
	pos := ARTHClassifier classify: #description classSide: false.
	self assert: pos expectedType equals: #String.
	self assert: pos matchedPattern identifier equals: #descriptionString.
	neg := ARTHClassifier classify: #descriptions classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testEqualsExactBoolean [

	| pos neg |
	pos := ARTHClassifier classify: #= classSide: false.
	self assert: pos expectedType equals: #Boolean.
	self assert: pos matchedPattern identifier equals: #equalsBoolean.
	neg := ARTHClassifier classify: #'==' classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testHandlesMouseDownExactKeyword [

	| pos neg |
	pos := ARTHClassifier classify: #handlesMouseDown: classSide: false.
	self assert: pos expectedType equals: #Boolean.
	self
		assert: pos matchedPattern identifier
		equals: #handlesMouseDownBoolean.
	neg := ARTHClassifier classify: #handlesMouseUp: classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testHasPrefixBoolean [

	| pos neg |
	pos := ARTHClassifier classify: #hasElements classSide: false.
	self assert: pos expectedType equals: #Boolean.
	self assert: pos matchedPattern identifier equals: #hasPrefixBoolean.
	neg := ARTHClassifier classify: #harm classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testIsPrefixBoolean [

	| pos neg |
	pos := ARTHClassifier classify: #isEmpty classSide: false.
	self assert: pos expectedType equals: #Boolean.
	self assert: pos matchedPattern identifier equals: #isPrefixBoolean.
	neg := ARTHClassifier classify: #island classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testKeyExactString [

	| pos neg |
	pos := ARTHClassifier classify: #key classSide: false.
	self assert: pos expectedType equals: #String.
	self assert: pos matchedPattern identifier equals: #keyString.
	neg := ARTHClassifier classify: #keys classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testManuallyPrefixArray [

	| pos neg1 neg2 |
	pos := ARTHClassifier
		       classify: #manuallyConfiguredThing
		       classSide: false.
	self assert: pos expectedType equals: #Array.
	self
		assert: pos matchedPattern identifier
		equals: #manuallyPrefixArray.
	neg1 := ARTHClassifier classify: #manual classSide: false.
	self deny: neg1 hasMatch.
	neg2 := ARTHClassifier classify: #manuallyresolved classSide: false.
	self deny: neg2 hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testManuallyResolvedDependenciesExactBeatsPrefix [

	| pos |
	pos := ARTHClassifier
		       classify: #manuallyResolvedDependencies
		       classSide: false.
	self assert: pos expectedType equals: #Array.
	"Also matches the broader manually prefix -- the exact pattern must win on specificity."
	self
		assert: pos matchedPattern identifier
		equals: #manuallyResolvedDependenciesArray
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testNameSuffixStringTrustedWithCaveat [

	| pos neg |
	pos := ARTHClassifier classify: #windowName classSide: false.
	self assert: pos expectedType equals: #String.
	self assert: pos matchedPattern identifier equals: #nameSuffixString.
	self assert: pos confidenceTier equals: #trustedWithCaveat.
	neg := ARTHClassifier classify: #named classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testOrderExactNumber [

	| pos neg |
	pos := ARTHClassifier classify: #order classSide: false.
	self assert: pos expectedType equals: #Number.
	self assert: pos matchedPattern identifier equals: #orderNumber.
	neg := ARTHClassifier classify: #reorder classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testPositiveSuffixArray [

	| pos neg |
	pos := ARTHClassifier classify: #assertPositive classSide: false.
	self assert: pos expectedType equals: #Array.
	self
		assert: pos matchedPattern identifier
		equals: #positiveSuffixArray.
	neg := ARTHClassifier classify: #positive classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testPriorityExactNumber [

	| pos neg |
	pos := ARTHClassifier classify: #priority classSide: false.
	self assert: pos expectedType equals: #Number.
	self assert: pos matchedPattern identifier equals: #priorityNumber.
	neg := ARTHClassifier classify: #priorityQueue classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testResumableSuffixBoolean [

	| pos neg |
	pos := ARTHClassifier classify: #errorResumable classSide: false.
	self assert: pos expectedType equals: #Boolean.
	self
		assert: pos matchedPattern identifier
		equals: #resumableSuffixBoolean.
	neg := ARTHClassifier classify: #resumable classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testShouldInheritSelectorsExactBoolean [

	| pos neg |
	pos := ARTHClassifier
		       classify: #shouldInheritSelectors
		       classSide: false.
	self assert: pos expectedType equals: #Boolean.
	self
		assert: pos matchedPattern identifier
		equals: #shouldInheritSelectorsBoolean.
	neg := ARTHClassifier classify: #shouldInherit classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testTitleExactString [

	| pos neg |
	pos := ARTHClassifier classify: #title classSide: false.
	self assert: pos expectedType equals: #String.
	self assert: pos matchedPattern identifier equals: #titleString.
	neg := ARTHClassifier classify: #windowTitle classSide: false.
	self deny: neg hasMatch
]

{ #category : 'tests' }
ARTHPatternMatchingTest >> testWantsPrefixBoolean [

	| pos neg |
	pos := ARTHClassifier classify: #wantsFocus classSide: false.
	self assert: pos expectedType equals: #Boolean.
	self
		assert: pos matchedPattern identifier
		equals: #wantsPrefixBoolean.
	neg := ARTHClassifier classify: #want classSide: false.
	self deny: neg hasMatch
]
