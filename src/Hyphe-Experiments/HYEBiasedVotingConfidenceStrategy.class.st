"
Biased voting confidence: like voting confidence, but a tie is broken by the AST based tool: if it answered one of the tied types, that type wins. Abstains if the tie is not broken or there is no vote.
"
Class {
	#name : 'HYEBiasedVotingConfidenceStrategy',
	#superclass : 'HYEExpMergeStrategy',
	#category : 'Hyphe-Experiments-Merging',
	#package : 'Hyphe-Experiments',
	#tag : 'Merging'
}

{ #category : 'accessing' }
HYEBiasedVotingConfidenceStrategy class >> defaultName [
	"Name of the strategy"

	^ 'BiasedVotingConfidence'
]

{ #category : 'merging' }
HYEBiasedVotingConfidenceStrategy >> merge: somePredictions [
	"The type that gets the most confidence; in a tie, the type of the AST based tool if it is one of the tied ones"

	| votes winnerKey astKeys |
	votes := self bestVotesIn: somePredictions.
	votes first ifNil: [ ^ self nothing ].
	winnerKey := votes last size = 1
		             ifTrue: [ votes last first ]
		             ifFalse: [
				             astKeys := (self astPredictionIn: somePredictions) ifNil: [ #(  ) ] ifNotNil: [ :prediction | prediction keys ].
				             (votes last select: [ :key | astKeys includes: key ]) ifEmpty: [ nil ] ifNotEmpty: [ :keys | keys first ] ].
	winnerKey ifNil: [ ^ self nothing ].
	^ HYEToolPrediction tool: self name types: (self predictionOfKey: winnerKey in: somePredictions) confidence: votes first value
]
