"
An experiment on the effect of a property of the methods (the number of return points, of statements...) on the quality of type inference. It has a group scheme, a dataset of methods with their ground truth (grouped by the scheme), the tools, the merging strategies and the comparison policy. run answers a HyExperimentResult: for each method, the answer of each tool, the answer of each strategy on these answers, and their comparison with the truth. Use: HyExperiment name: 'return points' scheme: HyGroupScheme returnPoints dataset: dataset tools: tools; then run.
"
Class {
	#name : 'HyExperiment',
	#superclass : 'Object',
	#instVars : [
		'name',
		'scheme',
		'dataset',
		'tools',
		'strategies',
		'policy'
	],
	#category : 'Hyphe-Experiments-Analysis',
	#package : 'Hyphe-Experiments',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
HyExperiment class >> name: aName scheme: aGroupScheme dataset: aDataset tools: someTools [
	"Create an experiment with the five standard strategies (the first tool marked as AST based, or the one named AST-based, favoured by the biased ones; the order of the tools is their reliability for the tier based one) and the default comparison policy"

	| experiment astTool |
	experiment := self new.
	astTool := someTools detect: [ :tool | tool isAstBased ] ifNone: [ someTools first ].
	experiment
		setName: aName
		scheme: aGroupScheme
		dataset: aDataset
		tools: someTools.
	experiment strategies: (HyExpMergeStrategy allWithAstTool: astTool name tierOrder: (someTools collect: [ :tool | tool name ])).
	^ experiment
]

{ #category : 'accessing' }
HyExperiment >> dataset [
	"Answer the dataset, grouped with the scheme"

	^ dataset
]

{ #category : 'accessing' }
HyExperiment >> name [
	"Answer the name of the experiment"

	^ name
]

{ #category : 'accessing' }
HyExperiment >> policy [
	"Answer the rules to compare predictions with the truth"

	^ policy
]

{ #category : 'accessing' }
HyExperiment >> policy: anObject [
	"Set the rules to compare predictions with the truth"

	policy := anObject
]

{ #category : 'Protocol (running) - 2 selector(s)' }
HyExperiment >> rowFor: anEntry [
	"Answer the row of a method: predictions of the tools (r replaced by the class of the method, prepared by the policy), of the strategies, and outcomes"

	| toolPredictions predictions outcomes |
	toolPredictions := tools collect: [ :tool | policy prepared: ((tool predictionFor: anEntry ref) resolvedFor: anEntry ref) ].
	predictions := Dictionary new.
	outcomes := Dictionary new.
	tools with: toolPredictions do: [ :tool :prediction | predictions at: tool name put: prediction ].
	strategies do: [ :strategy | predictions at: strategy name put: (strategy merge: toolPredictions) ].
	predictions keysAndValuesDo: [ :source :prediction | outcomes at: source put: (policy outcomeOf: prediction for: anEntry) ].
	^ HyExperimentRow entry: anEntry predictions: predictions outcomes: outcomes
]

{ #category : 'running' }
HyExperiment >> run [
	"Ask each tool its answer for each method of the dataset that has a group and a ground truth, merge the answers with each strategy, compare everything with the truth. Answer a HyExperimentResult."

	| rows |
	rows := OrderedCollection new.
	dataset entries do: [ :entry | (entry group notNil and: [ entry truth notNil ]) ifTrue: [ rows add: (self rowFor: entry) ] ].
	^ HyExperimentResult experiment: self rows: rows
]

{ #category : 'accessing' }
HyExperiment >> scheme [
	"Answer the group scheme"

	^ scheme
]

{ #category : 'initialization' }
HyExperiment >> setName: aName scheme: aGroupScheme dataset: aDataset tools: someTools [
	"Set the parts of the experiment; the dataset is grouped with the scheme"

	name := aName.
	scheme := aGroupScheme.
	dataset := aDataset.
	tools := someTools.
	strategies := OrderedCollection new.
	policy := HyComparisonPolicy new.
	dataset assignGroups: scheme
]

{ #category : 'accessing' }
HyExperiment >> strategies [
	"Answer the merging strategies"

	^ strategies
]

{ #category : 'accessing' }
HyExperiment >> strategies: anObject [
	"Set the merging strategies"

	strategies := anObject
]

{ #category : 'accessing' }
HyExperiment >> strategyNames [
	"Answer the names of the strategies"

	^ strategies collect: [ :strategy | strategy name ]
]

{ #category : 'accessing' }
HyExperiment >> toolNames [
	"Answer the names of the tools"

	^ tools collect: [ :tool | tool name ]
]

{ #category : 'accessing' }
HyExperiment >> tools [
	"Answer the inference tools, in order of reliability"

	^ tools
]
