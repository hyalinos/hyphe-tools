"
Tests of the rules to compare a prediction with the ground truth: every case of the experiment document and the alternative choices of the cases left to decide.
"
Class {
	#name : 'HYEComparisonPolicyTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#instVars : [
		'policy'
	],
	#category : 'Hyphe-Experiments-Tests-Comparison',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Comparison'
}

{ #category : 'helpers' }
HYEComparisonPolicyTest >> outcome: aPredictionString truth: aTruthString [
	"Compare a prediction (nil for no answer) with a truth, for a method of Foo, with the policy of the test"

	^ policy
		  outcomeOf: (HYEToolPrediction tool: 'T' type: aPredictionString)
		  for:
		  (HYEGroundTruthEntry ref: (HYEMethodRef package: 'P' class: 'Foo' selector: #bar) truth: (HYETypeExpression parse: aTruthString))
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> outcome: aPredictionString truth: aTruthString on: aClassName with: aPolicy [
	"Compare a prediction with a truth for a method of the class named aClassName with the given policy"

	^ aPolicy outcomeOf: (HYEToolPrediction tool: 'T' type: aPredictionString) for: (HYEGroundTruthEntry
			   ref: (HYEMethodRef package: 'P' class: aClassName selector: #bar)
			   truth: (HYETypeExpression parse: aTruthString))
]

{ #category : 'running' }
HYEComparisonPolicyTest >> setUp [
	"The default policy"

	super setUp.
	policy := HYEComparisonPolicy new
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testArgumentTruth [
	"Truth a_n: nobody can tell it, excluded by default; an error if the policy says so"

	self assert: (self outcome: 'Integer' truth: 'a1') equals: #excluded.
	self assert: (self outcome: nil truth: 'a') equals: #excluded.

	policy argumentTruth: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'a1') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testDefaultPreparedPredictionIsTheSame [

	| prediction |
	prediction := HYEToolPrediction tool: 'T' type: 'ByteString | Object'.
	self assert: (policy prepared: prediction) equals: prediction
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testDefaultsKeepTheOlderRules [

	self assert: policy nameNormalization equals: #none.
	self deny: policy objectMeansUnknown.
	self assert: policy relatedMatching equals: #off.
	self assert: (self outcome: 'ByteString' truth: 'String') equals: #incorrect.
	self assert: (self outcome: 'Object' truth: 'Integer') equals: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'SmallInteger') equals: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'UndefinedObject | Integer') equals: #correct
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testDescendantsAreNotRightWithoutTheSetting [
	"The experiment 1 rules alone: a subclass is a related class even if the truth is r"

	self
		assert: (self
				 outcome: 'SortedCollection'
				 truth: 'r'
				 on: 'OrderedCollection'
				 with: HYEComparisonPolicy experimentOne)
		equals: #related
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testDescendantsInAUnionWithReceiver [
	"r | String: a subclass of the class of the method is one member, so partial as for any union"

	self
		assert: (self
				 outcome: 'SortedCollection'
				 truth: 'r | String'
				 on: 'OrderedCollection'
				 with: HYEComparisonPolicy experimentOneWithReceivers)
		equals: #partial.
	self
		assert: (self
				 outcome: 'SortedCollection | String'
				 truth: 'r | String'
				 on: 'OrderedCollection'
				 with: HYEComparisonPolicy experimentOneWithReceivers)
		equals: #correct
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testDescendantsOfAMetaclass [
	"A method of the class side: r is the class object, its subclasses' metaclasses are right too"

	| p |
	p := HYEComparisonPolicy experimentOneWithReceivers.
	self
		assert: (self
				 outcome: 'OrderedCollection class'
				 truth: 'r'
				 on: 'OrderedCollection class'
				 with: p)
		equals: #correct.
	self
		assert: (self
				 outcome: 'SortedCollection class'
				 truth: 'r'
				 on: 'OrderedCollection class'
				 with: p)
		equals: #correct.
	self
		assert: (self
				 outcome: 'Dictionary class'
				 truth: 'r'
				 on: 'OrderedCollection class'
				 with: p)
		equals: #incorrect
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testDescendantsOnlyWhenTheTruthHasReceiver [
	"A truth that names the class (not r) is exactly that class, also with #classAndDescendants"

	self
		assert: (self
				 outcome: 'SortedCollection'
				 truth: 'OrderedCollection'
				 on: 'OrderedCollection'
				 with: HYEComparisonPolicy experimentOneWithReceivers)
		equals: #related
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testDifferentType [
	"Different type: incorrect"

	self assert: (self outcome: 'String' truth: 'Integer') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testExperimentOneNormalizesNames [

	policy := HYEComparisonPolicy experimentOne.
	self assert: (self outcome: 'ByteString' truth: 'String') equals: #correct.
	self assert: (self outcome: 'WideString' truth: 'String') equals: #correct.
	self assert: (self outcome: 'ByteSymbol' truth: 'Symbol') equals: #correct.
	self assert: (self outcome: 'False | True' truth: 'Boolean') equals: #correct.
	self assert: (self outcome: 'True' truth: 'Boolean') equals: #correct.
	self assert: (self outcome: 'ByteString' truth: 'Symbol') equals: #related
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testExperimentOneObjectAnswerIsNoAnswer [

	policy := HYEComparisonPolicy experimentOne.
	self assert: (self outcome: 'Object' truth: 'Integer') equals: #abstained.
	self assert: (self outcome: 'Integer | Object' truth: 'Integer') equals: #abstained.
	self assert: (self outcome: nil truth: 'Integer') equals: #abstained
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testExperimentOneObjectTruthIsExcluded [

	policy := HYEComparisonPolicy experimentOne.
	self assert: (self outcome: 'Integer' truth: 'Object') equals: #excluded.
	self assert: (self outcome: nil truth: 'Object') equals: #excluded.
	self assert: (self outcome: 'Object' truth: 'Object') equals: #excluded
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testExperimentOneOneTypeOfAUnionIsPartial [

	policy := HYEComparisonPolicy experimentOne.
	self assert: (self outcome: 'Integer' truth: 'UndefinedObject | Integer') equals: #partial.
	self assert: (self outcome: 'Integer | UndefinedObject' truth: 'UndefinedObject | Integer') equals: #correct.
	self assert: (self outcome: 'Integer | String | Float' truth: 'Integer | String') equals: #partial.
	self assert: (self outcome: 'Array' truth: 'UndefinedObject | Integer') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testExperimentOneRelatedByInheritance [

	policy := HYEComparisonPolicy experimentOne.
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
HYEComparisonPolicyTest >> testExperimentOneRelatedNeverUsesObject [

	policy := HYEComparisonPolicy experimentOne.
	policy objectMeansUnknown: false.
	self assert: (self outcome: 'Object' truth: 'Integer') equals: #incorrect.
	self assert: (self outcome: 'Integer' truth: 'Object') equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testExperimentOneSettings [

	policy := HYEComparisonPolicy experimentOne.
	self assert: policy unionTruth equals: #partial.
	self assert: policy nameNormalization equals: #standard.
	self assert: policy objectMeansUnknown.
	self assert: policy relatedMatching equals: #inheritance.
	self assert: policy abstention equals: #abstain.
	self assert: policy unknownTruth equals: #excluded.
	self assert: policy argumentTruth equals: #excluded
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testNoAnswer [
	"No answer is an abstention by default, an error if the policy says so"

	self assert: (self outcome: nil truth: 'Integer') equals: #abstained.

	policy abstention: #incorrect.
	self assert: (self outcome: nil truth: 'Integer') equals: #incorrect
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testNoTruth [
	"An entry without truth cannot be compared"

	self
		assert: (policy
				 outcomeOf: (HYEToolPrediction tool: 'T' type: 'Integer')
				 for: (HYEGroundTruthEntry ref: (self metricsRef: #mixedSends) truth: nil))
		equals: #excluded
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testPartOfAUnionPredictedAsASet [
	"Two members of a three types union: partial"

	self assert: (self outcome: 'A | B' truth: 'A | B | C') equals: #partial
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testPredictionWithAnArgumentTypeIsNotAnAnswer [
	"A prediction that is only the type of an argument says no class: it is an abstention"

	self assert: (self outcome: 'a1' truth: 'Integer') equals: #abstained
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testPreparedPrediction [

	| prediction |
	policy := HYEComparisonPolicy experimentOne.
	prediction := policy prepared: (HYEToolPrediction tool: 'T' type: 'ByteString | True').
	self assert: prediction types keys equals: #( 'Boolean' 'String' ).
	self assert: (policy prepared: (HYEToolPrediction tool: 'T' type: 'ByteString | Object')) isNothing.
	self assert: (policy prepared: (HYEToolPrediction tool: 'T' type: nil)) isNothing.
	self assert: (policy prepared: (HYEToolPrediction tool: 'T' type: 'r | ByteString')) types keys equals: #( 'String' 'r' )
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testReceiverAndDescendants [
	"Truth r with #classAndDescendants: the class of the method and its subclasses are right, a superclass is a related class, an unrelated class is wrong"

	| p |
	p := HYEComparisonPolicy experimentOneWithReceivers.
	self
		assert: (self
				 outcome: 'OrderedCollection'
				 truth: 'r'
				 on: 'OrderedCollection'
				 with: p)
		equals: #correct.
	self
		assert: (self
				 outcome: 'SortedCollection'
				 truth: 'r'
				 on: 'OrderedCollection'
				 with: p)
		equals: #correct.
	self
		assert: (self
				 outcome: 'SequenceableCollection'
				 truth: 'r'
				 on: 'OrderedCollection'
				 with: p)
		equals: #related.
	self
		assert: (self
				 outcome: 'Dictionary'
				 truth: 'r'
				 on: 'OrderedCollection'
				 with: p)
		equals: #incorrect.
	self
		assert: (self
				 outcome: 'NoSuchClassAnywhere'
				 truth: 'r'
				 on: 'OrderedCollection'
				 with: p)
		equals: #incorrect.
	self
		assert: (self
				 outcome: nil
				 truth: 'r'
				 on: 'OrderedCollection'
				 with: p)
		equals: #abstained
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testReceiverAndDescendantsIsAccepted [

	self
		assert: (HYEComparisonPolicy new
				 receiverMatching: #classAndDescendants;
				 receiverMatching)
		equals: #classAndDescendants.
	self assert: HYEComparisonPolicy experimentOneWithReceivers receiverMatching equals: #classAndDescendants.
	self assert: HYEComparisonPolicy experimentOne receiverMatching equals: #definingClass
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testReceiverHierarchyWithClassNotInTheImage [
	"A method of a class that is not in the image has no hierarchy: only the exact name matches"

	| entry |
	policy receiverMatching: #classHierarchy.
	entry := HYEGroundTruthEntry
		         ref: (HYEMethodRef package: 'P' class: 'NoSuchClassAnywhere' selector: #foo)
		         truth: (HYETypeExpression parse: 'r').

	self assert: (policy outcomeOf: (HYEToolPrediction tool: 'T' type: 'Object') for: entry) equals: #incorrect.
	self assert: (policy outcomeOf: (HYEToolPrediction tool: 'T' type: 'NoSuchClassAnywhere') for: entry) equals: #correct
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testReceiverInAUnionTruth [
	"r | ? is Foo or unknown"

	self assert: (self outcome: 'Foo' truth: 'r | ?') equals: #correct
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testReceiverTruth [
	"Truth r: the tool must say the class of the method (resolved r counts too)"

	self assert: (self outcome: 'Foo' truth: 'r') equals: #correct.
	self assert: (self outcome: 'r' truth: 'r') equals: #correct.
	self assert: (self outcome: 'Bar' truth: 'r') equals: #incorrect.
	self assert: (self outcome: nil truth: 'r') equals: #abstained
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testReceiverTruthWithClassHierarchy [
	"With #classHierarchy a superclass or a subclass of the class also matches; unknown classes are never related"

	| entry |
	policy receiverMatching: #classHierarchy.
	entry := HYEGroundTruthEntry
		         ref: (HYEMethodRef package: 'P' class: 'OrderedCollection' selector: #add:)
		         truth: (HYETypeExpression parse: 'r').

	self assert: (policy outcomeOf: (HYEToolPrediction tool: 'T' type: 'SequenceableCollection') for: entry) equals: #correct.
	self assert: (policy outcomeOf: (HYEToolPrediction tool: 'T' type: 'SortedCollection') for: entry) equals: #correct.
	self assert: (policy outcomeOf: (HYEToolPrediction tool: 'T' type: 'Dictionary') for: entry) equals: #incorrect.
	self assert: (policy outcomeOf: (HYEToolPrediction tool: 'T' type: 'NoSuchClassAnywhere') for: entry) equals: #incorrect
]

{ #category : 'Protocol (tests) - 30 selector(s)' }
HYEComparisonPolicyTest >> testRelatedNeedsTheSetting [

	self assert: (self outcome: 'Integer' truth: 'SmallInteger') equals: #incorrect.
	policy relatedMatching: #inheritance.
	self assert: (self outcome: 'Integer' truth: 'SmallInteger') equals: #related.
	self should: [ policy relatedMatching: #maybe ] raise: Error
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testSameType [
	"Same type: correct"

	self assert: (self outcome: 'Integer' truth: 'Integer') equals: #correct
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testSetAndTruthOverlap [
	"A | C against A | B: they have a type in common but neither contains the other: setContainingTruth"

	self assert: (self outcome: 'A | C' truth: 'A | B') equals: #partial
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testSetThatContainsTheRightType [
	"A set that includes the correct type: partial by default, correct or incorrect if the policy says so"

	self assert: (self outcome: 'Integer | String' truth: 'Integer') equals: #partial.

	policy setContainingTruth: #correct.
	self assert: (self outcome: 'Integer | String' truth: 'Integer') equals: #correct.

	policy setContainingTruth: #incorrect.
	self assert: (self outcome: 'Integer | String' truth: 'Integer') equals: #incorrect
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testSetThatDoesNotContainTheRightType [
	"A set without the correct type is incorrect"

	self assert: (self outcome: 'String | Boolean' truth: 'Integer') equals: #incorrect
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testSettingsAreChecked [
	"An unknown choice is refused"

	self should: [ policy abstention: #maybe ] raise: Error.
	self should: [ policy setContainingTruth: #excluded ] raise: Error.
	self assert: policy abstention equals: #abstain
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testSettingsAreReadBack [
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
HYEComparisonPolicyTest >> testTruthWithAnUnknownMember [
	"String | ?: a tool that says String is right; another type is incorrect, or excluded if the policy says so"

	self assert: (self outcome: 'String' truth: 'String | ?') equals: #correct.
	self assert: (self outcome: 'Integer' truth: 'String | ?') equals: #incorrect.

	policy unresolvedMembers: #excluded.
	self assert: (self outcome: 'Integer' truth: 'String | ?') equals: #excluded.
	self assert: (self outcome: 'String' truth: 'String | ?') equals: #correct
]

{ #category : 'tests' }
HYEComparisonPolicyTest >> testUnionTruth [
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
HYEComparisonPolicyTest >> testUnknownTruth [
	"Truth ? or !: excluded by default; with #abstentionCorrect the tool is right to abstain and wrong to answer"

	self assert: (self outcome: 'Integer' truth: '?') equals: #excluded.
	self assert: (self outcome: nil truth: '!') equals: #excluded.

	policy unknownTruth: #abstentionCorrect.
	self assert: (self outcome: nil truth: '?') equals: #correct.
	self assert: (self outcome: 'Integer' truth: '?') equals: #incorrect
]
