"
Classes, instances, literals. Deductively certain, no subclasses considered.
"
Class {
	#name : 'HYIFixedNS',
	#superclass : 'HYIStability',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'accessing' }
HYIFixedNS class >> rank [
	"Highest rank on the min-tag axis (Sec 3.3.1) -- deductively certain evidence, whether or not subclasses are considered."

	^ 3
]

{ #category : 'instance creation' }
HYIFixedNS class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'testing' }
HYIFixedNS >> isFixed [
	"Both Fixed variants answer true here -- isFixed covers Fixed-S and Fixed-NS alike."

	^ true
]

{ #category : 'testing' }
HYIFixedNS >> isFixedNS [
	"Overrides the abstract root's default false -- this IS Fixed-NS."

	^ true
]

{ #category : 'printing' }
HYIFixedNS >> printOn: aStream [
	"Prints as 'Fixed-NS', matching the spec's own tag name."

	aStream nextPutAll: 'Fixed-NS'
]
