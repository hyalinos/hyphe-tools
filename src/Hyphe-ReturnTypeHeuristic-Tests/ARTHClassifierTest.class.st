"
Integration tests for ARTHClassifier's whole-image entry points, run against real classes already loaded in this image (ARTHPattern and the Hyphe-ReturnTypeHeuristic package itself), checking traversal shape (both sides covered, one row per method) and per-method package attribution (via CompiledMethod>>#package, not the class's home package).
"
Class {
	#name : 'ARTHClassifierTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeHeuristic-Tests',
	#package : 'Hyphe-ReturnTypeHeuristic-Tests'
}

{ #category : 'tests' }
ARTHClassifierTest >> testClassSideScopeAnyClassifiesIdenticallyOnBothSides [

	| instanceSide classSide |
	instanceSide := ARTHClassifier classify: #isEmpty classSide: false.
	classSide := ARTHClassifier classify: #isEmpty classSide: true.
	self assert: instanceSide expectedType equals: classSide expectedType.
	self
		assert: instanceSide matchedPattern identifier
		equals: classSide matchedPattern identifier
]

{ #category : 'tests' }
ARTHClassifierTest >> testClassifyClassCoversBothInstanceAndClassSide [

	| report |
	report := ARTHClassifier classifyClass: ARTHPattern.
	self
		assert: report size
		equals:
		ARTHPattern selectors size + ARTHPattern class selectors size.
	self assert: (report results anySatisfy: [ :r | r classSide ]).
	self assert: (report results anySatisfy: [ :r | r classSide not ])
]

{ #category : 'tests' }
ARTHClassifierTest >> testClassifyMethodReportsSelectorsOwnDefiningPackage [

	| method result |
	method := ARTHClassification >> #hasMatch.
	result := ARTHClassifier classifyMethod: method.
	self assert: result packageName equals: 'Hyphe-ReturnTypeHeuristic'.
	self assert: result className equals: #ARTHClassification.
	self deny: result classSide.
	self assert: result expectedType equals: (HTMType classRef: #Boolean)
]

{ #category : 'tests' }
ARTHClassifierTest >> testClassifyPackageMatchesSumOfItsClasses [

	| viaPackage viaClasses expectedCount |
	viaPackage := ARTHClassifier classifyPackage:
		              'Hyphe-ReturnTypeHeuristic'.
	expectedCount := (PackageOrganizer default packageNamed:
		                  #'Hyphe-ReturnTypeHeuristic') methods size.
	self assert: viaPackage size equals: expectedCount
]

{ #category : 'tests' }
ARTHClassifierTest >> testCsvFieldQuotesCommasAndQuotes [

	self assert: (ARTHMethodResult new csvField: 'plain') equals: 'plain'.
	self assert: (ARTHMethodResult new csvField: 'a,b') equals: '"a,b"'.
	self
		assert: (ARTHMethodResult new csvField: 'she said "hi"')
		equals: '"she said ""hi"""'
]

{ #category : 'tests' }
ARTHClassifierTest >> testExactKeywordPatternDoesNotMatchUnarySelectorOfSameStem [
	"handlesMouseDown: is a keyword selector; a same-stem unary selector must not match it."

	| result |
	result := ARTHClassifier classify: #handlesMouseDown classSide: false.
	self deny: result hasMatch
]

{ #category : 'tests' }
ARTHClassifierTest >> testMatchedResultsExcludesNoMatchRows [

	| report |
	report := ARTHClassifier classifyClass: ARTHPattern.
	self assert: (report matchedResults allSatisfy: [ :r | r hasMatch ]).
	self assert: report matchedCount equals: report matchedResults size
]
