"
The rules to compare what a tool answered with the ground truth: outcomeOf:for: answers #correct, #partial, #incorrect, #abstained (the tool did not answer, which is not counted as an error) or #excluded (the method cannot be used for this comparison). The experiment document leaves several cases to decide (marked TBD there); each is a setting with the default chosen here, and the other choice stays available. setContainingTruth: the tool says a set of types that includes the right one: #partial (default), #correct or #incorrect. unionTruth: the truth is a union (String | Integer) and the tool gives one of its members: #correct (default), #partial, #incorrect. abstention: the tool gives no answer: #abstain (default, not an error) or #incorrect. receiverMatching: truth r matches a tool that says the class of the method (#definingClass, default) or also a superclass or a subclass of it (#classHierarchy). argumentTruth: truth a_n, the type of an argument, which a tool cannot know: #excluded (default) or #incorrect. unknownTruth: truth ? or !, no type to find: #excluded (default) or #abstentionCorrect (right if the tool abstains, wrong if it answers). unresolvedMembers: the truth has also ? or a_n members (String | ?) and the tool says another type: #ignore (default, incorrect) or #excluded. Predictions and truths should be compared after resolvedFor: (r is the class of the method). nameNormalization: #none (default, names as they are) or #standard (ByteString and WideString are String, ByteSymbol and WideSymbol are Symbol, True and False are Boolean; applied to the truth and the answers). objectMeansUnknown: false (default) or true (Object as a truth is like ?, excluded; an answer that says Object is no answer: prepared: turns it into nothing before the strategies merge). relatedMatching: #off (default) or #inheritance (a wrong answer that is right if a class and one of its superclasses or subclasses, not Object, were the same, is #related). HyComparisonPolicy experimentOne sets the choices of experiment 1 (EXPERIMENT-1.md, section 5): unionTruth #partial, #standard, objectMeansUnknown true, #inheritance. HyExperiment passes every answer of a tool through prepared: before the strategies merge them.
"
Class {
	#name : 'HyComparisonPolicy',
	#superclass : 'Object',
	#instVars : [
		'setContainingTruth',
		'unionTruth',
		'abstention',
		'receiverMatching',
		'argumentTruth',
		'unknownTruth',
		'unresolvedMembers',
		'nameNormalization',
		'objectMeansUnknown',
		'relatedMatching'
	],
	#category : 'Hyphe-Experiments-Comparison',
	#package : 'Hyphe-Experiments',
	#tag : 'Comparison'
}

{ #category : 'Protocol (instance creation) - 1 selector(s)' }
HyComparisonPolicy class >> experimentOne [
	"The rules of experiment 1 (EXPERIMENT-1.md, section 5): one type of a union is partial; class names are normalized; Object means any type (a tool that says it does not answer, a truth Object is excluded like ?); a wrong answer for a class related by inheritance is #related"

	^ self new
		  unionTruth: #partial;
		  nameNormalization: #standard;
		  objectMeansUnknown: true;
		  relatedMatching: #inheritance;
		  yourself
]

{ #category : 'settings' }
HyComparisonPolicy >> abstention [
	"Answer the choice for this case: one of #abstain #incorrect"

	^ abstention
]

{ #category : 'settings' }
HyComparisonPolicy >> abstention: aSymbol [
	"Choose what to do in this case: one of #abstain #incorrect"

	(#( #abstain #incorrect ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	abstention := aSymbol
]

{ #category : 'settings' }
HyComparisonPolicy >> argumentTruth [
	"Answer the choice for this case: one of #excluded #incorrect"

	^ argumentTruth
]

{ #category : 'settings' }
HyComparisonPolicy >> argumentTruth: aSymbol [
	"Choose what to do in this case: one of #excluded #incorrect"

	(#( #excluded #incorrect ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	argumentTruth := aSymbol
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> compare: predictionNames withTruth: truthNames open: isOpen ref: aMethodRef [
	"Compare two sets of class names with the strict rules, see compare:withTruth:open:ref:matching:"

	^ self
		  compare: predictionNames
		  withTruth: truthNames
		  open: isOpen
		  ref: aMethodRef
		  matching: #strict
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> compare: predictionNames withTruth: truthNames open: isOpen ref: aMethodRef matching: aMode [
	"Compare two sets of class names. Equal sets are correct. Predicted types that are all in the truth but do not cover it (a member of a union): unionTruth for one type, partial for several. Predicted types that cover the truth but have more (or only overlap it): setContainingTruth. No common type: incorrect, or excluded if the truth is open (has ? or an argument) and unresolvedMembers is #excluded. Two names are the same type as name:matches:ref:matching: says."

	| allPredictionsMatch allTruthCovered anyMatch |
	allPredictionsMatch := predictionNames allSatisfy: [ :predicted |
			                       truthNames anySatisfy: [ :expected |
					                       self
						                       name: predicted
						                       matches: expected
						                       ref: aMethodRef
						                       matching: aMode ] ].
	allTruthCovered := truthNames allSatisfy: [ :expected |
			                   predictionNames anySatisfy: [ :predicted |
					                   self
						                   name: predicted
						                   matches: expected
						                   ref: aMethodRef
						                   matching: aMode ] ].
	anyMatch := predictionNames anySatisfy: [ :predicted |
			            truthNames anySatisfy: [ :expected |
					            self
						            name: predicted
						            matches: expected
						            ref: aMethodRef
						            matching: aMode ] ].
	(allPredictionsMatch and: [ allTruthCovered ]) ifTrue: [ ^ #correct ].
	allPredictionsMatch ifTrue: [
			^ predictionNames size = 1
				  ifTrue: [ unionTruth ]
				  ifFalse: [ #partial ] ].
	anyMatch ifTrue: [ ^ setContainingTruth ].
	^ (isOpen and: [ unresolvedMembers = #excluded ])
		  ifTrue: [ #excluded ]
		  ifFalse: [ #incorrect ]
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> initialize [
	"The default choices, see the class comment"

	super initialize.
	setContainingTruth := #partial.
	unionTruth := #correct.
	abstention := #abstain.
	receiverMatching := #definingClass.
	argumentTruth := #excluded.
	unknownTruth := #excluded.
	unresolvedMembers := #ignore.
	nameNormalization := #none.
	objectMeansUnknown := false.
	relatedMatching := #off
]

{ #category : 'private' }
HyComparisonPolicy >> is: aName relatedTo: anotherName [
	"Answer true if one of the two classes is a subclass of the other (classes that are not in the image are not related)"

	| first second |
	first := Smalltalk globals at: aName asSymbol ifAbsent: [ ^ false ].
	second := Smalltalk globals at: anotherName asSymbol ifAbsent: [ ^ false ].
	^ (first isBehavior and: [ second isBehavior ]) and: [ (first inheritsFrom: second) or: [ second inheritsFrom: first ] ]
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> isGeneric: aName [
	"Answer true for a class that every class inherits from: it says nothing about the type"

	^ #( 'Object' 'ProtoObject' ) includes: aName
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> name: aPredictedName matches: anExpectedName ref: aMethodRef [
	"Two class names match when they are equal; with #classHierarchy, the class of the method also matches its superclasses and subclasses"

	^ self
		  name: aPredictedName
		  matches: anExpectedName
		  ref: aMethodRef
		  matching: #strict
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> name: aPredictedName matches: anExpectedName ref: aMethodRef matching: aMode [
	"Two class names match when they are equal; with #classHierarchy, the class of the method also matches its superclasses and subclasses; with the mode #inheritance, a class also matches its superclasses and subclasses, but not Object or ProtoObject (#strict is the first two rules only)"

	aPredictedName = anExpectedName ifTrue: [ ^ true ].
	aMode = #inheritance ifTrue: [
			^ (self isGeneric: aPredictedName) not and: [
				  (self isGeneric: anExpectedName) not and: [ self is: aPredictedName relatedTo: anExpectedName ] ] ].
	(receiverMatching = #classHierarchy and: [ anExpectedName = aMethodRef className ]) ifFalse: [ ^ false ].
	^ self is: aPredictedName relatedTo: anExpectedName
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> nameNormalization [
	"Answer the choice for the names of the classes: one of #none #standard"

	^ nameNormalization
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> nameNormalization: aSymbol [
	"Choose how the names of the classes are compared: #none (as they are) or #standard (ByteString and WideString are String, ByteSymbol and WideSymbol are Symbol, True and False are Boolean, as in the ground truth)"

	(#( #none #standard ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	nameNormalization := aSymbol
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> normalizedName: aName [
	"Answer the name a class is counted as, see nameNormalization:"

	nameNormalization = #standard ifFalse: [ ^ aName ].
	^ ({
		   ('ByteString' -> 'String').
		   ('WideString' -> 'String').
		   ('ByteSymbol' -> 'Symbol').
		   ('WideSymbol' -> 'Symbol').
		   ('True' -> 'Boolean').
		   ('False' -> 'Boolean') } detect: [ :each | each key = aName ] ifNone: [ nil ])
		  ifNil: [ aName ]
		  ifNotNil: [ :each | each value ]
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> normalizedNames: someNames [
	"Answer the set of the names a collection of class names are counted as"

	^ (someNames collect: [ :each | self normalizedName: each ]) asSet
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> objectMeansUnknown [
	"Answer true if Object, in a truth or in an answer, means any type"

	^ objectMeansUnknown
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> objectMeansUnknown: aBoolean [
	"Choose whether Object, as a truth, is the same as ? (no type to find) and, as an answer of a tool, is no answer (any type says nothing)"

	objectMeansUnknown := aBoolean
]

{ #category : 'private' }
HyComparisonPolicy >> outcomeForAbstention [
	"What it means that the tool did not answer"

	^ abstention = #abstain
		  ifTrue: [ #abstained ]
		  ifFalse: [ #incorrect ]
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> outcomeForUnknownTruthPrediction: aPrediction [
	"The truth says any type (? or !, or Object when it means any type): a tool cannot be asked"

	^ unknownTruth = #excluded
		  ifTrue: [ #excluded ]
		  ifFalse: [
				  aPrediction isNothing
					  ifTrue: [ #correct ]
					  ifFalse: [ #incorrect ] ]
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> outcomeForUnresolvedTruth: aTruth prediction: aPrediction [
	"The truth has no class: it is the type of an argument, or ? / !, which a tool cannot be asked"

	aTruth hasArgument ifTrue: [
			^ argumentTruth = #excluded
				  ifTrue: [ #excluded ]
				  ifFalse: [ #incorrect ] ].
	^ self outcomeForUnknownTruthPrediction: aPrediction
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> outcomeOf: aPrediction for: anEntry [
	"Compare the prediction of a tool with the ground truth of an entry: answer #correct, #partial, #related (only with relatedMatching #inheritance), #incorrect, #abstained or #excluded"

	| truth ref truthNames predictionNames open strict |
	truth := anEntry truth ifNil: [ ^ #excluded ].
	ref := anEntry ref.
	truthNames := self normalizedNames: (truth resolvedClassNamesFor: ref).
	truthNames isEmpty ifTrue: [ ^ self outcomeForUnresolvedTruth: truth prediction: aPrediction ].
	(objectMeansUnknown and: [ truthNames includes: 'Object' ]) ifTrue: [ ^ self outcomeForUnknownTruthPrediction: aPrediction ].
	aPrediction isNothing ifTrue: [ ^ self outcomeForAbstention ].
	predictionNames := self normalizedNames: (aPrediction types resolvedClassNamesFor: ref).
	predictionNames isEmpty ifTrue: [ ^ self outcomeForAbstention ].
	(objectMeansUnknown and: [ predictionNames includes: 'Object' ]) ifTrue: [ ^ self outcomeForAbstention ].
	open := truth hasUnknown or: [ truth hasArgument or: [ truth hasAbstract ] ].
	strict := self
		          compare: predictionNames
		          withTruth: truthNames
		          open: open
		          ref: ref
		          matching: #strict.
	(strict = #incorrect and: [ relatedMatching = #inheritance ]) ifFalse: [ ^ strict ].
	^ (#( #correct #partial ) includes: (self
			    compare: predictionNames
			    withTruth: truthNames
			    open: open
			    ref: ref
			    matching: #inheritance))
		  ifTrue: [ #related ]
		  ifFalse: [ strict ]
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> prepared: aPrediction [
	"Answer the prediction of a tool as it takes part in the experiment (and is merged by the strategies): the names of the classes normalized, and no answer for a tool that says Object when Object means any type"

	| expression |
	aPrediction isNothing ifTrue: [ ^ aPrediction ].
	expression := aPrediction types.
	(objectMeansUnknown and: [ (self normalizedNames: expression classNames) includes: 'Object' ]) ifTrue: [
		^ HyToolPrediction nothingFrom: aPrediction toolName ].
	nameNormalization = #standard ifFalse: [ ^ aPrediction ].
	^ HyToolPrediction
		  tool: aPrediction toolName
		  types: (HyTypeExpression atoms: (expression atoms collect: [ :atom |
						    atom isClass
							    ifTrue: [ HyTypeAtom named: (self normalizedName: atom name) ]
							    ifFalse: [ atom ] ]))
		  confidence: aPrediction confidence
]

{ #category : 'settings' }
HyComparisonPolicy >> receiverMatching [
	"Answer the choice for this case: one of #definingClass #classHierarchy"

	^ receiverMatching
]

{ #category : 'settings' }
HyComparisonPolicy >> receiverMatching: aSymbol [
	"Choose what to do in this case: one of #definingClass #classHierarchy"

	(#( #definingClass #classHierarchy ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	receiverMatching := aSymbol
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> relatedMatching [
	"Answer the choice for classes related by inheritance: one of #off #inheritance"

	^ relatedMatching
]

{ #category : 'Protocol (comparing) - 18 selector(s)' }
HyComparisonPolicy >> relatedMatching: aSymbol [
	"Choose what to do with a wrong answer that would be right if a class and one of its superclasses or subclasses (not Object) were the same: #off (it stays incorrect) or #inheritance (it is #related, apart from #correct)"

	(#( #off #inheritance ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	relatedMatching := aSymbol
]

{ #category : 'settings' }
HyComparisonPolicy >> setContainingTruth [
	"Answer the choice for this case: one of #partial #correct #incorrect"

	^ setContainingTruth
]

{ #category : 'settings' }
HyComparisonPolicy >> setContainingTruth: aSymbol [
	"Choose what to do in this case: one of #partial #correct #incorrect"

	(#( #partial #correct #incorrect ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	setContainingTruth := aSymbol
]

{ #category : 'settings' }
HyComparisonPolicy >> unionTruth [
	"Answer the choice for this case: one of #correct #partial #incorrect"

	^ unionTruth
]

{ #category : 'settings' }
HyComparisonPolicy >> unionTruth: aSymbol [
	"Choose what to do in this case: one of #correct #partial #incorrect"

	(#( #correct #partial #incorrect ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	unionTruth := aSymbol
]

{ #category : 'settings' }
HyComparisonPolicy >> unknownTruth [
	"Answer the choice for this case: one of #excluded #abstentionCorrect"

	^ unknownTruth
]

{ #category : 'settings' }
HyComparisonPolicy >> unknownTruth: aSymbol [
	"Choose what to do in this case: one of #excluded #abstentionCorrect"

	(#( #excluded #abstentionCorrect ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	unknownTruth := aSymbol
]

{ #category : 'settings' }
HyComparisonPolicy >> unresolvedMembers [
	"Answer the choice for this case: one of #ignore #excluded"

	^ unresolvedMembers
]

{ #category : 'settings' }
HyComparisonPolicy >> unresolvedMembers: aSymbol [
	"Choose what to do in this case: one of #ignore #excluded"

	(#( #ignore #excluded ) includes: aSymbol) ifFalse: [ ^ self error: 'Unknown choice ' , aSymbol printString ].
	unresolvedMembers := aSymbol
]
