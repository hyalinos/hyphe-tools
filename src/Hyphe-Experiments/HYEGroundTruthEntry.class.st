"
One method of a ground truth dataset: the reference of the method, its manually verified return type (a HYETypeExpression, nil if not determined yet), a comment, and, once the dataset is grouped, the measure used to group (number of statements, of return points...) and the group (a HYEMethodGroup).
"
Class {
	#name : 'HYEGroundTruthEntry',
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
HYEGroundTruthEntry class >> ref: aMethodRef truth: aTypeExpression [
	"Create an entry"

	^ self new
		  setRef: aMethodRef truth: aTypeExpression;
		  yourself
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> comment [
	"Answer the comment of the annotator"

	^ comment
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> comment: anObject [
	"Set the comment of the annotator"

	comment := anObject
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> count [
	"Answer the measure used to group the entry (statements, return points...), nil before grouping"

	^ count
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> count: anObject [
	"Set the measure used to group the entry (statements, return points...), nil before grouping"

	count := anObject
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> group [
	"Answer the group of the entry (a HYEMethodGroup), nil before grouping"

	^ group
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> group: anObject [
	"Set the group of the entry (a HYEMethodGroup), nil before grouping"

	group := anObject
]

{ #category : 'printing' }
HYEGroundTruthEntry >> printOn: aStream [
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
HYEGroundTruthEntry >> ref [
	"Answer the reference of the method"

	^ ref
]

{ #category : 'initialization' }
HYEGroundTruthEntry >> setRef: aMethodRef truth: aTypeExpression [
	"Set the method and its return type"

	ref := aMethodRef.
	truth := aTypeExpression
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> truth [
	"Answer the return type of the method (a HYETypeExpression), nil if it is not known yet"

	^ truth
]

{ #category : 'accessing' }
HYEGroundTruthEntry >> truth: anObject [
	"Set the return type of the method (a HYETypeExpression), nil if it is not known yet"

	truth := anObject
]
