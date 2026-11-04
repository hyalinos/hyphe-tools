"
A way to combine the answers of several tools into one: merge: takes the HYEToolPrediction of every tool (resolved, see HYEToolPrediction>>resolvedFor:) and answers a HYEToolPrediction named after the strategy, possibly nothing. Five strategies: HYEExpConsensusStrategy, HYEExpBiasedConsensusStrategy, HYETierBasedStrategy, HYEVotingConfidenceStrategy, HYEBiasedVotingConfidenceStrategy. astToolName is the tool the biased strategies favour; tierOrder the tools from the most to the least reliable (tier based; by default the order of the predictions); weights a dictionary tool name -> weight for the votes (default 1).
"
Class {
	#name : 'HYEExpMergeStrategy',
	#superclass : 'Object',
	#instVars : [
		'name',
		'astToolName',
		'tierOrder',
		'weights',
		'requireAllTools'
	],
	#category : 'Hyphe-Experiments-Merging',
	#package : 'Hyphe-Experiments',
	#tag : 'Merging'
}

{ #category : 'instance creation' }
HYEExpMergeStrategy class >> allWithAstTool: anAstToolName tierOrder: someToolNames [
	"Answer the five strategies of the experiment, configured with the AST based tool and the order of reliability of the tools"

	^ {
		  HYEExpConsensusStrategy new.
		  (HYEExpBiasedConsensusStrategy new
			   astToolName: anAstToolName;
			   yourself).
		  (HYETierBasedStrategy new
			   tierOrder: someToolNames;
			   yourself).
		  HYEVotingConfidenceStrategy new.
		  (HYEBiasedVotingConfidenceStrategy new
			   astToolName: anAstToolName;
			   yourself) }
]

{ #category : 'private' }
HYEExpMergeStrategy >> answeredBy: somePredictions [
	"Answer the predictions that are not no-answer"

	^ somePredictions reject: [ :prediction | prediction isNothing ]
]

{ #category : 'private' }
HYEExpMergeStrategy >> astPredictionIn: somePredictions [
	"Answer the prediction of the AST based tool if it answered, nil otherwise"

	^ somePredictions detect: [ :prediction | prediction toolName = astToolName and: [ prediction isNothing not ] ] ifNone: [ nil ]
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> astToolName [
	"Answer the name of the AST based tool"

	^ astToolName
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> astToolName: aString [
	"Set the name of the AST based tool, the one biased strategies favour"

	astToolName := aString
]

{ #category : 'private' }
HYEExpMergeStrategy >> bestVotesIn: somePredictions [
	"Answer the keys (a sorted array of strings, one type) that gets the most confidence, as an association keys -> share of the whole confidence, and the keys that tie with it. A prediction of several types gives each type its confidence divided by their number. Answer an array: the best association (nil if there is no vote) and the collection of the keys that tie for the best."

	| scores total best tied |
	scores := Dictionary new.
	total := 0.
	(self answeredBy: somePredictions) do: [ :prediction |
			| share |
			share := prediction effectiveConfidence * (self weights at: prediction toolName ifAbsent: [ 1 ]) / prediction keys size.
			prediction keys do: [ :key |
					scores at: key put: (scores at: key ifAbsent: [ 0 ]) + share.
					total := total + share ] ].
	scores isEmpty ifTrue: [
			^ {
				  nil.
				  #(  ) } ].
	best := scores values max.
	tied := (scores keys select: [ :key | (scores at: key) = best ]) asSortedCollection asArray.
	^ {
		  (tied first -> (total = 0
			    ifTrue: [ 0 ]
			    ifFalse: [ best / total ])).
		  tied }
]

{ #category : 'merging' }
HYEExpMergeStrategy >> merge: somePredictions [
	"Combine the predictions of all the tools into one prediction"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> name [
	"Answer the name of the strategy, used as column name in the results"

	^ name ifNil: [ self class defaultName ]
]

{ #category : 'private' }
HYEExpMergeStrategy >> nothing [
	"The prediction of a strategy that abstains"

	^ HYEToolPrediction nothingFrom: self name
]

{ #category : 'private' }
HYEExpMergeStrategy >> predictionOfKey: aKey in: somePredictions [
	"Answer a prediction, among the answers, that says exactly the type of the key (one atom); a one-type prediction is made if none says it alone"

	^ HYETypeExpression atoms: { (HYETypeAtom parse: aKey) }
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> requireAllTools [
	"Answer whether the consensus needs the answer of every tool (true, the default: a tool that does not answer makes the consensus fail) or only of the tools that answered, at least two of them"

	^ requireAllTools ifNil: [ true ]
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> requireAllTools: aBoolean [
	"Tell whether the consensus needs the answer of every tool, or only agreement among the tools that answered (at least two)"

	requireAllTools := aBoolean
]

{ #category : 'private' }
HYEExpMergeStrategy >> resultFrom: aPrediction [
	"Answer the prediction of the strategy that says what another prediction says"

	^ HYEToolPrediction tool: self name types: aPrediction types confidence: aPrediction confidence
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> tierOrder [
	"Answer the names of the tools from the most to the least reliable, nil for the order of the predictions"

	^ tierOrder
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> tierOrder: someToolNames [
	"Set the tools from the most to the least reliable"

	tierOrder := someToolNames
]

{ #category : 'private' }
HYEExpMergeStrategy >> unanimousResultIn: somePredictions [
	"Answer the common prediction if the tools agree, nil otherwise. By default every tool must have answered (see requireAllTools); the confidence is the mean one, nil if no tool gives one."

	| answers confidences |
	answers := self answeredBy: somePredictions.
	(self requireAllTools
		 ifTrue: [ somePredictions isEmpty or: [ answers size ~= somePredictions size ] ]
		 ifFalse: [ answers size < 2 ]) ifTrue: [ ^ nil ].
	(answers allSatisfy: [ :prediction | prediction keys = answers first keys ]) ifFalse: [ ^ nil ].
	confidences := (answers collect: [ :prediction | prediction confidence ]) reject: #isNil.
	^ HYEToolPrediction
		  tool: self name
		  types: answers first types
		  confidence: (confidences ifEmpty: [ nil ] ifNotEmpty: [ confidences sum / confidences size ])
]

{ #category : 'accessing' }
HYEExpMergeStrategy >> weights [
	"Answer the dictionary tool name -> weight of its votes (a missing tool weighs 1)"

	^ weights ifNil: [ weights := Dictionary new ]
]
