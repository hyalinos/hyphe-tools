"
End to end tests of an experiment on eight methods (two per group of return points) with four tools made of blocks: Good (always right), Bad (always wrong), Half (right in G1 and G2, wrong in G3 and G4, with a confidence of 0.9) and Silent (never answers).
"
Class {
	#name : 'HYEExperimentTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#instVars : [
		'result'
	],
	#category : 'Hyphe-Experiments-Tests-Analysis',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Analysis'
}

{ #category : 'helpers' }
HYEExperimentTest >> dataset [
	"The dataset of the eight methods"

	| dataset |
	dataset := HYEGroundTruthDataset named: 'eight'.
	self truths do: [ :association | dataset add: (self entryOf: association key truth: association value) ].
	^ dataset
]

{ #category : 'helpers' }
HYEExperimentTest >> group: aName [
	"The group of the scheme with this name"

	^ HYEGroupScheme returnPoints groupNamed: aName
]

{ #category : 'running' }
HYEExperimentTest >> setUp [
	"Run the experiment"

	super setUp.
	result := (HYEExperiment
		           name: 'test'
		           scheme: HYEGroupScheme returnPoints
		           dataset: self dataset
		           tools: self tools) run
]

{ #category : 'tests' }
HYEExperimentTest >> testAccuracyDependsOnTheGroupForHalf [
	"All right in G1 and G2, all wrong in G3 and G4: significant dependence"

	| test |
	test := result accuracyChiSquareOf: 'Half'.

	self assert: (test statistic closeTo: 8.0).
	self assert: (test isSignificantAt: 0.05).
	self deny: ((result accuracyChiSquareOf: 'Good') isSignificantAt: 0.05).
	self assert: (result accuracyChiSquareOf: 'Silent') statistic isNil
]

{ #category : 'tests' }
HYEExperimentTest >> testAccuracyOfTheTools [
	"Good is always right, Bad never, Half in the first two groups, Silent answers nothing"

	result groups do: [ :group |
			self assert: (result accuracyOf: 'Good' in: group) equals: 1.
			self assert: (result accuracyOf: 'Bad' in: group) equals: 0.
			self assert: (result accuracyOf: 'Silent' in: group) isNil.
			self assert: (result coverageOf: 'Silent' in: group) equals: 0.
			self assert: (result coverageOf: 'Good' in: group) equals: 1 ].
	self assert: (result accuracyOf: 'Half' in: (self group: 'G1')) equals: 1.
	self assert: (result accuracyOf: 'Half' in: (self group: 'G2')) equals: 1.
	self assert: (result accuracyOf: 'Half' in: (self group: 'G3')) equals: 0.
	self assert: (result accuracyOf: 'Half' in: (self group: 'G4')) equals: 0
]

{ #category : 'tests' }
HYEExperimentTest >> testAgreement [
	"Good, Bad and Half all answer: they agree only in no group"

	result groups do: [ :group | self assert: (result agreementRateIn: group) equals: 0 ].
	self assert: (result agreeingRowsIn: (self group: 'G1')) equals: 0 -> 2
]

{ #category : 'tests' }
HYEExperimentTest >> testBestStrategyPerGroup [
	"BiasedConsensus (the first of the strategies that are always right) wins everywhere, so it does not change"

	result groups do: [ :group | self assert: (result bestStrategyIn: group) equals: 'BiasedConsensus' ].
	self deny: result bestStrategyChanges
]

{ #category : 'tests' }
HYEExperimentTest >> testBestStrategyTieGoesToTheFirstInTheList [
	"With one tool that is always wrong all the strategies have an accuracy of 0 and a coverage of 1: the first one is the best"

	| other |
	other := (HYEExperiment
		          name: 'other'
		          scheme: HYEGroupScheme returnPoints
		          dataset: self dataset
		          tools: { (HYEBlockTool name: 'Only' block: [ :ref | 'Wrong' ]) beAstBased }) run.

	self assert: (other bestStrategyIn: (self group: 'G1')) equals: 'Consensus'.
	self assert: (other accuracyOf: 'BiasedConsensus' in: (self group: 'G1')) equals: 0
]

{ #category : 'tests' }
HYEExperimentTest >> testConfidence [
	"Half says 0.9 each time, Good gives no confidence"

	| stats |
	stats := result confidenceStatsOf: 'Half' in: (self group: 'G2').

	self assert: (stats at: #count) equals: 2.
	self assert: ((stats at: #mean) closeTo: 0.9).
	self assert: ((stats at: #standardDeviation) closeTo: 0.0).
	self assert: ((stats at: #min) closeTo: 0.9).
	self assert: (result confidenceStatsOf: 'Good' in: (self group: 'G2')) equals: (Dictionary new
			 at: #count put: 0;
			 at: #mean put: nil;
			 at: #standardDeviation put: nil;
			 at: #min put: nil;
			 at: #max put: nil;
			 yourself)
]

{ #category : 'tests' }
HYEExperimentTest >> testExcludedAndAbstainedAreTallied [
	"Entries with an unknown truth are excluded, silent tools abstain"

	| dataset experiment tally |
	dataset := self dataset.
	dataset add: (self entryOf: (self refOf: #repeatedSends in: MetricsTestData) truth: '?').
	dataset add: (self entryOf: (self refOf: #cascadeOfSends in: MetricsTestData) truth: nil).
	experiment := HYEExperiment
		              name: 'x'
		              scheme: HYEGroupScheme returnPoints
		              dataset: dataset
		              tools: self tools.
	result := experiment run.
	tally := result tallyOf: 'Silent' in: (self group: 'G1').

	self assert: result rows size equals: 9.
	self assert: tally abstained equals: 2.
	self assert: tally excluded equals: 1.
	self assert: (result tallyOf: 'Good' in: (self group: 'G1')) excluded equals: 1
]

{ #category : 'tests' }
HYEExperimentTest >> testExperimentNamesAndStrategies [
	"The experiment knows its tools and strategies, the standard strategies are used"

	| experiment |
	experiment := HYEExperiment
		              name: 'x'
		              scheme: HYEGroupScheme returnPoints
		              dataset: self dataset
		              tools: self tools.

	self assert: experiment toolNames asArray equals: #( 'Good' 'Bad' 'Half' 'Silent' ).
	self assert: experiment strategyNames size equals: 5.
	self assert: experiment strategies second astToolName equals: 'Good'.
	self assert: experiment strategies third tierOrder equals: #( 'Good' 'Bad' 'Half' 'Silent' )
]

{ #category : 'Protocol (tests) - 19 selector(s)' }
HYEExperimentTest >> testExperimentOneRulesAreApplied [
	"A tool that says Object does not answer (nor vote), ByteString is String, and a truth Object is left out"

	| experiment |
	experiment := HYEExperiment
		              name: 'x'
		              scheme: HYEGroupScheme returnPoints
		              dataset: self dataset
		              tools: {
				              (HYEBlockTool name: 'Anything' block: [ :ref | 'Object' ]).
				              (HYEBlockTool name: 'Bytes' block: [ :ref | 'ByteString' ]) }.
	experiment policy: HYEComparisonPolicy experimentOne.
	result := experiment run.
	result rows do: [ :row |
			self assert: (row predictionOf: 'Anything') isNothing.
			self assert: (row predictionOf: 'VotingConfidence') types keys equals: #( 'String' ).
			self assert: (row outcomeOf: 'Anything') equals: (row entry truth classNames asArray = #( 'Object' )
					 ifTrue: [ #excluded ]
					 ifFalse: [ #abstained ]).
			row entry truth classNames asArray = #( 'String' ) ifTrue: [ self assert: (row outcomeOf: 'Bytes') equals: #correct ] ]
]

{ #category : 'tests' }
HYEExperimentTest >> testMethodsNotInTheImageAreLeftOut [
	"A method that is not in the image has no group: it is not a row"

	| dataset |
	dataset := self dataset.
	dataset add: (self entryOf: (HYEMethodRef package: 'P' class: 'NoSuchClassAnywhere' selector: #foo) truth: 'Integer').

	result := (HYEExperiment
		           name: 'x'
		           scheme: HYEGroupScheme returnPoints
		           dataset: dataset
		           tools: self tools) run.

	self assert: result rows size equals: 8
]

{ #category : 'tests' }
HYEExperimentTest >> testPairwiseAgreement [
	"Good and Half agree in G1 and G2 and disagree in G3 and G4; nobody agrees with Bad"

	| pairs |
	pairs := result pairwiseAgreementIn: (self group: 'G1').
	self assert: (pairs at: { 'Good'. 'Half' }) equals: 1.
	self assert: (pairs at: { 'Good'. 'Bad' }) equals: 0.
	self assert: (pairs at: { 'Good'. 'Silent' }) isNil.

	self assert: ((result pairwiseAgreementIn: (self group: 'G3')) at: { 'Good'. 'Half' }) equals: 0
]

{ #category : 'tests' }
HYEExperimentTest >> testPolicyIsUsed [
	"With the policy where abstaining is an error, Silent is incorrect everywhere"

	| experiment |
	experiment := HYEExperiment
		              name: 'x'
		              scheme: HYEGroupScheme returnPoints
		              dataset: self dataset
		              tools: self tools.
	experiment policy abstention: #incorrect.
	result := experiment run.

	self assert: (result accuracyOf: 'Silent' in: (self group: 'G1')) equals: 0.
	self assert: (result tallyOf: 'Silent' in: (self group: 'G1')) incorrect equals: 2
]

{ #category : 'tests' }
HYEExperimentTest >> testReceiverAnswersAreResolved [
	"A tool that says r and one that says the class agree"

	| dataset experiment row |
	dataset := HYEGroundTruthDataset named: 'r'.
	dataset add: (self entryOf: (self refOf: #mixedSends in: MetricsTestData) truth: 'r').
	experiment := HYEExperiment
		              name: 'r'
		              scheme: HYEGroupScheme returnPoints
		              dataset: dataset
		              tools: {
				              (HYEBlockTool name: 'Self' block: [ :ref | 'r' ]) beAstBased.
				              (HYEBlockTool name: 'Class' block: [ :ref | 'MetricsTestData' ]) }.
	result := experiment run.
	row := result rows first.

	self assert: (row outcomeOf: 'Self') equals: #correct.
	self assert: (row outcomeOf: 'Class') equals: #correct.
	self assert: (row outcomeOf: 'Consensus') equals: #correct.
	self assert: (result agreementRateIn: (self group: 'G1')) equals: 1
]

{ #category : 'tests' }
HYEExperimentTest >> testReport [
	"The report has the title, the four research questions and the numbers"

	| report |
	report := result reportString.

	self assert: (report beginsWith: 'Experiment: test').
	self assert: (report includesSubstring: 'RQ1').
	self assert: (report includesSubstring: 'RQ2').
	self assert: (report includesSubstring: 'RQ3').
	self assert: (report includesSubstring: 'RQ4').
	self assert: (report includesSubstring: 'Half: G1=100.0%').
	self assert: (report includesSubstring: 'G3=0.0%').
	self assert: (report includesSubstring: 'chi2 = 8.00').
	self assert: (report includesSubstring: 'the best strategy does not change with the group')
]

{ #category : 'tests' }
HYEExperimentTest >> testRowsAndGroups [
	"One row per method, two in each group"

	self assert: result rows size equals: 8.
	result groups do: [ :group | self assert: (result rowsIn: group) size equals: 2 ].
	self
		assert: result sourceNames asArray
		equals: #( 'Good' 'Bad' 'Half' 'Silent' 'Consensus' 'BiasedConsensus' 'TierBased' 'VotingConfidence' 'BiasedVotingConfidence' )
]

{ #category : 'tests' }
HYEExperimentTest >> testStatementCountExperiment [
	"The same machinery works with the statement count scheme (G1: 1 statement)"

	| experiment other |
	experiment := HYEExperiment
		              name: 'statements'
		              scheme: HYEGroupScheme statementCount
		              dataset: self dataset
		              tools: { (HYEBlockTool name: 'Always Wrong' block: [ :ref | 'Wrong' ]) beAstBased }.
	other := experiment run.

	self assert: other rows size equals: 8.
	self assert: (other groups collect: [ :group | (other rowsIn: group) size ]) asArray sum equals: 8
]

{ #category : 'tests' }
HYEExperimentTest >> testStrategies [
	"Consensus never works with a silent tool; biased consensus and tier based follow Good; voting: in the first groups Good and Half beat Bad, then Bad and Half beat Good"

	(self group: 'G1') in: [ :g |
			self assert: (result accuracyOf: 'Consensus' in: g) isNil.
			self assert: (result accuracyOf: 'BiasedConsensus' in: g) equals: 1.
			self assert: (result accuracyOf: 'TierBased' in: g) equals: 1.
			self assert: (result accuracyOf: 'VotingConfidence' in: g) equals: 1.
			self assert: (result accuracyOf: 'BiasedVotingConfidence' in: g) equals: 1 ].
	(self group: 'G4') in: [ :g |
			self assert: (result accuracyOf: 'BiasedConsensus' in: g) equals: 1.
			self assert: (result accuracyOf: 'TierBased' in: g) equals: 1.
			self assert: (result accuracyOf: 'VotingConfidence' in: g) equals: 0.
			self assert: (result accuracyOf: 'BiasedVotingConfidence' in: g) equals: 0 ]
]

{ #category : 'tests' }
HYEExperimentTest >> testWriteMethodResults [
	"One line per method with the group, the truth, and each source with its outcome"

	| records file |
	file := result writeMethodResultsTo: (self memoryFile: 'rows.csv').
	records := HYECsv recordsFrom: file.

	self assert: records size equals: 8.
	self assert: (records first at: 'group') equals: 'G1'.
	self assert: (records first at: 'truth') equals: 'Object'.
	self assert: (records first at: 'good') equals: 'Object'.
	self assert: (records first at: 'good outcome') equals: 'correct'.
	self assert: (records first at: 'silent outcome') equals: 'abstained'.
	self assert: (records first at: 'countreturn') equals: '0'.
	self assert: (records first includesKey: 'biasedconsensus outcome')
]

{ #category : 'tests' }
HYEExperimentTest >> testWriteSummary [
	"One line per source and group with the counts and the rates"

	| records line |
	records := HYECsv recordsFrom: (result writeSummaryTo: (self memoryFile: 'summary.csv')).

	self assert: records size equals: 9 * 4.
	line := records detect: [ :record | (record at: 'source') = 'Half' and: [ (record at: 'group') = 'G3' ] ].
	self assert: (line at: 'correct') equals: '0'.
	self assert: (line at: 'incorrect') equals: '2'.
	self assert: (line at: 'accuracy') asNumber equals: 0.
	self assert: (line at: 'coverage') asNumber equals: 1.
	line := records detect: [ :record | (record at: 'source') = 'Silent' and: [ (record at: 'group') = 'G3' ] ].
	self assert: (line at: 'accuracy') equals: ''
]

{ #category : 'helpers' }
HYEExperimentTest >> tools [
	"The four tools; they know the truth of the eight methods only (for another method Good gives no answer, Half is wrong)"

	| truths |
	truths := Dictionary new.
	self truths do: [ :association | truths add: association ].
	^ {
		  (HYEBlockTool name: 'Good' block: [ :ref | truths at: ref ifAbsent: [ nil ] ]) beAstBased.
		  (HYEBlockTool name: 'Bad' block: [ :ref | 'Wrong' ]).
		  (HYEBlockTool name: 'Half' block: [ :ref |
				   | right |
				   right := (truths includesKey: ref) and: [
					            (HYEGroupScheme returnPoints groupFor: (HYEGroupScheme returnPoints measure: ref compiledMethod)) name <= 'G2' ].
				   HYEToolPrediction
					   tool: 'Half'
					   types: (HYETypeExpression parse: (right
								     ifTrue: [ truths at: ref ]
								     ifFalse: [ 'Wrong' ]))
					   confidence: 0.9 ]).
		  (HYEBlockTool name: 'Silent' block: [ :ref | nil ]) }
]

{ #category : 'helpers' }
HYEExperimentTest >> truths [
	"The ground truth of the eight methods: selector in class -> type"

	^ {
		  ((self refOf: #mixedSends in: MetricsTestData) -> 'Object').
		  ((self refOf: #sendsToSelf in: MetricsTestData) -> 'Object').
		  ((self refOf: #noSends in: MetricsTestData) -> 'SmallInteger').
		  ((self refOf: #referencesOneClass in: MetricsTestData) -> 'OrderedCollection').
		  ((self refOf: #twoReturns: in: HYEReturnPointsTestData) -> 'SmallInteger').
		  ((self refOf: #twoReturnsAgain: in: HYEReturnPointsTestData) -> 'String').
		  ((self refOf: #threeReturns: in: HYEReturnPointsTestData) -> 'SmallInteger').
		  ((self refOf: #threeReturnsAgain: in: HYEReturnPointsTestData) -> 'String') }
]
