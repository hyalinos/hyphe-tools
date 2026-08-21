Class {
	#name : 'CTIBlockInfo',
	#superclass : 'Object',
	#instVars : [
		'paramVars',
		'returnVar'
	],
	#category : 'Hyphe-ReturnTypeConstraint',
	#package : 'Hyphe-ReturnTypeConstraint'
}

{ #category : 'accessing' }
CTIBlockInfo >> paramVars [

	^ paramVars
]

{ #category : 'accessing' }
CTIBlockInfo >> paramVars: coll [

	paramVars := coll
]

{ #category : 'accessing' }
CTIBlockInfo >> returnVar [

	^ returnVar
]

{ #category : 'accessing' }
CTIBlockInfo >> returnVar: v [

	returnVar := v
]
