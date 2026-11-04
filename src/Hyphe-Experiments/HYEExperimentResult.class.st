"
The result of an experiment, and the analysis for the research questions. RQ1, does the group (number of return points, statements...) change the accuracy: accuracyOf:in:, tallyOf:in:, accuracyChiSquareOf: for each tool and strategy. RQ2, does it change the agreement between tools: agreementRateIn:, pairwiseAgreementIn:, agreementChiSquare. RQ3, does it change the confidence of the tools: confidenceStatsOf:in:. RQ4, does the best merging strategy change with the group: bestStrategyIn:, bestStrategyByGroup, bestStrategyChanges. reportString writes all of it as text, writeMethodResultsTo: and writeSummaryTo: as CSV files. A source is a tool or a strategy, by its name.
"
Class {
	#name : 'HYEExperimentResult',
	#superclass : 'Object',
	#instVars : [
		'experiment',
		'rows'
	],
	#category : 'Hyphe-Experiments-Analysis',
	#package : 'Hyphe-Experiments',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
HYEExperimentResult class >> experiment: anExperiment rows: someRows [
	"Create the result of an experiment"

	^ self new
		  setExperiment: anExperiment rows: someRows;
		  yourself
]

{ #category : 'Protocol (testing) - 1 selector(s)' }
HYEExperimentResult >> accuracyChiSquareOf: aSourceName [
	"Answer the chi-square test of the dependence between the group and being correct, among the answers of a tool or strategy (a table correct / not correct by group): does the number of return points (statements...) change its accuracy?"

	| tallies |
	tallies := self groups collect: [ :group | self tallyOf: aSourceName in: group ].
	^ HYEChiSquareTest on: {
			  (tallies collect: [ :tally | tally correct ]).
			  (tallies collect: [ :tally | tally partial + tally related + tally incorrect ]) }
]

{ #category : 'RQ1 accuracy' }
HYEExperimentResult >> accuracyOf: aSourceName in: aGroup [
	"Answer the proportion of correct answers among the answers of a tool or strategy in a group; nil if it gave none"

	^ (self tallyOf: aSourceName in: aGroup) accuracy
]

{ #category : 'RQ2 agreement' }
HYEExperimentResult >> agreeingRowsIn: aGroup [
	"Answer an association: the number of the methods of a group where all the tools that answered say the same -> the number of methods where at least two tools answered (agreement needs two answers)"

	| considered agreeing |
	considered := 0.
	agreeing := 0.
	(self rowsIn: aGroup) do: [ :row |
			| answers |
			answers := self toolAnswersOf: row.
			answers size >= 2 ifTrue: [
					considered := considered + 1.
					(answers allSatisfy: [ :prediction | prediction keys = answers first keys ]) ifTrue: [ agreeing := agreeing + 1 ] ] ].
	^ agreeing -> considered
]

{ #category : 'RQ2 agreement' }
HYEExperimentResult >> agreementChiSquare [
	"Answer the chi-square test of the dependence between the group and the agreement of the tools (a table agree / disagree by group): does the number of return points (statements...) change how much the tools agree?"

	| counts |
	counts := self groups collect: [ :group | self agreeingRowsIn: group ].
	^ HYEChiSquareTest on: {
			  (counts collect: [ :each | each key ]).
			  (counts collect: [ :each | each value - each key ]) }
]

{ #category : 'RQ2 agreement' }
HYEExperimentResult >> agreementRateIn: aGroup [
	"Answer the proportion of the methods of a group, among the ones where at least two tools answered, where all the answering tools say the same; nil if there is no such method"

	| counts |
	counts := self agreeingRowsIn: aGroup.
	^ counts value = 0 ifFalse: [ counts key / counts value ]
]

{ #category : 'RQ4 strategies' }
HYEExperimentResult >> bestStrategyByGroup [
	"Answer a dictionary group -> name of its best strategy"

	| result |
	result := Dictionary new.
	self groups do: [ :group | result at: group put: (self bestStrategyIn: group) ].
	^ result
]

{ #category : 'RQ4 strategies' }
HYEExperimentResult >> bestStrategyChanges [
	"Answer true if the best strategy is not the same in all the groups where some strategy answered"

	^ (self bestStrategyByGroup values reject: #isNil) asSet size > 1
]

{ #category : 'RQ4 strategies' }
HYEExperimentResult >> bestStrategyIn: aGroup [
	"Answer the name of the merging strategy with the best accuracy in a group; in a tie the one that answers more, then the first in the list. nil if no strategy answered."

	| best bestKey |
	best := nil.
	self strategyNames do: [ :name |
			| tally key |
			tally := self tallyOf: name in: aGroup.
			tally accuracy ifNotNil: [ :accuracy |
					key := {
						       accuracy.
						       tally coverage }.
					(bestKey isNil or: [ key first > bestKey first or: [ key first = bestKey first and: [ key last > bestKey last ] ] ]) ifTrue: [
							best := name.
							bestKey := key ] ] ].
	^ best
]

{ #category : 'RQ3 confidence' }
HYEExperimentResult >> confidenceStatsOf: aSourceName in: aGroup [
	"Answer a dictionary count, mean, standardDeviation, min, max of the confidences a tool or strategy gave in a group (only the answers that have a confidence); count is 0 and the others nil if there is none"

	| values mean |
	values := ((self rowsIn: aGroup) collect: [ :row | (row predictionOf: aSourceName) confidence ]) reject: #isNil.
	values isEmpty ifTrue: [
			^ Dictionary new
				  at: #count put: 0;
				  at: #mean put: nil;
				  at: #standardDeviation put: nil;
				  at: #min put: nil;
				  at: #max put: nil;
				  yourself ].
	mean := values sum / values size.
	^ Dictionary new
		  at: #count put: values size;
		  at: #mean put: mean asFloat;
		  at: #standardDeviation put: (values size < 2
				   ifTrue: [ 0.0 ]
				   ifFalse: [ ((values inject: 0 into: [ :sum :value | sum + (value - mean) squared ]) / (values size - 1)) sqrt asFloat ]);
		  at: #min put: values min;
		  at: #max put: values max;
		  yourself
]

{ #category : 'RQ1 accuracy' }
HYEExperimentResult >> coverageOf: aSourceName in: aGroup [
	"Answer the proportion of the methods of a group a tool or strategy answered; nil if there is none"

	^ (self tallyOf: aSourceName in: aGroup) coverage
]

{ #category : 'reporting' }
HYEExperimentResult >> describe: aChiSquare on: aStream [
	"Write the statistic, the p-value and Cramer's V of a chi-square test on a stream"

	aChiSquare statistic ifNil: [
			^ aStream
				  nextPutAll: 'not enough data to test';
				  lf ].
	aStream
		nextPutAll: 'chi2 = ';
		nextPutAll: (aChiSquare statistic printShowingDecimalPlaces: 2);
		nextPutAll: ', df = ';
		print: aChiSquare degreesOfFreedom;
		nextPutAll: ', p = ';
		nextPutAll: (aChiSquare pValue printShowingDecimalPlaces: 4);
		nextPutAll: ', Cramer''s V = ';
		nextPutAll: (aChiSquare cramersV printShowingDecimalPlaces: 3);
		lf
]

{ #category : 'accessing' }
HYEExperimentResult >> experiment [
	"Answer the experiment"

	^ experiment
]

{ #category : 'accessing' }
HYEExperimentResult >> groups [
	"Answer the groups of the scheme"

	^ experiment scheme groups
]

{ #category : 'RQ2 agreement' }
HYEExperimentResult >> pairwiseAgreementIn: aGroup [
	"Answer a dictionary { tool name. tool name } -> proportion of the methods of a group where both tools answered and said the same (nil if they never both answered)"

	| result names |
	result := Dictionary new.
	names := self toolNames.
	names withIndexDo: [ :first :i |
			(names copyFrom: i + 1 to: names size) do: [ :second |
					| both same |
					both := 0.
					same := 0.
					(self rowsIn: aGroup) do: [ :row |
							| a b |
							a := row predictionOf: first.
							b := row predictionOf: second.
							(a isNothing or: [ b isNothing ]) ifFalse: [
									both := both + 1.
									a keys = b keys ifTrue: [ same := same + 1 ] ] ].
					result
						at: {
								first.
								second }
						put: (both = 0 ifFalse: [ same / both ]) ] ].
	^ result
]

{ #category : 'reporting' }
HYEExperimentResult >> percent: aNumberOrNil [
	"Answer a number as a percentage with one decimal, - if there is none"

	^ aNumberOrNil ifNil: [ '-' ] ifNotNil: [ :number | (number * 100) asFloat printShowingDecimalPlaces: 1 ]
]

{ #category : 'reporting' }
HYEExperimentResult >> reportString [
	"Answer the analysis of the four research questions as text: accuracy and coverage of each tool and strategy per group and the test of the dependence on the group (RQ1), the agreement of the tools (RQ2), the confidence (RQ3) and the best strategy per group (RQ4)"

	^ String streamContents: [ :stream |
			  stream
				  nextPutAll: 'Experiment: ';
				  nextPutAll: experiment name;
				  lf.
			  stream
				  nextPutAll: 'Methods: ';
				  print: rows size;
				  nextPutAll: ' ('.
			  self groups
				  do: [ :group |
						  stream
							  nextPutAll: group name;
							  nextPut: $=;
							  print: (self rowsIn: group) size ]
				  separatedBy: [ stream space ].
			  stream
				  nextPut: $);
				  lf;
				  lf.

			  stream
				  nextPutAll: 'RQ1 - accuracy (% correct among answers), answers/methods, per group';
				  lf.
			  self sourceNames do: [ :source |
					  stream
						  nextPutAll: source;
						  nextPutAll: ': '.
					  self groups
						  do: [ :group |
								  | tally |
								  tally := self tallyOf: source in: group.
								  stream
									  nextPutAll: group name;
									  nextPut: $=;
									  nextPutAll: (self percent: tally accuracy);
									  nextPutAll: '% ';
									  print: tally answered;
									  nextPut: $/;
									  print: tally evaluated ]
						  separatedBy: [ stream nextPutAll: ' | ' ].
					  stream lf.
					  stream nextPutAll: '    dependence on the group: '.
					  self describe: (self accuracyChiSquareOf: source) on: stream ].
			  stream lf.

			  stream
				  nextPutAll: 'RQ2 - agreement of the tools (when at least two answered)';
				  lf.
			  self groups do: [ :group |
					  stream
						  nextPutAll: group name;
						  nextPutAll: ': ';
						  nextPutAll: (self percent: (self agreementRateIn: group));
						  nextPutAll: '% of ';
						  print: (self agreeingRowsIn: group) value;
						  lf ].
			  stream nextPutAll: 'dependence on the group: '.
			  self describe: self agreementChiSquare on: stream.
			  stream lf.

			  stream
				  nextPutAll: 'RQ3 - confidence given by the tools (mean, number of answers with a confidence)';
				  lf.
			  self sourceNames do: [ :source |
					  stream
						  nextPutAll: source;
						  nextPutAll: ': '.
					  self groups
						  do: [ :group |
								  | stats |
								  stats := self confidenceStatsOf: source in: group.
								  stream
									  nextPutAll: group name;
									  nextPut: $=;
									  nextPutAll: ((stats at: #mean) ifNil: [ '-' ] ifNotNil: [ :mean | mean printShowingDecimalPlaces: 2 ]);
									  nextPutAll: ' (';
									  print: (stats at: #count);
									  nextPut: $) ]
						  separatedBy: [ stream nextPutAll: ' | ' ].
					  stream lf ].
			  stream lf.

			  stream
				  nextPutAll: 'RQ4 - best merging strategy per group';
				  lf.
			  self groups do: [ :group |
					  stream
						  nextPutAll: group name;
						  nextPutAll: ': ';
						  nextPutAll: ((self bestStrategyIn: group) ifNil: [ '-' ]);
						  lf ].
			  stream
				  nextPutAll: 'the best strategy ';
				  nextPutAll: (self bestStrategyChanges
						   ifTrue: [ 'changes with' ]
						   ifFalse: [ 'does not change with' ]);
				  nextPutAll: ' the group';
				  lf ]
]

{ #category : 'accessing' }
HYEExperimentResult >> rows [
	"Answer the rows, one per method"

	^ rows
]

{ #category : 'accessing' }
HYEExperimentResult >> rowsIn: aGroup [
	"Answer the rows of the methods of a group"

	^ rows select: [ :row | row group = aGroup ]
]

{ #category : 'initialization' }
HYEExperimentResult >> setExperiment: anExperiment rows: someRows [
	"Set the experiment and the rows"

	experiment := anExperiment.
	rows := someRows
]

{ #category : 'accessing' }
HYEExperimentResult >> sourceNames [
	"Answer the names of the tools, then of the strategies"

	^ self toolNames , self strategyNames
]

{ #category : 'accessing' }
HYEExperimentResult >> strategyNames [
	"Answer the names of the merging strategies"

	^ experiment strategyNames
]

{ #category : 'RQ1 accuracy' }
HYEExperimentResult >> tallyOf: aSourceName in: aGroup [
	"Answer the outcomes of a tool or a strategy for the methods of a group (HYEOutcomeTally)"

	| tally |
	tally := HYEOutcomeTally new.
	(self rowsIn: aGroup) do: [ :row | tally add: (row outcomeOf: aSourceName) ].
	^ tally
]

{ #category : 'RQ2 agreement' }
HYEExperimentResult >> toolAnswersOf: aRow [
	"Answer the predictions of the tools (not the strategies) that gave an answer"

	^ (self toolNames collect: [ :name | aRow predictionOf: name ]) reject: [ :prediction | prediction isNothing ]
]

{ #category : 'accessing' }
HYEExperimentResult >> toolNames [
	"Answer the names of the tools"

	^ experiment toolNames
]

{ #category : 'exporting' }
HYEExperimentResult >> writeMethodResultsTo: aFileOrString [
	"Write one line per method: package, class, selector, group, measure, truth, then for each tool and each strategy its answer and its outcome. Answer the file."

	| header sources |
	sources := self sourceNames.
	header := #( 'package' 'class' 'selector' 'group' ) , {
		          experiment scheme metricName.
		          'truth' } , (sources gather: [ :name |
			           {
				           name.
				           (name , ' outcome') } ]).
	^ HYECsv
		  write: { header } , (rows collect: [ :row |
					   {
						   row entry ref package.
						   row entry ref className.
						   row entry ref selector.
						   row group name.
						   row entry count.
						   row entry truth } , (sources gather: [ :source |
							    {
								    (row predictionOf: source) types.
								    (row outcomeOf: source) } ]) ])
		  to: aFileOrString
]

{ #category : 'exporting' }
HYEExperimentResult >> writeSummaryTo: aFileOrString [
	"Write one line per source and group: the counts of the outcomes, accuracy, accuracy counting partial answers as correct, coverage. Answer the file."

	| lines |
	lines := OrderedCollection with:
		         #( 'source' 'group' 'evaluated' 'answered' 'correct' 'partial' 'incorrect' 'abstained' 'excluded' 'accuracy' 'accuracyWithPartial'
		            'coverage' ).
	self sourceNames do: [ :source |
			self groups do: [ :group |
					| tally |
					tally := self tallyOf: source in: group.
					lines add: {
							source.
							group name.
							tally evaluated.
							tally answered.
							tally correct.
							tally partial.
							tally incorrect.
							tally abstained.
							tally excluded.
							(tally accuracy ifNotNil: [ :x | x asFloat ]).
							(tally accuracyWithPartial ifNotNil: [ :x | x asFloat ]).
							(tally coverage ifNotNil: [ :x | x asFloat ]) } ] ].
	^ HYECsv write: lines to: aFileOrString
]
