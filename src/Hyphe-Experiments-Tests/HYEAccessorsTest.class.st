"
Tests of the accessors, the printing and the variants of the constructors of the classes of Hyphe-Experiments that the other tests do not need.
"
Class {
	#name : 'HYEAccessorsTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Data',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Data'
}

{ #category : 'tests' }
HYEAccessorsTest >> testChiSquareObserved [
	"The observed table has no empty row"

	self assert: (HYEChiSquareTest on: #( #( 1 2 ) #( 0 0 ) #( 3 4 ) )) observed size equals: 2
]

{ #category : 'tests' }
HYEAccessorsTest >> testConfidenceStatisticsOfSeveralValues [
	"Mean, standard deviation, minimum and maximum of different confidences"

	| dataset experiment result stats |
	dataset := HYEGroundTruthDataset named: 'conf'.
	{ #mixedSends. #sendsToSelf. #sendsToSuper } do: [ :selector |
		dataset add: (self entryOf: (self metricsRef: selector) truth: 'Object') ].
	experiment := HYEExperiment
		              name: 'conf'
		              scheme: HYEGroupScheme returnPoints
		              dataset: dataset
		              tools: { (HYEBlockTool name: 'Sure' block: [ :ref |
					               HYEToolPrediction tool: 'Sure' types: (HYETypeExpression parse: 'Object') confidence: ({
							                (#mixedSends -> 0.2).
							                (#sendsToSelf -> 0.4).
							                (#sendsToSuper -> 0.6) } detect: [ :each | each key = ref selector ]) value ]) }.
	result := experiment run.
	stats := result confidenceStatsOf: 'Sure' in: (HYEGroupScheme returnPoints groupNamed: 'G1').

	self assert: (stats at: #count) equals: 3.
	self assert: ((stats at: #mean) closeTo: 0.4).
	self assert: ((stats at: #standardDeviation) closeTo: 0.2).
	self assert: (stats at: #min) equals: 0.2.
	self assert: (stats at: #max) equals: 0.6.
	self assert: (result reportString includesSubstring: 'Sure: G1=0.40 (3)')
]

{ #category : 'tests' }
HYEAccessorsTest >> testCsvOfAnEmptyFileWithHeaderOnly [
	"Only a header: no record"

	self assert: (HYECsv recordsFrom: (self write: { 'a,b' } to: (self memoryFile: 'h.csv'))) isEmpty
]

{ #category : 'tests' }
HYEAccessorsTest >> testDatasetNameAndEntries [
	"The dataset has a name that can be changed"

	| dataset |
	dataset := HYEGroundTruthDataset named: 'a'.
	dataset name: 'b'.

	self assert: dataset name equals: 'b'.
	self assert: dataset entries isEmpty.
	self assert: dataset scheme isNil
]

{ #category : 'tests' }
HYEAccessorsTest >> testDatasetWrittenBeforeGrouping [
	"A dataset that was not grouped is written with a count column"

	| dataset file |
	dataset := HYEGroundTruthDataset named: 'plain'.
	dataset add: (self entryOf: (self metricsRef: #mixedSends) truth: 'Object').
	file := dataset writeCsvTo: (self memoryFile: 'plain.csv').

	self assert: ((HYECsv recordsFrom: file) first keys includes: 'count')
]

{ #category : 'tests' }
HYEAccessorsTest >> testExperimentAccessors [
	"The experiment, its rows and the parts of a row can be read"

	| dataset experiment result row |
	dataset := HYEGroundTruthDataset named: 'one'.
	dataset add: (self entryOf: (self metricsRef: #mixedSends) truth: 'Object').
	experiment := HYEExperiment
		              name: 'acc'
		              scheme: HYEGroupScheme returnPoints
		              dataset: dataset
		              tools: { (HYEBlockTool name: 'Solo' block: [ :ref | 'Object' ]) }.
	experiment policy: HYEComparisonPolicy new.
	result := experiment run.
	row := result rows first.

	self assert: experiment name equals: 'acc'.
	self assert: experiment scheme name equals: 'returnPoints'.
	self assert: experiment dataset equals: dataset.
	self assert: experiment tools size equals: 1.
	self assert: result experiment equals: experiment.
	self assert: row entry equals: dataset entries first.
	self assert: row group name equals: 'G1'.
	self assert: (row predictionOf: 'Solo') keys equals: #( 'Object' ).
	self assert: (row outcomes at: 'Solo') equals: #correct.
	self assert: (row predictions at: 'Solo') toolName equals: 'Solo'.
	self assert: result toolNames asArray equals: #( 'Solo' ).
	self assert: experiment strategies second astToolName equals: 'Solo'
]

{ #category : 'tests' }
HYEAccessorsTest >> testExperimentWithoutAnAstTool [
	"Without a tool marked as AST based the first tool is the one the biased strategies favour"

	| experiment |
	experiment := HYEExperiment
		              name: 'x'
		              scheme: HYEGroupScheme returnPoints
		              dataset: HYEGroundTruthDataset new
		              tools: {
				              (HYEBlockTool name: 'First' block: [ :ref | nil ]).
				              (HYEBlockTool name: 'Second' block: [ :ref | nil ]) }.

	self assert: experiment strategies second astToolName equals: 'First'
]

{ #category : 'tests' }
HYEAccessorsTest >> testGroundTruthEntryAccessors [
	"The parts of an entry can be changed, and are printed"

	| entry |
	entry := HYEGroundTruthEntry ref: (self metricsRef: #mixedSends) truth: nil.
	entry truth: (HYETypeExpression parse: 'r').

	self assert: entry truth equals: (HYETypeExpression parse: 'r').
	self assert: (entry printString includesSubstring: 'MetricsTestData>>#mixedSends').
	self assert: (entry printString includesSubstring: '-> r')
]

{ #category : 'tests' }
HYEAccessorsTest >> testGroupAndSchemeAccessors [
	"Name, label, range, printing"

	| group scheme |
	scheme := HYEGroupScheme statementCount.
	group := scheme groupNamed: 'G2'.

	self assert: scheme name equals: 'statementCount'.
	self assert: scheme groups size equals: 4.
	self assert: group label equals: '2-3 statements'.
	self assert: group lower equals: 2.
	self assert: group upper equals: 3.
	self assert: (scheme groupNamed: 'G4') upper isNil.
	self assert: group printString equals: 'G2 (2-3 statements)'
]

{ #category : 'tests' }
HYEAccessorsTest >> testMethodsOutsideEveryGroupAreSkipped [
	"A scheme whose groups do not cover a count (here: only 5 and more) leaves the method out"

	| scheme sampler entries |
	scheme := HYEGroupScheme
		          name: 'big'
		          metric: 'x'
		          block: [ :method | 1 ]
		          groups: { (HYEMethodGroup
				           name: 'G1'
				           label: 'big'
				           lower: 5
				           upper: nil) }.
	sampler := (HYEMethodSampler scheme: scheme)
		           pool: { (MetricsTestData >> #noSends) };
		           yourself.

	entries := (sampler sample: (Dictionary new
			             at: scheme groups first put: 1;
			             yourself)) at: scheme groups first.

	self assert: entries isEmpty
]

{ #category : 'tests' }
HYEAccessorsTest >> testPredictionPrintsItsConfidence [
	"tool: types (confidence)"

	self assert: (HYEToolPrediction tool: 'T' types: (HYETypeExpression parse: 'A') confidence: 0.5) printString equals: 'T: A (0.5)'.
	self assert: (HYEToolPrediction nothingFrom: 'T') printString equals: 'T: nothing'
]

{ #category : 'tests' }
HYEAccessorsTest >> testReportOfAnExperimentWithoutAnyData [
	"No row: the report still works"

	| result |
	result := (HYEExperiment
		           name: 'empty'
		           scheme: HYEGroupScheme statementCount
		           dataset: HYEGroundTruthDataset new
		           tools: { (HYEBlockTool name: 'T' block: [ :ref | nil ]) }) run.

	self assert: (result reportString includesSubstring: 'Methods: 0').
	self assert: (result reportString includesSubstring: 'not enough data to test')
]

{ #category : 'tests' }
HYEAccessorsTest >> testSamplerAccessorsAndExclusionOfReferences [
	"The pool and the generator can be read; exclusions can be given as references and add up"

	| random sampler scheme entries a b |
	random := Random seed: 3.
	scheme := HYEGroupScheme returnPoints.
	sampler := (HYEMethodSampler scheme: scheme)
		           pool: MetricsTestData methods;
		           random: random;
		           yourself.
	a := (MetricsTestData methods select: [ :method | (scheme measure: method) = 0 ]) collect: [ :method |
		     HYEMethodRef fromCompiledMethod: method ].
	b := Set withAll: (a first: 3).
	sampler excluding: b.
	sampler excluding: (a allButFirst: 3).

	self assert: sampler random equals: random.
	self assert: sampler pool size equals: MetricsTestData methods size.
	entries := (sampler sample: (Dictionary new
			             at: (scheme groupNamed: 'G1') put: 100;
			             yourself)) at: (scheme groupNamed: 'G1').
	self assert: (entries select: [ :entry | a includes: entry ref ]) isEmpty
]

{ #category : 'tests' }
HYEAccessorsTest >> testSamplerSkipsMethodsThatCannotBeMeasured [
	"A method that raises an error when measured is not drawn and does not stop the sampling"

	| scheme sampler entries |
	scheme := HYEGroupScheme
		          name: 'broken'
		          metric: 'x'
		          block: [ :method |
				          method selector = #mixedSends
					          ifTrue: [ self error: 'cannot' ]
					          ifFalse: [ 1 ] ]
		          groups: { (HYEMethodGroup
				           name: 'G1'
				           label: 'all'
				           lower: 0
				           upper: nil) }.
	sampler := (HYEMethodSampler scheme: scheme)
		           pool: {
				           (MetricsTestData >> #mixedSends).
				           (MetricsTestData >> #noSends) };
		           yourself.

	entries := (sampler sample: (Dictionary new
			             at: scheme groups first put: 5;
			             yourself)) at: scheme groups first.

	self assert: (entries collect: [ :entry | entry ref selector ]) asArray equals: #( #noSends )
]

{ #category : 'tests' }
HYEAccessorsTest >> testTierBasedIgnoresToolsThatAreNotInThePredictions [
	"A tool of the order that gave no prediction at all is skipped"

	| strategy |
	strategy := HYETierBasedStrategy new
		            tierOrder: #( 'Ghost' 'B' );
		            yourself.

	self assert: (strategy merge: { (HYEToolPrediction tool: 'B' type: 'X') }) keys equals: #( 'X' )
]
