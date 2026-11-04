"
Superclass of the tests of Hyphe-Experiments: helpers to build method references and datasets in memory.
"
Class {
	#name : 'HYEExperimentsAbstractTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Experiments-Tests',
	#package : 'Hyphe-Experiments-Tests'
}

{ #category : 'testing' }
HYEExperimentsAbstractTest class >> isAbstract [
	"This class only holds helpers"

	^ self == HYEExperimentsAbstractTest
]

{ #category : 'helpers' }
HYEExperimentsAbstractTest >> entryOf: aRef truth: aString [
	"Answer a ground truth entry; the truth is written in the notation of the ground truth, nil for none"

	^ HYEGroundTruthEntry ref: aRef truth: (HYETypeExpression parse: aString)
]

{ #category : 'helpers' }
HYEExperimentsAbstractTest >> memoryFile: aName [
	"Answer a file of a fresh memory file system"

	^ FileSystem memory root / aName
]

{ #category : 'helpers' }
HYEExperimentsAbstractTest >> metricsRef: aSelector [
	"Answer the reference of a method of MetricsTestData"

	^ self refOf: aSelector in: MetricsTestData
]

{ #category : 'helpers' }
HYEExperimentsAbstractTest >> prediction: aTypeString tool: aName [
	"Answer a prediction of a tool, from a type in the notation (nil for no answer)"

	^ HYEToolPrediction tool: aName type: aTypeString
]

{ #category : 'helpers' }
HYEExperimentsAbstractTest >> refOf: aSelector in: aClass [
	"Answer the reference of a method of the image"

	^ HYEMethodRef fromCompiledMethod: aClass >> aSelector
]

{ #category : 'helpers' }
HYEExperimentsAbstractTest >> write: someLines to: aFile [
	"Write lines of text in a file of the memory file system and answer the file"

	aFile ensureCreateFile.
	aFile writeStreamDo: [ :stream |
			someLines do: [ :line |
					stream
						nextPutAll: line;
						lf ] ].
	^ aFile
]
