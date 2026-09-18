"
The unconstrained tau: 'no information, any type'. Singleton (use HYITop value). Per AGENT_BRIEF.md, atomic and never carries a Stability tag -- except as the sole payload of Unknown(Top), a special sentinel meaning 'not computed yet' (see HYITypeVariant class>>validateTau:stability:). Distinguish from bare Top, which means 'genuinely unconstrained'.
"
Class {
	#name : 'HYITop',
	#superclass : 'HYIType',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYITop class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'comparing' }
HYITop >> = other [
	"All instances of a singleton class are interchangeable -- equality is purely by class."

	^ other class == self class
]

{ #category : 'comparing' }
HYITop >> hash [
	"Consistent with =."

	^ self class hash
]

{ #category : 'testing' }
HYITop >> isTop [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'printing' }
HYITop >> printOn: aStream [
	"Prints as the spec's own name for this atomic production."

	aStream nextPutAll: 'Top'
]
