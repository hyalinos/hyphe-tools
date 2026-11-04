"
Tier based: the tools are ranked by reliability (tierOrder, or the order of the predictions) and the answer of the highest ranked tool that answered is used. Abstains if no tool answered.
"
Class {
	#name : 'HYETierBasedStrategy',
	#superclass : 'HYEExpMergeStrategy',
	#category : 'Hyphe-Experiments-Merging',
	#package : 'Hyphe-Experiments',
	#tag : 'Merging'
}

{ #category : 'accessing' }
HYETierBasedStrategy class >> defaultName [
	"Name of the strategy"

	^ 'TierBased'
]

{ #category : 'merging' }
HYETierBasedStrategy >> merge: somePredictions [
	"The answer of the most reliable tool that answered"

	| ranked |
	ranked := tierOrder ifNil: [ somePredictions ] ifNotNil: [ :order |
			          (order collect: [ :toolName |
				           somePredictions detect: [ :prediction | prediction toolName = toolName ] ifNone: [ nil ] ]) reject: #isNil ].
	^ (self answeredBy: ranked) ifEmpty: [ self nothing ] ifNotEmpty: [ :answers | self resultFrom: answers first ]
]
