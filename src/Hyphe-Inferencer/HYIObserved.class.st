"
Seen in actual execution; other types may exist on unexecuted paths.
"
Class {
	#name : 'HYIObserved',
	#superclass : 'HYIStability',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'accessing' }
HYIObserved class >> rank [
	"Second-highest on the min-tag axis -- seen in real execution, but other types may exist on unexecuted paths."

	^ 2
]

{ #category : 'instance creation' }
HYIObserved class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'testing' }
HYIObserved >> isObserved [
	"Overrides the abstract root's default false -- this IS Observed."

	^ true
]

{ #category : 'printing' }
HYIObserved >> printOn: aStream [
	"Prints as 'Observed'."

	aStream nextPutAll: 'Observed'
]
