"
A tool whose answers were recorded earlier (in CSV files produced by running the tool on the dataset): it answers what was recorded and no answer for any other method. The CSV has the columns selector, class, package, type and optionally confidence; the type is written #Integer, or Integer | String, or nil for no answer; the quotes around the selector are ignored. Use: HyRecordedTool fromCsv: aFile name: 'J2Inferer', or fromCsvFiles: to read several files (one per group).
"
Class {
	#name : 'HyRecordedTool',
	#superclass : 'HyExpInferenceTool',
	#instVars : [
		'predictions'
	],
	#category : 'Hyphe-Experiments-Tools',
	#package : 'Hyphe-Experiments',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
HyRecordedTool class >> fromCsv: aFileOrString name: aToolName [
	"Create a tool with the answers recorded in a CSV file"

	^ self fromCsvFiles: { aFileOrString } name: aToolName
]

{ #category : 'instance creation' }
HyRecordedTool class >> fromCsvFiles: someFiles name: aToolName [
	"Create a tool with the answers recorded in several CSV files (for example one per group); files that do not exist are skipped"

	| tool |
	tool := self new
		        name: aToolName;
		        yourself.
	someFiles do: [ :each | each asFileReference exists ifTrue: [ tool recordFromCsv: each ] ].
	^ tool
]

{ #category : 'initialization' }
HyRecordedTool >> initialize [
	"Start with no recorded answer"

	super initialize.
	predictions := Dictionary new
]

{ #category : 'inferring' }
HyRecordedTool >> predictionFor: aMethodRef [
	"Answer what was recorded for the method, no answer if nothing was"

	^ predictions at: aMethodRef ifAbsent: [ self nothing ]
]

{ #category : 'recording' }
HyRecordedTool >> record: aPrediction for: aMethodRef [
	"Record the answer of the tool for a method"

	predictions at: aMethodRef put: aPrediction
]

{ #category : 'recording' }
HyRecordedTool >> recordFromCsv: aFileOrString [
	"Record the answers of a CSV file"

	(HyCsv recordsFrom: aFileOrString) do: [ :record |
			(HyMethodRef fromRecord: record) ifNotNil: [ :ref |
					self
						record: (HyToolPrediction
								 tool: name
								 types: (HyTypeExpression parse: (HyCsv record: record valueAt: #( 'type' 'typeinferred' )))
								 confidence: ((HyCsv record: record valueAt: #( 'confidence' )) ifNotNil: [ :text | text asNumber ]))
						for: ref ] ]
]

{ #category : 'accessing' }
HyRecordedTool >> size [
	"Answer the number of methods with a recorded answer (a recorded no answer counts)"

	^ predictions size
]
