Class {
	#name : 'CTIConfig',
	#superclass : 'Object',
	#instVars : [
		'basicNewHeuristic',
		'blockEvaluationHeuristic',
		'arithmeticHeuristic',
		'singleImplementorHeuristic'
	],
	#category : 'Hyphe-ReturnTypeConstraint',
	#package : 'Hyphe-ReturnTypeConstraint'
}

{ #category : 'accessing' }
CTIConfig >> allHeuristicNames [

	^ #( #basicNewHeuristic #blockEvaluationHeuristic #arithmeticHeuristic #singleImplementorHeuristic )
]

{ #category : 'accessing' }
CTIConfig >> arithmeticHeuristic [

	^ arithmeticHeuristic
]

{ #category : 'accessing' }
CTIConfig >> arithmeticHeuristic: aBool [

	arithmeticHeuristic := aBool
]

{ #category : 'accessing' }
CTIConfig >> basicNewHeuristic [

	^ basicNewHeuristic
]

{ #category : 'accessing' }
CTIConfig >> basicNewHeuristic: aBool [

	basicNewHeuristic := aBool
]

{ #category : 'accessing' }
CTIConfig >> blockEvaluationHeuristic [

	^ blockEvaluationHeuristic
]

{ #category : 'accessing' }
CTIConfig >> blockEvaluationHeuristic: aBool [

	blockEvaluationHeuristic := aBool
]

{ #category : 'initialization' }
CTIConfig >> initialize [

	super initialize.
	basicNewHeuristic := true.
	blockEvaluationHeuristic := true.
	arithmeticHeuristic := true.
	singleImplementorHeuristic := true
]

{ #category : 'accessing' }
CTIConfig >> singleImplementorHeuristic [

	^ singleImplementorHeuristic
]

{ #category : 'accessing' }
CTIConfig >> singleImplementorHeuristic: aBool [

	singleImplementorHeuristic := aBool
]
