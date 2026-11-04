"
Draws random methods of the image to complete the groups of a dataset that have fewer than the wanted number of methods. The pool of candidates is every method of the image (SystemNavigation default allMethods) unless another one is given with pool:. Methods already in the dataset (excluding:) are never drawn. The pool is shuffled with the random generator and scanned once: a method is taken if its group still needs methods, so each candidate has the same chance and a seeded generator (Random seed: 42) gives the same sample again. Use: sampler completeDataset: aDataset toSize: 100.
"
Class {
	#name : 'HYEMethodSampler',
	#superclass : 'Object',
	#instVars : [
		'scheme',
		'pool',
		'random',
		'excluded'
	],
	#category : 'Hyphe-Experiments-Grouping',
	#package : 'Hyphe-Experiments',
	#tag : 'Grouping'
}

{ #category : 'instance creation' }
HYEMethodSampler class >> scheme: aGroupScheme [
	"Create a sampler for the groups of a scheme; excluded methods and pool are set afterwards"

	^ self new
		  setScheme: aGroupScheme;
		  yourself
]

{ #category : 'sampling' }
HYEMethodSampler >> completeDataset: aDataset toSize: aNumber [
	"Complete each group of the dataset (see assignGroups:, which must have been sent with the same scheme) up to aNumber methods, with methods that are not in the dataset. The new entries, without type for you to fill in, are added to the dataset and answered as a dictionary group -> entries."

	| needs drawn |
	excluded := excluded union: aDataset refs.
	needs := Dictionary new.
	scheme groups do: [ :group | needs at: group put: aNumber - (aDataset entriesInGroup: group) size ].
	drawn := self sample: needs.
	drawn do: [ :entries | entries do: [ :entry | aDataset add: entry ] ].
	^ drawn
]

{ #category : 'private' }
HYEMethodSampler >> consider: aCompiledMethod remaining: remaining into: result [
	"Take the method if it is not excluded and its group still needs methods"

	| ref count group |
	ref := HYEMethodRef fromCompiledMethod: aCompiledMethod.
	(excluded includes: ref) ifTrue: [ ^ self ].
	count := [ scheme measure: aCompiledMethod ]
		         on: Error
		         do: [ nil ].
	count ifNil: [ ^ self ].
	group := scheme groupFor: count.
	group ifNil: [ ^ self ].
	(remaining at: group ifAbsent: [ 0 ]) > 0 ifFalse: [ ^ self ].

	(result at: group) add: ((HYEGroundTruthEntry ref: ref truth: nil)
			 count: count;
			 group: group;
			 yourself).
	remaining at: group put: (remaining at: group) - 1.
	(remaining at: group) = 0 ifTrue: [ remaining removeKey: group ]
]

{ #category : 'configuring' }
HYEMethodSampler >> excluding: aDatasetOrRefs [
	"Never draw the methods of a dataset (or of a collection of method references); can be sent several times, the exclusions add up"

	excluded := excluded union: ((aDatasetOrRefs isKindOf: HYEGroundTruthDataset)
			             ifTrue: [ aDatasetOrRefs refs ]
			             ifFalse: [ aDatasetOrRefs asSet ])
]

{ #category : 'accessing' }
HYEMethodSampler >> pool [
	"Answer the compiled methods to draw from; nil means every method of the image"

	^ pool
]

{ #category : 'accessing' }
HYEMethodSampler >> pool: anObject [
	"Set the compiled methods to draw from; nil means every method of the image"

	pool := anObject
]

{ #category : 'accessing' }
HYEMethodSampler >> random [
	"Answer the random generator used to shuffle the candidates; give a seeded one (Random seed: 42) to get the same sample twice"

	^ random
]

{ #category : 'accessing' }
HYEMethodSampler >> random: anObject [
	"Set the random generator used to shuffle the candidates; give a seeded one (Random seed: 42) to get the same sample twice"

	random := anObject
]

{ #category : 'sampling' }
HYEMethodSampler >> sample: aDictionaryOfNeeds [
	"Answer a dictionary group -> entries drawn (without type, with count and group set), for each group of the dictionary group -> number of methods wanted. A group may get fewer methods if the pool has not enough."

	| remaining result candidates |
	remaining := Dictionary new.
	result := Dictionary new.
	aDictionaryOfNeeds keysAndValuesDo: [ :group :number |
			number > 0 ifTrue: [ remaining at: group put: number ].
			result at: group put: OrderedCollection new ].

	candidates := (pool ifNil: [ SystemNavigation default allMethods ]) asArray copy shuffleBy: random.
	candidates do: [ :method |
			remaining isEmpty ifTrue: [ ^ result ].
			self consider: method remaining: remaining into: result ].
	^ result
]

{ #category : 'initialization' }
HYEMethodSampler >> setScheme: aGroupScheme [
	"Set the scheme; by default the pool is the image, the generator is not seeded, nothing is excluded"

	scheme := aGroupScheme.
	random := Random new.
	excluded := Set new
]
