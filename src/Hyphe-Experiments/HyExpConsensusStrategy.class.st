"
Consensus: the answer is a type only if all the tools agree on it, that is every tool answered and said the same. Otherwise the strategy abstains.
"
Class {
	#name : 'HyExpConsensusStrategy',
	#superclass : 'HyExpMergeStrategy',
	#category : 'Hyphe-Experiments-Merging',
	#package : 'Hyphe-Experiments',
	#tag : 'Merging'
}

{ #category : 'accessing' }
HyExpConsensusStrategy class >> defaultName [
	"Name of the strategy"

	^ 'Consensus'
]

{ #category : 'merging' }
HyExpConsensusStrategy >> merge: somePredictions [
	"The common answer of all the tools, or no answer"

	^ (self unanimousResultIn: somePredictions) ifNil: [ self nothing ]
]
