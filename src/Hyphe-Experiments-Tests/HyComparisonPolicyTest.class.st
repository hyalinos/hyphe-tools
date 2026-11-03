"
Tests of the rules to compare a prediction with the ground truth: every case of the experiment document and the alternative choices of the cases left to decide.
"
Class {
	#name : 'HyComparisonPolicyTest',
	#superclass : 'HyExperimentsAbstractTest',
	#instVars : [
		'policy'
	],
	#category : 'Hyphe-Experiments-Tests-Comparison',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Comparison'
}

{ #category : 'helpers' }
HyComparisonPolicyTest >> outcome: aPredictionString truth: aTruthString [
	"Compare a prediction (nil for no answer) with a truth, for a method of Foo, with the policy of the test"

	^ policy
		  outcomeOf: (HyToolPrediction tool: 'T' type: aPredictionString)
		  for:
		  (HyGroundTruthEntry ref: (HyMethodRef package: 'P' class: 'Foo' selector: #bar) truth: (HyTypeExpression parse: aTruthString))
]

{ #category : 'running' }
HyComparisonPolicyTest >> setUp [
	"The default policy"

	super setUp.
	policy := HyComparisonPolicy new
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testArgumentTruth [
	"Truth a_n: nobody can tell it, excluded by default; an error if the policy says so"

	self assert: (self outcome: 'Integer' truth: 'a1') equals: #excluded.
	self assert: (self outcome: nil truth: 'a') equals: #excluded.

	policy argumentTruth: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'a1') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testDefaultPreparedPredictionIsTheSame [

	| prediction |
	prediction := HyToolPrediction tool: 'T' type: 'ByteString | Object'.
	self assert: (policy prepared: prediction) equals: prediction
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testDefaultsKeepTheOlderRules [

	self assert: policy nameNormalization equals: #none.
	self deny: policy objectMeansUnknown.
	self assert: policy relatedMatching equals: #off.
	self assert: (self outcome: 'ByteString' truth: 'String') equals: #incorrect.
	self assert: (self outcome: 'Object' truth: 'Integer') equals: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'SmallInteger') equals: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'UndefinedObject | Integer') equals: #correct
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testDifferentType [
	"Different type: incorrect"

	self assert: (self outcome: 'String' truth: 'Integer') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testExperimentOneNormalizesNames [

	policy := HyComparisonPolicy experimentOne.
	self assert: (self outcome: 'ByteString' truth: 'String') equals: #correct.
	self assert: (self outcome: 'WideString' truth: 'String') equals: #correct.
	self assert: (self outcome: 'ByteSymbol' truth: 'Symbol') equals: #correct.
	self assert: (self outcome: 'False | True' truth: 'Boolean') equals: #correct.
	self assert: (self outcome: 'True' truth: 'Boolean') equals: #correct.
	self assert: (self outcome: 'ByteString' truth: 'Symbol') equals: #related
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testExperimentOneObjectAnswerIsNoAnswer [

	policy := HyComparisonPolicy experimentOne.
	self assert: (self outcome: 'Object' truth: 'Integer') equals: #abstained.
	self assert: (self outcome: 'Integer | Object' truth: 'Integer') equals: #abstained.
	self assert: (self outcome: nil truth: 'Integer') equals: #abstained
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testExperimentOneObjectTruthIsExcluded [

	policy := HyComparisonPolicy experimentOne.
	self assert: (self outcome: 'Integer' truth: 'Object') equals: #excluded.
	self assert: (self outcome: nil truth: 'Object') equals: #excluded.
	self assert: (self outcome: 'Object' truth: 'Object') equals: #excluded
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testExperimentOneOneTypeOfAUnionIsPartial [

	policy := HyComparisonPolicy experimentOne.
	self assert: (self outcome: 'Integer' truth: 'UndefinedObject | Integer') equals: #partial.
	self assert: (self outcome: 'Integer | UndefinedObject' truth: 'UndefinedObject | Integer') equals: #correct.
	self assert: (self outcome: 'Integer | String | Float' truth: 'Integer | String') equals: #partial.
	self assert: (self outcome: 'Array' truth: 'UndefinedObject | Integer') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testExperimentOneRelatedByInheritance [

	policy := HyComparisonPolicy experimentOne.
	self assert: (self outcome: 'Integer' truth: 'SmallInteger') equals: #related.
	self assert: (self outcome: 'SmallInteger' truth: 'Integer') equals: #related.
	self assert: (self outcome: 'Number' truth: 'Integer | String') equals: #related.
	self assert: (self outcome: 'String' truth: 'Symbol') equals: #related.
	self assert: (self outcome: 'Integer' truth: 'String') equals: #incorrect.
	self assert: (self outcome: 'Array' truth: 'Collection') equals: #related.
	self assert: (self outcome: 'Array' truth: 'Set') equals: #incorrect.
	self assert: (self outcome: 'SmallInteger' truth: 'SmallInteger') equals: #correct
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testExperimentOneRelatedNeverUsesObject [

	policy := HyComparisonPolicy experimentOne.
	policy objectMeansUnknown: false.
	self assert: (self outcome: 'Object' truth: 'Integer') equals: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'Object') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testExperimentOneSettings [

	policy := HyComparisonPolicy experimentOne.
	self assert: policy unionTruth equals: #partial.
	self assert: policy nameNormalization equals: #standard.
	self assert: policy objectMeansUnknown.
	self assert: policy relatedMatching equals: #inheritance.
	self assert: policy abstention equals: #abstain.
	self assert: policy unknownTruth equals: #excluded.
	self assert: policy argumentTruth equals: #excluded
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testNoAnswer [
	"No answer is an abstention by default, an error if the policy says so"

	self assert: (self outcome: nil truth: 'Integer') equals: #abstained.

	policy abstention: #incorrect.
	self assert: (self outcome: nil truth: 'Integer') equals: #incorrect
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testNoTruth [
	"An entry without truth cannot be compared"

	self
		assert: (policy
				 outcomeOf: (HyToolPrediction tool: 'T' type: 'Integer')
				 for: (HyGroundTruthEntry ref: (self metricsRef: #mixedSends) truth: nil))
		equals: #excluded
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testPartOfAUnionPredictedAsASet [
	"Two members of a three types union: partial"

	self assert: (self outcome: 'A | B' truth: 'A | B | C') equals: #partial
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testPredictionWithAnArgumentTypeIsNotAnAnswer [
	"A prediction that is only the type of an argument says no class: it is an abstention"

	self assert: (self outcome: 'a1' truth: 'Integer') equals: #abstained
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testPreparedPrediction [

	| prediction |
	policy := HyComparisonPolicy experimentOne.
	prediction := policy prepared: (HyToolPrediction tool: 'T' type: 'ByteString | True').
	self assert: prediction types keys equals: #( 'Boolean' 'String' ).
	self assert: (policy prepared: (HyToolPrediction tool: 'T' type: 'ByteString | Object')) isNothing.
	self assert: (policy prepared: (HyToolPrediction tool: 'T' type: nil)) isNothing.
	self assert: (policy prepared: (HyToolPrediction tool: 'T' type: 'r | ByteString')) types keys equals: #( 'String' 'r' )
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testReceiverHierarchyWithClassNotInTheImage [
	"A method of a class that is not in the image has no hierarchy: only the exact name matches"

	| entry |
	policy receiverMatching: #classHierarchy.
	entry := HyGroundTruthEntry
		         ref: (HyMethodRef package: 'P' class: 'NoSuchClassAnywhere' selector: #foo)
		         truth: (HyTypeExpression parse: 'r').

	self assert: (policy outcomeOf: (HyToolPrediction tool: 'T' type: 'Object') for: entry) equals: #incorrect.
	self assert: (policy outcomeOf: (HyToolPrediction tool: 'T' type: 'NoSuchClassAnywhere') for: entry) equals: #correct
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testReceiverInAUnionTruth [
	"r | ? is Foo or unknown"

	self assert: (self outcome: 'Foo' truth: 'r | ?') equals: #correct
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testReceiverTruth [
	"Truth r: the tool must say the class of the method (resolved r counts too)"

	self assert: (self outcome: 'Foo' truth: 'r') equals: #correct.
	self assert: (self outcome: 'r' truth: 'r') equals: #correct.
	self assert: (self outcome: 'Bar' truth: 'r') equals: #incorrect.
	self assert: (self outcome: nil truth: 'r') equals: #abstained
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testReceiverTruthWithClassHierarchy [
	"With #classHierarchy a superclass or a subclass of the class also matches; unknown classes are never related"

	| entry |
	policy receiverMatching: #classHierarchy.
	entry := HyGroundTruthEntry
		         ref: (HyMethodRef package: 'P' class: 'OrderedCollection' selector: #add:)
		         truth: (HyTypeExpression parse: 'r').

	self assert: (policy outcomeOf: (HyToolPrediction tool: 'T' type: 'SequenceableCollection') for: entry) equals: #correct.
	self assert: (policy outcomeOf: (HyToolPrediction tool: 'T' type: 'SortedCollection') for: entry) equals: #correct.
	self assert: (policy outcomeOf: (HyToolPrediction tool: 'T' type: 'Dictionary') for: entry) equals: #incorrect.
	self assert: (policy outcomeOf: (HyToolPrediction tool: 'T' type: 'NoSuchClassAnywhere') for: entry) equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HyComparisonPolicyTest >> testRelatedNeedsTheSetting [

	self assert: (self outcome: 'Integer' truth: 'SmallInteger') equals: #incorrect.
	policy relatedMatching: #inheritance.
	self assert: (self outcome: 'Integer' truth: 'SmallInteger') equals: #related.
	self should: [ policy relatedMatching: #maybe ] raise: Error
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testSameType [
	"Same type: correct"

	self assert: (self outcome: 'Integer' truth: 'Integer') equals: #correct
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testSetAndTruthOverlap [
	"A | C against A | B: they have a type in common but neither contains the other: setContainingTruth"

	self assert: (self outcome: 'A | C' truth: 'A | B') equals: #partial
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testSetThatContainsTheRightType [
	"A set that includes the correct type: partial by default, correct or incorrect if the policy says so"

	self assert: (self outcome: 'Integer | String' truth: 'Integer') equals: #partial.

	policy setContainingTruth: #correct.
	self assert: (self outcome: 'Integer | String' truth: 'Integer') equals: #correct.

	policy setContainingTruth: #incorrect.
	self assert: (self outcome: 'Integer | String' truth: 'Integer') equals: #incorrect
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testSetThatDoesNotContainTheRightType [
	"A set without the correct type is incorrect"

	self assert: (self outcome: 'String | Boolean' truth: 'Integer') equals: #incorrect
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testSettingsAreChecked [
	"An unknown choice is refused"

	self should: [ policy abstention: #maybe ] raise: Error.
	self should: [ policy setContainingTruth: #excluded ] raise: Error.
	self assert: policy abstention equals: #abstain
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testSettingsAreReadBack [
	"Each setting answers what was chosen, and the defaults are the ones of the class comment"

	self assert: policy setContainingTruth equals: #partial.
	self assert: policy unionTruth equals: #correct.
	self assert: policy abstention equals: #abstain.
	self assert: policy receiverMatching equals: #definingClass.
	self assert: policy argumentTruth equals: #excluded.
	self assert: policy unknownTruth equals: #excluded.
	self assert: policy unresolvedMembers equals: #ignore.

	policy
		setContainingTruth: #correct;
		unionTruth: #incorrect;
		abstention: #incorrect;
		receiverMatching: #classHierarchy;
		argumentTruth: #incorrect;
		unknownTruth: #abstentionCorrect;
		unresolvedMembers: #excluded.

	self assert: policy setContainingTruth equals: #correct.
	self assert: policy unionTruth equals: #incorrect.
	self assert: policy abstention equals: #incorrect.
	self assert: policy receiverMatching equals: #classHierarchy.
	self assert: policy argumentTruth equals: #incorrect.
	self assert: policy unknownTruth equals: #abstentionCorrect.
	self assert: policy unresolvedMembers equals: #excluded
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testTruthWithAnUnknownMember [
	"String | ?: a tool that says String is right; another type is incorrect, or excluded if the policy says so"

	self assert: (self outcome: 'String' truth: 'String | ?') equals: #correct.
	self assert: (self outcome: 'Integer' truth: 'String | ?') equals: #incorrect.

	policy unresolvedMembers: #excluded.
	self assert: (self outcome: 'Integer' truth: 'String | ?') equals: #excluded.
	self assert: (self outcome: 'String' truth: 'String | ?') equals: #correct
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testUnionTruth [
	"A union truth: one of its members is correct by default, the whole union too; one member and another type are partial or not according to the policy"

	self assert: (self outcome: 'Integer' truth: 'Integer | String') equals: #correct.
	self assert: (self outcome: 'Integer | String' truth: 'String | Integer') equals: #correct.
	self assert: (self outcome: 'Boolean' truth: 'Integer | String') equals: #incorrect.

	policy unionTruth: #partial.
	self assert: (self outcome: 'Integer' truth: 'Integer | String') equals: #partial.

	policy unionTruth: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'Integer | String') equals: #incorrect
]

{ #category : 'tests' }
HyComparisonPolicyTest >> testUnknownTruth [
	"Truth ? or !: excluded by default; with #abstentionCorrect the tool is right to abstain and wrong to answer"

	self assert: (self outcome: 'Integer' truth: '?') equals: #excluded.
	self assert: (self outcome: nil truth: '!') equals: #excluded.

	policy unknownTruth: #abstentionCorrect.
	self assert: (self outcome: nil truth: '?') equals: #correct.
	self assert: (self outcome: 'Integer' truth: '?') equals: #incorrect
]
