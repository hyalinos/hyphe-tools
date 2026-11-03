"
Tests of HyGroundTruthDataset: reading, grouping, writing.
"
Class {
	#name : 'HyGroundTruthDatasetTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Data',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Data'
}

{ #category : 'helpers' }
HyGroundTruthDatasetTest >> datasetFile [
	"A CSV file in the format of the ground truth sheets, with a method that is not in the image and a line without type"

	^ self
		  write: { 'package,class,selector,countReturn,Type,Comment'. 'Hyphe-Analysis-Tests,MetricsTestData,mixedSends,0,r,'.
			  'Hyphe-Analysis-Tests,MetricsTestData,noSends,1,SmallInteger,"a, comma"'.
			  'Hyphe-Analysis-Tests,MetricsTestData,sendsToSelf,,String | ?,'.
			  'Nowhere,NoSuchClassAnywhere,foo,,Integer,'. ',,,,,'. 'Hyphe-Analysis-Tests,MetricsTestData,deepBlocks,3,,' }
		  to: (self memoryFile: 'gt.csv')
]

{ #category : 'tests' }
HyGroundTruthDatasetTest >> testAccessors [
	"refs, entryFor:, includesRef:, asDictionary"

	| dataset ref |
	dataset := HyGroundTruthDataset fromCsv: self datasetFile.
	ref := self metricsRef: #noSends.

	self assert: (dataset includesRef: ref).
	self deny: (dataset includesRef: (self metricsRef: #repeatedSends)).
	self assert: (dataset entryFor: ref) comment equals: 'a, comma'.
	self assert: (dataset entryFor: (self metricsRef: #repeatedSends)) isNil.
	self assert: dataset refs size equals: 5.
	self assert: (dataset asDictionary at: ref) equals: (HyTypeExpression parse: 'SmallInteger')
]

{ #category : 'tests' }
HyGroundTruthDatasetTest >> testAssignGroups [
	"The count of each method is measured and its group found; the method that is not in the image is answered and gets none"

	| dataset missing |
	dataset := HyGroundTruthDataset fromCsv: self datasetFile.

	missing := dataset assignGroups: HyGroupScheme returnPoints.

	self assert: missing size equals: 1.
	self assert: missing first ref className equals: 'NoSuchClassAnywhere'.
	self assert: missing first group isNil.
	self assert: dataset entries first count equals: 0.
	self assert: dataset entries first group name equals: 'G1'.
	self assert: dataset entries second count equals: 1.
	self assert: dataset entries second group name equals: 'G2'.
	self assert: dataset scheme metricName equals: 'countReturn'
]

{ #category : 'tests' }
HyGroundTruthDatasetTest >> testFromCsv [
	"Entries with their type, comment and count; the empty line is skipped, a missing type is nil"

	| dataset |
	dataset := HyGroundTruthDataset fromCsv: self datasetFile.

	self assert: dataset size equals: 5.
	self assert: dataset entries first ref selector equals: #mixedSends.
	self assert: dataset entries first truth equals: (HyTypeExpression parse: 'r').
	self assert: dataset entries first count equals: 0.
	self assert: dataset entries second comment equals: 'a, comma'.
	self assert: dataset entries third truth equals: (HyTypeExpression parse: 'String | ?').
	self assert: dataset entries third count isNil.
	self assert: dataset entries last truth isNil.
	self assert: dataset name equals: 'gt'
]

{ #category : 'tests' }
HyGroundTruthDatasetTest >> testGroupSizes [
	"Number of entries per group"

	| dataset sizes |
	dataset := HyGroundTruthDataset fromCsv: self datasetFile.
	dataset assignGroups: HyGroupScheme returnPoints.
	sizes := dataset groupSizes.

	self assert: (sizes at: (HyGroupScheme returnPoints groupNamed: 'G1')) equals: 2.
	self assert: (sizes at: (HyGroupScheme returnPoints groupNamed: 'G2')) equals: 2.
	self assert: (sizes at: (HyGroupScheme returnPoints groupNamed: 'G3')) equals: 0
]

{ #category : 'tests' }
HyGroundTruthDatasetTest >> testWriteCsvAndReadBack [
	"The whole dataset can be written, grouped or not, and read again"

	| dataset file again |
	dataset := HyGroundTruthDataset fromCsv: self datasetFile.
	dataset assignGroups: HyGroupScheme returnPoints.
	file := dataset writeCsvTo: (self memoryFile: 'all.csv').
	again := HyGroundTruthDataset fromCsv: file.

	self assert: again size equals: dataset size.
	self
		assert: (again entries collect: [ :entry | entry truth ]) asArray
		equals: (dataset entries collect: [ :entry | entry truth ]) asArray.
	self
		assert: (again entries collect: [ :entry | entry comment ]) asArray
		equals: (dataset entries collect: [ :entry | entry comment ]) asArray
]

{ #category : 'tests' }
HyGroundTruthDatasetTest >> testWriteGroupFiles [
	"One file per group, with the columns package, class, selector and the measure (the LOC format without type and comment)"

	| dataset files records |
	dataset := HyGroundTruthDataset fromCsv: self datasetFile.
	dataset assignGroups: HyGroupScheme returnPoints.

	files := dataset writeGroupFilesTo: FileSystem memory root / 'groups' prefix: 'rp-'.

	self assert: (files collect: [ :file | file basename ]) asArray equals: #( 'rp-G1.csv' 'rp-G2.csv' 'rp-G3.csv' 'rp-G4.csv' ).
	records := HyCsv recordsFrom: files first.
	self assert: (records collect: [ :record | record at: 'selector' ]) asArray equals: #( 'mixedSends' 'sendsToSelf' ).
	self assert: (records first at: 'countreturn') equals: '0'.
	self assert: records first keys asSet equals: #( 'package' 'class' 'selector' 'countreturn' ) asSet.
	self assert: (HyCsv recordsFrom: files third) isEmpty
]
