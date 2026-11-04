"
A group of methods defined by a range of a measure: from lower to upper, both included, upper nil when there is no upper limit. The name is short (G1), the label tells the range (2-3 statements).
"
Class {
	#name : 'HYEMethodGroup',
	#superclass : 'Object',
	#instVars : [
		'name',
		'label',
		'lower',
		'upper'
	],
	#category : 'Hyphe-Experiments-Grouping',
	#package : 'Hyphe-Experiments',
	#tag : 'Grouping'
}

{ #category : 'instance creation' }
HYEMethodGroup class >> name: aName label: aLabel lower: aLowerNumber upper: anUpperNumberOrNil [
	"Create a group"

	^ self new
		  setName: aName
		  label: aLabel
		  lower: aLowerNumber
		  upper: anUpperNumberOrNil;
		  yourself
]

{ #category : 'comparing' }
HYEMethodGroup >> = anObject [
	"Two groups are equal when they have the same name and the same range, so groups of two schemes of the same kind are interchangeable"

	^ self class == anObject class and: [ name = anObject name and: [ lower = anObject lower and: [ upper = anObject upper ] ] ]
]

{ #category : 'comparing' }
HYEMethodGroup >> hash [
	"Hash of the name and of the range"

	^ (name hash bitXor: lower hash) bitXor: upper hash
]

{ #category : 'testing' }
HYEMethodGroup >> includes: aNumber [
	"Answer true if the value belongs to the group"

	^ aNumber >= lower and: [ upper isNil or: [ aNumber <= upper ] ]
]

{ #category : 'accessing' }
HYEMethodGroup >> label [
	"Answer the description of the range"

	^ label
]

{ #category : 'accessing' }
HYEMethodGroup >> lower [
	"Answer the smallest value of the group"

	^ lower
]

{ #category : 'accessing' }
HYEMethodGroup >> name [
	"Answer the short name of the group, G1..."

	^ name
]

{ #category : 'printing' }
HYEMethodGroup >> printOn: aStream [
	"Print as G1 (1 statement)"

	aStream
		nextPutAll: name;
		nextPutAll: ' (';
		nextPutAll: label;
		nextPut: $)
]

{ #category : 'initialization' }
HYEMethodGroup >> setName: aName label: aLabel lower: aLowerNumber upper: anUpperNumberOrNil [
	"Set the parts of the group"

	name := aName.
	label := aLabel.
	lower := aLowerNumber.
	upper := anUpperNumberOrNil
]

{ #category : 'accessing' }
HYEMethodGroup >> upper [
	"Answer the largest value of the group, nil if there is none"

	^ upper
]
