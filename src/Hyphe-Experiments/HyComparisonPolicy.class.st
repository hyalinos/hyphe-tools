"
The rules to compare what a tool answered with the ground truth: outcomeOf:for: answers #correct, #partial, #incorrect, #abstained (the tool did not answer, which is not counted as an error) or #excluded (the method cannot be used for this comparison). The experiment document leaves several cases to decide (marked TBD there); each is a setting with the default chosen here, and the other choice stays available. setContainingTruth: the tool says a set of types that includes the right one: #partial (default), #correct or #incorrect. unionTruth: the truth is a union (String | Integer) and the tool gives one of its members: #correct (default), #partial, #incorrect. abstention: the tool gives no answer: #abstain (default, not an error) or #incorrect. receiverMatching: truth r matches a tool that says the class of the method (#definingClass, default) or also a superclass or a subclass of it (#classHierarchy). argumentTruth: truth a_n, the type of an argument, which a tool cannot know: #excluded (default) or #incorrect. unknownTruth: truth ? or !, no type to find: #excluded (default) or #abstentionCorrect (right if the tool abstains, wrong if it answers). unresolvedMembers: the truth has also ? or a_n members (String | ?) and the tool says another type: #ignore (default, incorrect) or #excluded. Predictions and truths should be compared after resolvedFor: (r is the class of the method).
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
		'unresolvedMembers'
	],
	#category : 'Hyphe-Experiments-Comparison',
	#package : 'Hyphe-Experiments',
	#tag : 'Comparison'
}

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

{ #category : 'private' }
HyComparisonPolicy >> compare: predictionNames withTruth: truthNames open: isOpen ref: aMethodRef [
	"Compare two sets of class names. Equal sets are correct. Predicted types that are all in the truth but do not cover it (a member of a union): unionTruth for one type, partial for several. Predicted types that cover the truth but have more (or only overlap it): setContainingTruth. No common type: incorrect, or excluded if the truth is open (has ? or an argument) and unresolvedMembers is #excluded."

	| allPredictionsMatch allTruthCovered anyMatch |
	allPredictionsMatch := predictionNames allSatisfy: [ :predicted |
		                       truthNames anySatisfy: [ :expected | self name: predicted matches: expected ref: aMethodRef ] ].
	allTruthCovered := truthNames allSatisfy: [ :expected |
		                   predictionNames anySatisfy: [ :predicted | self name: predicted matches: expected ref: aMethodRef ] ].
	anyMatch := predictionNames anySatisfy: [ :predicted |
		            truthNames anySatisfy: [ :expected | self name: predicted matches: expected ref: aMethodRef ] ].

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

{ #category : 'initialization' }
HyComparisonPolicy >> initialize [
	"The default choices, see the class comment"

	super initialize.
	setContainingTruth := #partial.
	unionTruth := #correct.
	abstention := #abstain.
	receiverMatching := #definingClass.
	argumentTruth := #excluded.
	unknownTruth := #excluded.
	unresolvedMembers := #ignore
]

{ #category : 'private' }
HyComparisonPolicy >> is: aName relatedTo: anotherName [
	"Answer true if one of the two classes is a subclass of the other (classes that are not in the image are not related)"

	| first second |
	first := Smalltalk globals at: aName asSymbol ifAbsent: [ ^ false ].
	second := Smalltalk globals at: anotherName asSymbol ifAbsent: [ ^ false ].
	^ (first isBehavior and: [ second isBehavior ]) and: [ (first inheritsFrom: second) or: [ second inheritsFrom: first ] ]
]

{ #category : 'private' }
HyComparisonPolicy >> name: aPredictedName matches: anExpectedName ref: aMethodRef [
	"Two class names match when they are equal; with #classHierarchy, the class of the method also matches its superclasses and subclasses"

	aPredictedName = anExpectedName ifTrue: [ ^ true ].
	(receiverMatching = #classHierarchy and: [ anExpectedName = aMethodRef className ]) ifFalse: [ ^ false ].
	^ self is: aPredictedName relatedTo: anExpectedName
]

{ #category : 'private' }
HyComparisonPolicy >> outcomeForAbstention [
	"What it means that the tool did not answer"

	^ abstention = #abstain
		  ifTrue: [ #abstained ]
		  ifFalse: [ #incorrect ]
]

{ #category : 'private' }
HyComparisonPolicy >> outcomeForUnresolvedTruth: aTruth prediction: aPrediction [
	"The truth has no class: it is the type of an argument, or ? / !, which a tool cannot be asked"

	aTruth hasArgument ifTrue: [
			^ argumentTruth = #excluded
				  ifTrue: [ #excluded ]
				  ifFalse: [ #incorrect ] ].
	^ unknownTruth = #excluded
		  ifTrue: [ #excluded ]
		  ifFalse: [
				  aPrediction isNothing
					  ifTrue: [ #correct ]
					  ifFalse: [ #incorrect ] ]
]

{ #category : 'comparing' }
HyComparisonPolicy >> outcomeOf: aPrediction for: anEntry [
	"Compare the prediction of a tool with the ground truth of an entry: answer #correct, #partial, #incorrect, #abstained or #excluded"

	| truth ref truthNames predictionNames |
	truth := anEntry truth ifNil: [ ^ #excluded ].
	ref := anEntry ref.
	truthNames := truth resolvedClassNamesFor: ref.
	truthNames isEmpty ifTrue: [ ^ self outcomeForUnresolvedTruth: truth prediction: aPrediction ].
	aPrediction isNothing ifTrue: [ ^ self outcomeForAbstention ].
	predictionNames := aPrediction types resolvedClassNamesFor: ref.
	predictionNames isEmpty ifTrue: [ ^ self outcomeForAbstention ].
	^ self
		  compare: predictionNames
		  withTruth: truthNames
		  open: (truth hasUnknown or: [ truth hasArgument or: [ truth hasAbstract ] ])
		  ref: ref
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
