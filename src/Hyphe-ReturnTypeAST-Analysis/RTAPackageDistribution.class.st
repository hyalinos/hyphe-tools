"
Groups ARTIMethodResult by packageName and builds one RTATypeDistribution per package,
so type-category counts/percentages (see RTATypeDistribution) can be compared across packages --
e.g. which package leans most heavily on Unknown, or has the most Bottom methods. #printReport gives
a quick text table; #printCountsCSVTo:/#printPercentagesCSVTo: give spreadsheet-friendly exports.
"
Class {
	#name : 'RTAPackageDistribution',
	#superclass : 'Object',
	#instVars : [
		'distributionsByPackage'
	],
	#category : 'Hyphe-ReturnTypeAST-Analysis-Statistics',
	#package : 'Hyphe-ReturnTypeAST-Analysis',
	#tag : 'Statistics'
}

{ #category : 'instance creation' }
RTAPackageDistribution class >> onReport: anARTIInferenceReport [

	^ self onResults: anARTIInferenceReport results
]

{ #category : 'instance creation' }
RTAPackageDistribution class >> onResults: aCollectionOfARTIMethodResult [

	^ self new
		  setResults: aCollectionOfARTIMethodResult;
		  yourself
]

{ #category : 'accessing' }
RTAPackageDistribution >> distributionFor: aPackageName [

	^ distributionsByPackage at: aPackageName
]

{ #category : 'accessing' }
RTAPackageDistribution >> packageNames [
	"Alphabetically sorted, for stable, comparable report/CSV row order."

	^ distributionsByPackage keys asSortedCollection asOrderedCollection
]

{ #category : 'private' }
RTAPackageDistribution >> paddedLeftOf: aString to: aWidth [

	^ (String
		   new: (aWidth - aString size max: 0)
		   withAll: Character space) , aString
]

{ #category : 'private' }
RTAPackageDistribution >> paddedRightOf: aString to: aWidth [

	^ aString
	  ,
	  (String
		   new: (aWidth - aString size max: 0)
		   withAll: Character space)
]

{ #category : 'printing' }
RTAPackageDistribution >> printCountsCSVTo: aFileReference [
	"One row per package: Package, Total, then one column per type category (raw counts)."

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream |
			ZnBufferedWriteStream
				on: stream
				do: [ :out |
						| writer header |
						writer := NeoCSVWriter on: out.
						header := OrderedCollection new.
						header
							add: #Package;
							add: #Total.
						header addAll: RTATypeDistribution categories.
						writer writeHeader: header.
						self packageNames do: [ :packageName |
								| dist row |
								dist := self distributionFor: packageName.
								row := OrderedCollection new.
								row
									add: packageName;
									add: dist total.
								RTATypeDistribution categories do: [ :category |
									row add: (dist countFor: category) ].
								writer nextPut: row ] ] ]
]

{ #category : 'printing' }
RTAPackageDistribution >> printPercentagesCSVTo: aFileReference [
	"One row per package: Package, Total, then one column per type category (percentage of that
	package's own total, 2 decimal places) -- for comparing packages of very different sizes."

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream |
			ZnBufferedWriteStream
				on: stream
				do: [ :out |
						| writer header |
						writer := NeoCSVWriter on: out.
						header := OrderedCollection new.
						header
							add: #Package;
							add: #Total.
						header addAll: RTATypeDistribution categories.
						writer writeHeader: header.
						self packageNames do: [ :packageName |
								| dist row |
								dist := self distributionFor: packageName.
								row := OrderedCollection new.
								row
									add: packageName;
									add: dist total.
								RTATypeDistribution categories do: [ :category |
									row add:
										((dist percentageFor: category) printShowingDecimalPlaces: 2) ].
								writer nextPut: row ] ] ]
]

{ #category : 'printing' }
RTAPackageDistribution >> printReport [
	"A quick text comparison table: one row per package (plus a TOTAL row), one column per category
	plus Total. Counts only -- see #printPercentagesCSVTo: for a percentage-based comparison."

	| stream nameWidth colWidth |
	stream := WriteStream on: String new.
	nameWidth := 24.
	colWidth := 10.
	stream nextPutAll: (self paddedRightOf: 'Package' to: nameWidth).
	stream nextPutAll: (self paddedLeftOf: 'Total' to: colWidth).
	RTATypeDistribution categories do: [ :category |
		stream nextPutAll:
			(self paddedLeftOf: category asString to: colWidth) ].
	stream nextPut: Character lf.

	self packageNames do: [ :packageName |
			| dist |
			dist := self distributionFor: packageName.
			stream nextPutAll: (self paddedRightOf: packageName to: nameWidth).
			stream nextPutAll:
				(self paddedLeftOf: dist total printString to: colWidth).
			RTATypeDistribution categories do: [ :category |
					stream nextPutAll:
						(self
							 paddedLeftOf: (dist countFor: category) printString
							 to: colWidth) ].
			stream nextPut: Character lf ].

	stream nextPutAll: (self paddedRightOf: 'TOTAL' to: nameWidth).
	stream nextPutAll:
		(self paddedLeftOf: self total printString to: colWidth).
	RTATypeDistribution categories do: [ :category |
			| categoryTotal |
			categoryTotal := (distributionsByPackage values collect: [ :d |
				                  d countFor: category ]) sum.
			stream nextPutAll:
				(self paddedLeftOf: categoryTotal printString to: colWidth) ].
	stream nextPut: Character lf.
	^ stream contents
]

{ #category : 'private' }
RTAPackageDistribution >> setResults: aCollectionOfARTIMethodResult [

	| grouped |
	distributionsByPackage := Dictionary new.
	grouped := aCollectionOfARTIMethodResult groupedBy: [ :each |
		           each packageName ].
	grouped keysAndValuesDo: [ :packageName :resultsInPackage |
			distributionsByPackage
				at: packageName
				put: (RTATypeDistribution onResults: resultsInPackage) ]
]

{ #category : 'accessing' }
RTAPackageDistribution >> total [

	^ (distributionsByPackage values collect: [ :d | d total ]) sum
]
