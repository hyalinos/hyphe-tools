"
Biased consensus: like consensus, but when the tools do not all agree the AST based tool, if it answered, has priority and its answer is the one. Without agreement and without an answer of the AST based tool the strategy abstains.
"
Class {
	#name : 'HYEExpBiasedConsensusStrategy',
	#superclass : 'HYEExpMergeStrategy',
	#category : 'Hyphe-Experiments-Merging',
	#package : 'Hyphe-Experiments',
	#tag : 'Merging'
}

{ #category : 'accessing' }
HYEExpBiasedConsensusStrategy class >> defaultName [
	"Name of the strategy"

	^ 'BiasedConsensus'
]

{ #category : 'merging' }
HYEExpBiasedConsensusStrategy >> merge: somePredictions [
	"The common answer of all the tools; else the answer of the AST based tool; else no answer"

	(self unanimousResultIn: somePredictions) ifNotNil: [ :result | ^ result ].
	^ (self astPredictionIn: somePredictions) ifNil: [ self nothing ] ifNotNil: [ :prediction | self resultFrom: prediction ]
]
