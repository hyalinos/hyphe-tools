"
A set of methods with their manually verified return types (HYEGroundTruthEntry). Read from a CSV file (fromCsv:) with the columns package, class, selector, type, comment and optionally a count; split in groups with assignGroups: (it measures each method of the image and finds its group); written group by group with writeGroupFilesTo:prefix: in the format of the LOC files without type and comment, plus the count column. asDictionary gives ref -> type.
"
Class {
	#name : 'HYEGroundTruthDataset',
	#superclass : 'Object',
	#instVars : [
		'name',
		'entries',
		'scheme'
	],
	#category : 'Hyphe-Experiments-Data',
	#package : 'Hyphe-Experiments',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HYEGroundTruthDataset class >> fromCsv: aFileOrString [
	"Read a dataset from a CSV file. Accepted columns, in any order: package, class (or className), selector (or methodSelector...), type (or typeCollected), comment, count (or countReturn, countStatement...). Lines without class or selector are skipped; a missing type is no type (nil)."

	| dataset |
	dataset := self named: aFileOrString asFileReference basenameWithoutExtension.
	(HYECsv recordsFrom: aFileOrString) do: [ :record |
			(HYEMethodRef fromRecord: record) ifNotNil: [ :ref |
					| entry |
					entry := HYEGroundTruthEntry
						         ref: ref
						         truth: (HYETypeExpression parse: (HYECsv record: record valueAt: #( 'type' 'typecollected' ))).
					entry comment: (HYECsv record: record valueAt: #( 'comment' )).
					(HYECsv record: record valueAt: #( 'count' 'countreturn' 'countresult' 'countstatement' 'countstatements' )) ifNotNil: [ :text |
						entry count: text asNumber ].
					dataset add: entry ] ].
	^ dataset
]

{ #category : 'instance creation' }
HYEGroundTruthDataset class >> named: aName [
	"Create an empty dataset"

	^ self new
		  setName: aName;
		  yourself
]

{ #category : 'adding' }
HYEGroundTruthDataset >> add: anEntry [
	"Add an entry and answer it"

	^ entries add: anEntry
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> asDictionary [
	"Answer a dictionary method reference -> type (HYETypeExpression, or nil if not determined)"

	| dictionary |
	dictionary := Dictionary new.
	entries do: [ :entry | dictionary at: entry ref put: entry truth ].
	^ dictionary
]

{ #category : 'grouping' }
HYEGroundTruthDataset >> assignGroups: aGroupScheme [
	"Measure each method of the dataset (statements, return points...) with the scheme and set the count and the group of its entry. Answer the entries whose method is not in the image: they get no count and no group."

	| missing |
	scheme := aGroupScheme.
	missing := OrderedCollection new.
	entries do: [ :entry |
			entry ref compiledMethod
				ifNil: [
						entry count: nil.
						entry group: nil.
						missing add: entry ]
				ifNotNil: [ :method |
						entry count: (aGroupScheme measure: method).
						entry group: (aGroupScheme groupFor: entry count) ] ].
	^ missing
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> entries [
	"Answer the entries, in order"

	^ entries
]

{ #category : 'grouping' }
HYEGroundTruthDataset >> entriesInGroup: aGroup [
	"Answer the entries of a group (after assignGroups:)"

	^ entries select: [ :entry | entry group = aGroup ]
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> entryFor: aMethodRef [
	"Answer the entry of a method, nil if there is none"

	^ entries detect: [ :entry | entry ref = aMethodRef ] ifNone: [ nil ]
]

{ #category : 'grouping' }
HYEGroundTruthDataset >> groupSizes [
	"Answer a dictionary group -> number of entries, for all the groups of the scheme (after assignGroups:)"

	| sizes |
	sizes := Dictionary new.
	scheme groups do: [ :group | sizes at: group put: (self entriesInGroup: group) size ].
	^ sizes
]

{ #category : 'testing' }
HYEGroundTruthDataset >> includesRef: aMethodRef [
	"Answer true if the dataset has an entry for the method"

	^ entries anySatisfy: [ :entry | entry ref = aMethodRef ]
]

{ #category : 'initialization' }
HYEGroundTruthDataset >> initialize [
	"A new dataset is empty"

	super initialize.
	entries := OrderedCollection new
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> name [
	"Answer the name of the dataset"

	^ name
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> name: anObject [
	"Set the name of the dataset"

	name := anObject
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> refs [
	"Answer the set of the references of the methods of the dataset"

	^ (entries collect: [ :entry | entry ref ]) asSet
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> scheme [
	"Answer the group scheme used by the last assignGroups:, nil before"

	^ scheme
]

{ #category : 'initialization' }
HYEGroundTruthDataset >> setName: aName [
	"Set the name and start empty"

	name := aName.
	entries := OrderedCollection new
]

{ #category : 'accessing' }
HYEGroundTruthDataset >> size [
	"Answer the number of entries"

	^ entries size
]

{ #category : 'writing' }
HYEGroundTruthDataset >> writeCsvTo: aFileOrString [
	"Write the whole dataset: package, class, selector, type, comment, and the count if the dataset was grouped. Answer the file."

	^ HYECsv
		  write:
			  { (#( 'package' 'class' 'selector' 'type' 'comment' ) , { (scheme ifNil: [ 'count' ] ifNotNil: [ scheme metricName ]) }) }
			  , (entries collect: [ :entry |
						   {
							   entry ref package.
							   entry ref className.
							   entry ref selector.
							   entry truth.
							   entry comment.
							   entry count } ])
		  to: aFileOrString
]

{ #category : 'writing' }
HYEGroundTruthDataset >> writeGroupFilesTo: aDirectory prefix: aString [
	"Write one CSV file per group of the scheme (after assignGroups:), named prefix + group name + .csv (G1.csv...), with the columns package, class, selector and the name of the measure. This is the format of the LOC files, without type and comment. Answer the files."

	| directory |
	directory := aDirectory asFileReference.
	^ scheme groups collect: [ :group |
			  HYECsv
				  write: { {
						  'package'.
						  'class'.
						  'selector'.
						  scheme metricName } } , ((self entriesInGroup: group) collect: [ :entry |
							   {
								   entry ref package.
								   entry ref className.
								   entry ref selector.
								   entry count } ])
				  to: directory / (aString , group name , '.csv') ]
]
