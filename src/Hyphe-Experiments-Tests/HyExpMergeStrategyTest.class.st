"
Tests of the five merging strategies: agreement, disagreement, tools without answer, bias towards the AST based tool, confidences.
"
Class {
	#name : 'HyExpMergeStrategyTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Merging',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Merging'
}

{ #category : 'helpers' }
HyExpMergeStrategyTest >> keysOf: aPrediction [
	"Answer the type of a prediction as keys, #() for no answer"

	^ aPrediction keys asArray
]

{ #category : 'helpers' }
HyExpMergeStrategyTest >> predictions: someAssociations [
	"Answer predictions from associations tool name -> type (nil for no answer)"

	^ someAssociations collect: [ :association | HyToolPrediction tool: association key type: association value ]
]

{ #category : 'helpers' }
HyExpMergeStrategyTest >> strategy: aClass [
	"Answer a strategy with AST as the AST based tool and AST, Name, Profiler as the order of reliability"

	^ aClass new
		  astToolName: 'AST';
		  tierOrder: #( 'AST' 'Name' 'Profiler' );
		  yourself
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testBiasedConsensusFollowsTheAstToolWithoutAgreement [
	"Without agreement the AST based tool decides; without it, no answer"

	| strategy |
	strategy := self strategy: HyExpBiasedConsensusStrategy.

	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> 'Integer').
							   ('Name' -> 'String').
							   ('Profiler' -> nil) })))
		equals: #( 'Integer' ).
	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> 'Integer').
							   ('Name' -> 'Integer').
							   ('Profiler' -> 'Integer') })))
		equals: #( 'Integer' ).
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> nil).
					  ('Name' -> 'String').
					  ('Profiler' -> 'Integer') })) isNothing.
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> nil).
					  ('Name' -> nil).
					  ('Profiler' -> nil) })) isNothing
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testBiasedVotingBreaksATieWithTheAstTool [
	"A tie is won by the type of the AST based tool, if it is one of the tied ones"

	| strategy |
	strategy := self strategy: HyBiasedVotingConfidenceStrategy.

	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> 'B').
							   ('Name' -> 'A') })))
		equals: #( 'B' ).
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> nil).
					  ('Name' -> 'A').
					  ('Profiler' -> 'B') })) isNothing.
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> 'C').
					  ('Name' -> 'A').
					  ('Profiler' -> 'A') })) isNothing not.
	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> 'C').
							   ('Name' -> 'A').
							   ('Profiler' -> 'A') })))
		equals: #( 'A' ).
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> nil).
					  ('Name' -> nil) })) isNothing
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testConsensusAbstainsWhenTheyDisagree [
	"One different answer, or one silent tool: no consensus"

	| strategy |
	strategy := self strategy: HyExpConsensusStrategy.

	self assert: (strategy merge: (self predictions: {
					  ('AST' -> 'Integer').
					  ('Name' -> 'String').
					  ('Profiler' -> 'Integer') })) isNothing.
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> 'Integer').
					  ('Name' -> nil).
					  ('Profiler' -> 'Integer') })) isNothing.
	self assert: (strategy merge: #(  )) isNothing
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testConsensusCanIgnoreSilentTools [
	"With requireAllTools false the tools that answered must agree, and at least two"

	| strategy |
	strategy := self strategy: HyExpConsensusStrategy.
	strategy requireAllTools: false.

	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> 'Integer').
							   ('Name' -> nil).
							   ('Profiler' -> 'Integer') })))
		equals: #( 'Integer' ).
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> 'Integer').
					  ('Name' -> nil).
					  ('Profiler' -> nil) })) isNothing.
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> 'Integer').
					  ('Name' -> 'String').
					  ('Profiler' -> nil) })) isNothing
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testConsensusConfidenceIsTheMean [
	"The confidence of the consensus is the mean of the confidences given"

	| strategy result |
	strategy := self strategy: HyExpConsensusStrategy.
	result := strategy merge: {
			          (HyToolPrediction tool: 'AST' types: (HyTypeExpression parse: 'A') confidence: 0.5).
			          (HyToolPrediction tool: 'Name' types: (HyTypeExpression parse: 'A') confidence: 1.0).
			          (HyToolPrediction tool: 'Profiler' types: (HyTypeExpression parse: 'A') confidence: nil) }.

	self assert: result confidence equals: 0.75
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testConsensusOfSetsIgnoresTheOrder [
	"Integer | String is String | Integer"

	| result |
	result := (self strategy: HyExpConsensusStrategy) merge: (self predictions: {
				           ('AST' -> 'Integer | String').
				           ('Name' -> 'String | Integer') }).

	self assert: (self keysOf: result) equals: #( 'Integer' 'String' )
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testConsensusWhenAllAgree [
	"All tools answered the same: that is the answer"

	| result |
	result := (self strategy: HyExpConsensusStrategy) merge: (self predictions: {
				           ('AST' -> 'Integer').
				           ('Name' -> 'Integer').
				           ('Profiler' -> 'Integer') }).

	self assert: (self keysOf: result) equals: #( 'Integer' ).
	self assert: result toolName equals: 'Consensus'
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testNames [
	"The strategies are named as in the result files of the experiment"

	self assert: (HyExpMergeStrategy allWithAstTool: 'AST' tierOrder: #( 'AST' )) size equals: 5.
	self
		assert: ((HyExpMergeStrategy allWithAstTool: 'AST' tierOrder: #( 'AST' )) collect: [ :strategy | strategy name ]) asArray
		equals: #( 'Consensus' 'BiasedConsensus' 'TierBased' 'VotingConfidence' 'BiasedVotingConfidence' )
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testTierBasedTakesTheMostReliableAnswer [
	"The first tool of the order that answered"

	| strategy |
	strategy := self strategy: HyTierBasedStrategy.

	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('Profiler' -> 'C').
							   ('Name' -> 'B').
							   ('AST' -> 'A') })))
		equals: #( 'A' ).
	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> nil).
							   ('Name' -> 'B').
							   ('Profiler' -> 'C') })))
		equals: #( 'B' ).
	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> nil).
							   ('Name' -> nil).
							   ('Profiler' -> 'C') })))
		equals: #( 'C' ).
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> nil).
					  ('Name' -> nil).
					  ('Profiler' -> nil) })) isNothing
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testTierBasedWithoutOrderUsesTheOrderOfThePredictions [
	"No tier order: the order given"

	| strategy |
	strategy := HyTierBasedStrategy new.

	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('X' -> nil).
							   ('Y' -> 'B').
							   ('Z' -> 'C') })))
		equals: #( 'B' )
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testVotingSharesTheConfidenceOfASet [
	"A tool that says A | B gives half of its confidence to each: A gets 1/2 + 1 = 1.5, B 1/2, so A wins"

	| result |
	result := (self strategy: HyVotingConfidenceStrategy) merge: (self predictions: {
				           ('AST' -> 'A | B').
				           ('Name' -> 'A') }).

	self assert: (self keysOf: result) equals: #( 'A' )
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testVotingTakesTheTypeWithTheMostConfidence [
	"Two tools say A, one says B: A wins, with its share of the confidence"

	| result |
	result := (self strategy: HyVotingConfidenceStrategy) merge: (self predictions: {
				           ('AST' -> 'A').
				           ('Name' -> 'B').
				           ('Profiler' -> 'A') }).

	self assert: (self keysOf: result) equals: #( 'A' ).
	self assert: result confidence equals: 2 / 3
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testVotingTieIsNoAnswer [
	"One vote each: no answer; and no vote: no answer"

	| strategy |
	strategy := self strategy: HyVotingConfidenceStrategy.

	self assert: (strategy merge: (self predictions: {
					  ('AST' -> 'A').
					  ('Name' -> 'B') })) isNothing.
	self assert: (strategy merge: (self predictions: {
					  ('AST' -> nil).
					  ('Name' -> nil) })) isNothing
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testVotingUsesTheConfidenceOfTheTools [
	"One confident tool can outvote two unsure ones"

	| result |
	result := (self strategy: HyVotingConfidenceStrategy) merge: {
			          (HyToolPrediction tool: 'AST' types: (HyTypeExpression parse: 'A') confidence: 0.2).
			          (HyToolPrediction tool: 'Name' types: (HyTypeExpression parse: 'A') confidence: 0.2).
			          (HyToolPrediction tool: 'Profiler' types: (HyTypeExpression parse: 'B') confidence: 0.9) }.

	self assert: (self keysOf: result) equals: #( 'B' )
]

{ #category : 'tests' }
HyExpMergeStrategyTest >> testVotingUsesTheWeightsOfTheTools [
	"A weight multiplies the votes of a tool"

	| strategy |
	strategy := self strategy: HyVotingConfidenceStrategy.
	strategy weights at: 'Profiler' put: 5.

	self
		assert: (self keysOf: (strategy merge: (self predictions: {
							   ('AST' -> 'A').
							   ('Name' -> 'A').
							   ('Profiler' -> 'B') })))
		equals: #( 'B' )
]
