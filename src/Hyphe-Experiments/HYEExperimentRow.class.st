"
The result of an experiment for one method: its ground truth entry (with its group), the prediction of each source (the tools and the merging strategies, by name) and the outcome of the comparison of each prediction with the truth.
"
Class {
	#name : 'HYEExperimentRow',
	#superclass : 'Object',
	#instVars : [
		'entry',
		'predictions',
		'outcomes'
	],
	#category : 'Hyphe-Experiments-Analysis',
	#package : 'Hyphe-Experiments',
	#tag : 'Analysis'
}

{ #category : 'instance creation' }
HYEExperimentRow class >> entry: anEntry predictions: aDictionary outcomes: anotherDictionary [
	"Create a row"

	^ self new
		  setEntry: anEntry predictions: aDictionary outcomes: anotherDictionary;
		  yourself
]

{ #category : 'accessing' }
HYEExperimentRow >> entry [
	"Answer the ground truth entry of the method"

	^ entry
]

{ #category : 'accessing' }
HYEExperimentRow >> group [
	"Answer the group of the method"

	^ entry group
]

{ #category : 'accessing' }
HYEExperimentRow >> outcomeOf: aSourceName [
	"Answer the outcome of the comparison of the prediction of a tool or of a strategy with the truth"

	^ outcomes at: aSourceName
]

{ #category : 'accessing' }
HYEExperimentRow >> outcomes [
	"Answer the dictionary source name -> outcome (#correct #partial #incorrect #abstained #excluded)"

	^ outcomes
]

{ #category : 'accessing' }
HYEExperimentRow >> predictionOf: aSourceName [
	"Answer the prediction of a tool or of a strategy"

	^ predictions at: aSourceName
]

{ #category : 'accessing' }
HYEExperimentRow >> predictions [
	"Answer the dictionary source name -> HYEToolPrediction (resolved), for tools and strategies"

	^ predictions
]

{ #category : 'initialization' }
HYEExperimentRow >> setEntry: anEntry predictions: aDictionary outcomes: anotherDictionary [
	"Set the parts of the row"

	entry := anEntry.
	predictions := aDictionary.
	outcomes := anotherDictionary
]
