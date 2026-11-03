"
Counts of the outcomes of a comparison (#correct #partial #incorrect #abstained #excluded) and the rates computed from them. evaluated: everything but the excluded methods; answered: the ones where the tool gave an answer (correct, partial and incorrect). accuracy is correct over answered (nil when nothing is answered), accuracyWithPartial counts partial as correct, coverage is answered over evaluated.
"
Class {
	#name : 'HyOutcomeTally',
	#superclass : 'Object',
	#instVars : [
		'counts'
	],
	#category : 'Hyphe-Experiments-Comparison',
	#package : 'Hyphe-Experiments',
	#tag : 'Comparison'
}

{ #category : 'accessing' }
HyOutcomeTally >> abstained [
	"Answer how many outcomes are abstained"

	^ counts at: #abstained
]

{ #category : 'rates' }
HyOutcomeTally >> accuracy [
	"Answer correct / answered, nil if the tool answered nothing"

	^ self answered = 0 ifFalse: [ self correct / self answered ]
]

{ #category : 'rates' }
HyOutcomeTally >> accuracyWithPartial [
	"Answer (correct + partial) / answered, nil if the tool answered nothing"

	^ self answered = 0 ifFalse: [ self correct + self partial / self answered ]
]

{ #category : 'adding' }
HyOutcomeTally >> add: anOutcome [
	"Count one outcome"

	counts at: anOutcome put: (counts at: anOutcome) + 1
]

{ #category : 'accessing' }
HyOutcomeTally >> answered [
	"Answer how many times the tool gave an answer"

	^ self correct + self partial + self incorrect
]

{ #category : 'accessing' }
HyOutcomeTally >> correct [
	"Answer how many outcomes are correct"

	^ counts at: #correct
]

{ #category : 'rates' }
HyOutcomeTally >> coverage [
	"Answer answered / evaluated, nil if nothing was evaluated"

	^ self evaluated = 0 ifFalse: [ self answered / self evaluated ]
]

{ #category : 'accessing' }
HyOutcomeTally >> evaluated [
	"Answer how many methods took part in the comparison (all but the excluded ones)"

	^ self answered + self abstained
]

{ #category : 'accessing' }
HyOutcomeTally >> excluded [
	"Answer how many outcomes are excluded"

	^ counts at: #excluded
]

{ #category : 'accessing' }
HyOutcomeTally >> incorrect [
	"Answer how many outcomes are incorrect"

	^ counts at: #incorrect
]

{ #category : 'initialization' }
HyOutcomeTally >> initialize [
	"Start with all the counts at 0"

	super initialize.
	counts := Dictionary new.
	#( #correct #partial #incorrect #abstained #excluded ) do: [ :outcome | counts at: outcome put: 0 ]
]

{ #category : 'accessing' }
HyOutcomeTally >> partial [
	"Answer how many outcomes are partial"

	^ counts at: #partial
]

{ #category : 'printing' }
HyOutcomeTally >> printOn: aStream [
	"Print the counts"

	super printOn: aStream.
	aStream nextPut: $(.
	#( #correct #partial #incorrect #abstained #excluded )
		do: [ :outcome |
				aStream
					nextPutAll: outcome;
					nextPut: $=;
					print: (counts at: outcome) ]
		separatedBy: [ aStream space ].
	aStream nextPut: $)
]
