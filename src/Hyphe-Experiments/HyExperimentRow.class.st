"
The result of an experiment for one method: its ground truth entry (with its group), the prediction of each source (the tools and the merging strategies, by name) and the outcome of the comparison of each prediction with the truth.
"
Class {
	#name : 'HyExperimentRow',
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
HyExperimentRow class >> entry: anEntry predictions: aDictionary outcomes: anotherDictionary [
	"Create a row"

	^ self new
		  setEntry: anEntry predictions: aDictionary outcomes: anotherDictionary;
		  yourself
]

{ #category : 'accessing' }
HyExperimentRow >> entry [
	"Answer the ground truth entry of the method"

	^ entry
]

{ #category : 'accessing' }
HyExperimentRow >> group [
	"Answer the group of the method"

	^ entry group
]

{ #category : 'accessing' }
HyExperimentRow >> outcomeOf: aSourceName [
	"Answer the outcome of the comparison of the prediction of a tool or of a strategy with the truth"

	^ outcomes at: aSourceName
]

{ #category : 'accessing' }
HyExperimentRow >> outcomes [
	"Answer the dictionary source name -> outcome (#correct #partial #incorrect #abstained #excluded)"

	^ outcomes
]

{ #category : 'accessing' }
HyExperimentRow >> predictionOf: aSourceName [
	"Answer the prediction of a tool or of a strategy"

	^ predictions at: aSourceName
]

{ #category : 'accessing' }
HyExperimentRow >> predictions [
	"Answer the dictionary source name -> HyToolPrediction (resolved), for tools and strategies"

	^ predictions
]

{ #category : 'initialization' }
HyExperimentRow >> setEntry: anEntry predictions: aDictionary outcomes: anotherDictionary [
	"Set the parts of the row"

	entry := anEntry.
	predictions := aDictionary.
	outcomes := anotherDictionary
]
