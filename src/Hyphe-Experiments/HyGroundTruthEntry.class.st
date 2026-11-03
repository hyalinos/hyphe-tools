"
One method of a ground truth dataset: the reference of the method, its manually verified return type (a HyTypeExpression, nil if not determined yet), a comment, and, once the dataset is grouped, the measure used to group (number of statements, of return points...) and the group (a HyMethodGroup).
"
Class {
	#name : 'HyGroundTruthEntry',
	#superclass : 'Object',
	#instVars : [
		'ref',
		'truth',
		'comment',
		'count',
		'group'
	],
	#category : 'Hyphe-Experiments-Data',
	#package : 'Hyphe-Experiments',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyGroundTruthEntry class >> ref: aMethodRef truth: aTypeExpression [
	"Create an entry"

	^ self new
		  setRef: aMethodRef truth: aTypeExpression;
		  yourself
]

{ #category : 'accessing' }
HyGroundTruthEntry >> comment [
	"Answer the comment of the annotator"

	^ comment
]

{ #category : 'accessing' }
HyGroundTruthEntry >> comment: anObject [
	"Set the comment of the annotator"

	comment := anObject
]

{ #category : 'accessing' }
HyGroundTruthEntry >> count [
	"Answer the measure used to group the entry (statements, return points...), nil before grouping"

	^ count
]

{ #category : 'accessing' }
HyGroundTruthEntry >> count: anObject [
	"Set the measure used to group the entry (statements, return points...), nil before grouping"

	count := anObject
]

{ #category : 'accessing' }
HyGroundTruthEntry >> group [
	"Answer the group of the entry (a HyMethodGroup), nil before grouping"

	^ group
]

{ #category : 'accessing' }
HyGroundTruthEntry >> group: anObject [
	"Set the group of the entry (a HyMethodGroup), nil before grouping"

	group := anObject
]

{ #category : 'printing' }
HyGroundTruthEntry >> printOn: aStream [
	"Print as Class>>#selector -> type"

	super printOn: aStream.
	aStream
		nextPut: $(;
		print: ref;
		nextPutAll: ' -> ';
		print: truth;
		nextPut: $)
]

{ #category : 'accessing' }
HyGroundTruthEntry >> ref [
	"Answer the reference of the method"

	^ ref
]

{ #category : 'initialization' }
HyGroundTruthEntry >> setRef: aMethodRef truth: aTypeExpression [
	"Set the method and its return type"

	ref := aMethodRef.
	truth := aTypeExpression
]

{ #category : 'accessing' }
HyGroundTruthEntry >> truth [
	"Answer the return type of the method (a HyTypeExpression), nil if it is not known yet"

	^ truth
]

{ #category : 'accessing' }
HyGroundTruthEntry >> truth: anObject [
	"Set the return type of the method (a HyTypeExpression), nil if it is not known yet"

	truth := anObject
]
