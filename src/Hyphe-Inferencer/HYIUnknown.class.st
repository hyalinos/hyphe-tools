"
Not computed yet. Per the spec's worked examples this tag is only ever paired with Top as its tau (Unknown(Top)) -- enforced by HYITypeVariant's constructors.
"
Class {
	#name : 'HYIUnknown',
	#superclass : 'HYIStability',
	#classInstVars : [
		'Instance'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'accessing' }
HYIUnknown class >> rank [
	"Lowest on the min-tag axis -- not computed yet; always dissolves against any other tag on merge."

	^ 0
]

{ #category : 'instance creation' }
HYIUnknown class >> value [
	"The singleton accessor -- lazily creates the one instance on first use."

	^ Instance ifNil: [ Instance := self new ]
]

{ #category : 'testing' }
HYIUnknown >> isUnknown [
	"Overrides the abstract root's default false -- this IS Unknown."

	^ true
]

{ #category : 'printing' }
HYIUnknown >> printOn: aStream [
	"Prints as 'Unknown'."

	aStream nextPutAll: 'Unknown'
]
