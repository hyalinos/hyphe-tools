"
self/super. Deductively certain, subclasses of the true receiver considered.
"
Class {
	#name : 'HYIFixedS',
	#superclass : 'HYIStability',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'accessing' }
HYIFixedS class >> rank [
	"Highest rank on the min-tag axis (Sec 3.3.1) -- deductively certain evidence, whether or not subclasses are considered."

	^ 3
]

{ #category : 'instance creation' }
HYIFixedS class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'testing' }
HYIFixedS >> isFixed [
	"Both Fixed variants answer true here -- isFixed covers Fixed-S and Fixed-NS alike."

	^ true
]

{ #category : 'testing' }
HYIFixedS >> isFixedS [
	"Overrides the abstract root's default false -- this IS Fixed-S."

	^ true
]

{ #category : 'printing' }
HYIFixedS >> printOn: aStream [
	"Prints as 'Fixed-S', matching the spec's own tag name."

	aStream nextPutAll: 'Fixed-S'
]
