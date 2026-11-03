"
Voting confidence: every answer is a vote for its type(s) worth its confidence (1 for a tool that gives none) times the weight of the tool, shared among the types of a set; the type with the highest total wins. The confidence of the result is the share of the winner in all the votes. Two types with the same total are a tie: the strategy abstains.
"
Class {
	#name : 'HyVotingConfidenceStrategy',
	#superclass : 'HyExpMergeStrategy',
	#category : 'Hyphe-Experiments-Merging',
	#package : 'Hyphe-Experiments',
	#tag : 'Merging'
}

{ #category : 'accessing' }
HyVotingConfidenceStrategy class >> defaultName [
	"Name of the strategy"

	^ 'VotingConfidence'
]

{ #category : 'merging' }
HyVotingConfidenceStrategy >> merge: somePredictions [
	"The type that gets the most confidence, no answer if there is no vote or a tie"

	| votes |
	votes := self bestVotesIn: somePredictions.
	(votes first isNil or: [ votes last size > 1 ]) ifTrue: [ ^ self nothing ].
	^ HyToolPrediction
		  tool: self name
		  types: (self predictionOfKey: votes first key in: somePredictions)
		  confidence: votes first value
]
