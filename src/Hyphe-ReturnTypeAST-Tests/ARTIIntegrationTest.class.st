"
REQ-T3/T4: end-to-end tests of the full pipeline (gates + reachability + all 10 checks +
union combination) against ARTIIntegrationFixtureClass, including CSV export and package-mode/class-mode
agreement on a shared class.
"
Class {
	#name : 'ARTIIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTIIntegrationTest >> testCSVExportWritesOneSortedRowPerResult [

	| report file lines |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	file := FileLocator temp / 'arti-integration-test.csv'.
	report printCSVTo: file.
	[
		lines := file contents lines.
		self assert: lines size equals: 6. "header + 5 rows"
		self assert: (lines first includesSubstring: 'Package').
		self assert: (lines first includesSubstring: 'Type') ] ensure: [
		file ensureDelete ]
]

{ #category : 'tests' }
ARTIIntegrationTest >> testFullPipelineOverAFixtureClassProducesTheExpectedResultCollection [
	"REQ-T3: exercises layers 0/3/1/2/4 together against a small fixture class with a known
	expected output."

	| report resultsBySelector |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	resultsBySelector := Dictionary new.
	report results do: [ :r | resultsBySelector at: r selector put: r ].

	self assert: report results size equals: 5.
	self assert: report excludedPrimitiveMethods size equals: 1.
	self
		assert: report excludedPrimitiveMethods first selector
		equals: #hasPrimitive.

	self
		assert: (resultsBySelector at: #returnsFive) type
		equals: (ARTIClassRef named: #Integer).
	self
		assert: (resultsBySelector at: #returnsSelf) type
		equals: ARTISelfType new.
	self
		assert: (resultsBySelector at: #returnsArg:) type
		equals: (ARTITypeVarType position: 1).
	self
		assert: (resultsBySelector at: #makeViaSelfNew) type
		equals: ARTIUnknownType new.
	self
		assert: (resultsBySelector at: #makeViaObjectNew) type
		equals: (ARTIClassRef named: #Object).

	self deny: (resultsBySelector includesKey: #emptyBody)
]

{ #category : 'tests' }
ARTIIntegrationTest >> testPackageModeAndClassModeAgreeOnASharedClass [

	| classReport packageReport classSelectors packageSelectorsForClass |
	classReport := ARTIReturnTypeInferrer inferClass:
		               ARTIIntegrationFixtureClass.
	packageReport := ARTIReturnTypeInferrer inferPackage:
		                 'Hyphe-ReturnTypeAST-Tests'.

	classSelectors := classReport results
		                  collect: [ :r | r selector ]
		                  as: Set.
	packageSelectorsForClass := (packageReport results select: [ :r |
		                             r className
		                             = 'ARTIIntegrationFixtureClass' ])
		                            collect: [ :r | r selector ]
		                            as: Set.

	self assert: classSelectors equals: packageSelectorsForClass
]

{ #category : 'tests' }
ARTIIntegrationTest >> testResultsRecordEnoughToReidentifyTheMethod [

	| report result |
	report := ARTIReturnTypeInferrer inferClass:
		          ARTIIntegrationFixtureClass.
	result := report results detect: [ :r | r selector = #returnsFive ].
	self assert: result packageName equals: 'Hyphe-ReturnTypeAST-Tests'.
	self assert: result className equals: 'ARTIIntegrationFixtureClass'.
	self deny: result classSide.

	result := report results detect: [ :r |
		          r selector = #makeViaObjectNew ].
	self assert: result classSide
]
