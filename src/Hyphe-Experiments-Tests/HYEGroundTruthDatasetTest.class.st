"
Tests of HYEGroundTruthDataset: reading, grouping, writing.
"
Class {
	#name : 'HYEGroundTruthDatasetTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Data',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Data'
}

{ #category : 'helpers' }
HYEGroundTruthDatasetTest >> datasetFile [
	"A CSV file in the format of the ground truth sheets, with a method that is not in the image and a line without type"

	^ self
		  write: { 'package,class,selector,countReturn,Type,Comment'. 'Hyphe-Analysis-Tests,MetricsTestData,mixedSends,0,r,'.
			  'Hyphe-Analysis-Tests,MetricsTestData,noSends,1,SmallInteger,"a, comma"'.
			  'Hyphe-Analysis-Tests,MetricsTestData,sendsToSelf,,String | ?,'.
			  'Nowhere,NoSuchClassAnywhere,foo,,Integer,'. ',,,,,'. 'Hyphe-Analysis-Tests,MetricsTestData,deepBlocks,3,,' }
		  to: (self memoryFile: 'gt.csv')
]

{ #category : 'tests' }
HYEGroundTruthDatasetTest >> testAccessors [
	"refs, entryFor:, includesRef:, asDictionary"

	| dataset ref |
	dataset := HYEGroundTruthDataset fromCsv: self datasetFile.
	ref := self metricsRef: #noSends.

	self assert: (dataset includesRef: ref).
	self deny: (dataset includesRef: (self metricsRef: #repeatedSends)).
	self assert: (dataset entryFor: ref) comment equals: 'a, comma'.
	self assert: (dataset entryFor: (self metricsRef: #repeatedSends)) isNil.
	self assert: dataset refs size equals: 5.
	self assert: (dataset asDictionary at: ref) equals: (HYETypeExpression parse: 'SmallInteger')
]

{ #category : 'tests' }
HYEGroundTruthDatasetTest >> testAssignGroups [
	"The count of each method is measured and its group found; the method that is not in the image is answered and gets none"

	| dataset missing |
	dataset := HYEGroundTruthDataset fromCsv: self datasetFile.

	missing := dataset assignGroups: HYEGroupScheme returnPoints.

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
HYEGroundTruthDatasetTest >> testFromCsv [
	"Entries with their type, comment and count; the empty line is skipped, a missing type is nil"

	| dataset |
	dataset := HYEGroundTruthDataset fromCsv: self datasetFile.

	self assert: dataset size equals: 5.
	self assert: dataset entries first ref selector equals: #mixedSends.
	self assert: dataset entries first truth equals: (HYETypeExpression parse: 'r').
	self assert: dataset entries first count equals: 0.
	self assert: dataset entries second comment equals: 'a, comma'.
	self assert: dataset entries third truth equals: (HYETypeExpression parse: 'String | ?').
	self assert: dataset entries third count isNil.
	self assert: dataset entries last truth isNil.
	self assert: dataset name equals: 'gt'
]

{ #category : 'tests' }
HYEGroundTruthDatasetTest >> testGroupSizes [
	"Number of entries per group"

	| dataset sizes |
	dataset := HYEGroundTruthDataset fromCsv: self datasetFile.
	dataset assignGroups: HYEGroupScheme returnPoints.
	sizes := dataset groupSizes.

	self assert: (sizes at: (HYEGroupScheme returnPoints groupNamed: 'G1')) equals: 2.
	self assert: (sizes at: (HYEGroupScheme returnPoints groupNamed: 'G2')) equals: 2.
	self assert: (sizes at: (HYEGroupScheme returnPoints groupNamed: 'G3')) equals: 0
]

{ #category : 'tests' }
HYEGroundTruthDatasetTest >> testWriteCsvAndReadBack [
	"The whole dataset can be written, grouped or not, and read again"

	| dataset file again |
	dataset := HYEGroundTruthDataset fromCsv: self datasetFile.
	dataset assignGroups: HYEGroupScheme returnPoints.
	file := dataset writeCsvTo: (self memoryFile: 'all.csv').
	again := HYEGroundTruthDataset fromCsv: file.

	self assert: again size equals: dataset size.
	self
		assert: (again entries collect: [ :entry | entry truth ]) asArray
		equals: (dataset entries collect: [ :entry | entry truth ]) asArray.
	self
		assert: (again entries collect: [ :entry | entry comment ]) asArray
		equals: (dataset entries collect: [ :entry | entry comment ]) asArray
]

{ #category : 'tests' }
HYEGroundTruthDatasetTest >> testWriteGroupFiles [
	"One file per group, with the columns package, class, selector and the measure (the LOC format without type and comment)"

	| dataset files records |
	dataset := HYEGroundTruthDataset fromCsv: self datasetFile.
	dataset assignGroups: HYEGroupScheme returnPoints.

	files := dataset writeGroupFilesTo: FileSystem memory root / 'groups' prefix: 'rp-'.

	self assert: (files collect: [ :file | file basename ]) asArray equals: #( 'rp-G1.csv' 'rp-G2.csv' 'rp-G3.csv' 'rp-G4.csv' ).
	records := HYECsv recordsFrom: files first.
	self assert: (records collect: [ :record | record at: 'selector' ]) asArray equals: #( 'mixedSends' 'sendsToSelf' ).
	self assert: (records first at: 'countreturn') equals: '0'.
	self assert: records first keys asSet equals: #( 'package' 'class' 'selector' 'countreturn' ) asSet.
	self assert: (HYECsv recordsFrom: files third) isEmpty
]
