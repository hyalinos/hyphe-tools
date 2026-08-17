"
Tests for RTATypeDistribution: category classification for every ARTIType kind,
counts/percentages against a known fixture report (see ARTIIntegrationFixtureClass), the empty-input edge case,
drill-down via #resultsInCategory:, and CSV export.
"
Class {
	#name : 'RTATypeDistributionTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Analysis-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Analysis-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
RTATypeDistributionTest >> testCSVExportWritesOneRowPerCategoryPlusHeader [

	| report dist file lines |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	dist := RTATypeDistribution onReport: report.
	file := FileLocator temp / 'rta-distribution-test.csv'.
	dist printCSVTo: file.
	[
		lines := file contents lines.
		self assert: lines size equals: 9. "header + 8 categories"
		self assert: (lines first includesSubstring: 'Category') ] ensure: [
		file ensureDelete ]
]

{ #category : 'tests' }
RTATypeDistributionTest >> testCategoryForEachTopLevelTypeKind [

	self
		assert:
		(RTATypeDistribution categoryFor: (ARTIClassRef named: #Integer))
		equals: #ClassRef.
	self
		assert:
		(RTATypeDistribution categoryFor: (ARTIMetaclass named: #Integer))
		equals: #Metaclass.
	self
		assert: (RTATypeDistribution categoryFor: ARTISelfType new)
		equals: #Self.
	self
		assert: (RTATypeDistribution categoryFor: ARTISelfClassType new)
		equals: #SelfClass.
	self
		assert: (RTATypeDistribution categoryFor: ARTIBottomType new)
		equals: #Bottom.
	self
		assert:
		(RTATypeDistribution categoryFor: (ARTITypeVarType position: 1))
		equals: #TypeVar.
	self
		assert: (RTATypeDistribution categoryFor: ARTIUnknownType new)
		equals: #Unknown.
	self
		assert:
			(RTATypeDistribution categoryFor: (ARTIUnionType withMembers: {
						  (ARTIClassRef named: #Integer).
						  ARTIUnknownType new }))
		equals: #Union
]

{ #category : 'tests' }
RTATypeDistributionTest >> testCountsAndTotalOverAKnownFixtureReport [

	| report dist |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	dist := RTATypeDistribution onReport: report.
	self assert: dist total equals: 5.
	self assert: (dist countFor: #ClassRef) equals: 2.
	self assert: (dist countFor: #Self) equals: 1.
	self assert: (dist countFor: #TypeVar) equals: 1.
	self assert: (dist countFor: #Unknown) equals: 1.
	self assert: (dist countFor: #Bottom) equals: 0.
	self assert: (dist countFor: #Metaclass) equals: 0.
	self assert: (dist countFor: #SelfClass) equals: 0.
	self assert: (dist countFor: #Union) equals: 0
]

{ #category : 'tests' }
RTATypeDistributionTest >> testCountsSumToTotal [

	| report dist sum |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	dist := RTATypeDistribution onReport: report.
	sum := (RTATypeDistribution categories collect: [ :c |
		        dist countFor: c ]) sum.
	self assert: sum equals: dist total
]

{ #category : 'tests' }
RTATypeDistributionTest >> testEmptyResultsGiveZeroPercentagesNotAnError [

	| dist |
	dist := RTATypeDistribution onResults: #(  ).
	self assert: dist total equals: 0.
	self assert: (dist percentageFor: #ClassRef) equals: 0.0
]

{ #category : 'tests' }
RTATypeDistributionTest >> testPercentagesSumToOneHundred [

	| report dist sum |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	dist := RTATypeDistribution onReport: report.
	sum := (RTATypeDistribution categories collect: [ :c |
		        dist percentageFor: c ]) sum.
	self assert: (sum - 100.0) abs < 0.001
]

{ #category : 'tests' }
RTATypeDistributionTest >> testResultsInCategoryDrillDown [

	| report dist unknownResults |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	dist := RTATypeDistribution onReport: report.
	unknownResults := dist resultsInCategory: #Unknown.
	self assert: unknownResults size equals: 1.
	self assert: unknownResults first selector equals: #makeViaSelfNew
]
