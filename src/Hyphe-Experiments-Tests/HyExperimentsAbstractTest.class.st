"
Superclass of the tests of Hyphe-Experiments: helpers to build method references and datasets in memory.
"
Class {
	#name : 'HyExperimentsAbstractTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Experiments-Tests',
	#package : 'Hyphe-Experiments-Tests'
}

{ #category : 'testing' }
HyExperimentsAbstractTest class >> isAbstract [
	"This class only holds helpers"

	^ self == HyExperimentsAbstractTest
]

{ #category : 'helpers' }
HyExperimentsAbstractTest >> entryOf: aRef truth: aString [
	"Answer a ground truth entry; the truth is written in the notation of the ground truth, nil for none"

	^ HyGroundTruthEntry ref: aRef truth: (HyTypeExpression parse: aString)
]

{ #category : 'helpers' }
HyExperimentsAbstractTest >> memoryFile: aName [
	"Answer a file of a fresh memory file system"

	^ FileSystem memory root / aName
]

{ #category : 'helpers' }
HyExperimentsAbstractTest >> metricsRef: aSelector [
	"Answer the reference of a method of MetricsTestData"

	^ self refOf: aSelector in: MetricsTestData
]

{ #category : 'helpers' }
HyExperimentsAbstractTest >> prediction: aTypeString tool: aName [
	"Answer a prediction of a tool, from a type in the notation (nil for no answer)"

	^ HyToolPrediction tool: aName type: aTypeString
]

{ #category : 'helpers' }
HyExperimentsAbstractTest >> refOf: aSelector in: aClass [
	"Answer the reference of a method of the image"

	^ HyMethodRef fromCompiledMethod: aClass >> aSelector
]

{ #category : 'helpers' }
HyExperimentsAbstractTest >> write: someLines to: aFile [
	"Write lines of text in a file of the memory file system and answer the file"

	aFile ensureCreateFile.
	aFile writeStreamDo: [ :stream |
			someLines do: [ :line |
					stream
						nextPutAll: line;
						lf ] ].
	^ aFile
]
