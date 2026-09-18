"
Predicted by a heuristic or LLM. Probabilistic, not verified.
"
Class {
	#name : 'HYIGuessed',
	#superclass : 'HYIStability',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'accessing' }
HYIGuessed class >> rank [
	"Second-lowest on the min-tag axis -- predicted by a heuristic or LLM, probabilistic and unverified."

	^ 1
]

{ #category : 'instance creation' }
HYIGuessed class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'testing' }
HYIGuessed >> isGuessed [
	"Overrides the abstract root's default false -- this IS Guessed."

	^ true
]

{ #category : 'printing' }
HYIGuessed >> printOn: aStream [
	"Prints as 'Guessed'."

	aStream nextPutAll: 'Guessed'
]
