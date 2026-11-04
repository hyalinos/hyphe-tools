"
Small helpers to read and write the CSV files of the experiments. Files are read with NeoCSV. A record is a dictionary with the lower case, trimmed names of the columns as keys, and the trimmed values (without the single quotes that the tool results put around selectors) as values; the same column is often named differently in the different files, so recordValue:at: takes several names. Files are written in UTF-8, a file with the same name is replaced.
"
Class {
	#name : 'HYECsv',
	#superclass : 'Object',
	#category : 'Hyphe-Experiments-Data',
	#package : 'Hyphe-Experiments',
	#tag : 'Data'
}

{ #category : 'reading' }
HYECsv class >> clean: aField [
	"Answer a field without the spaces around it nor the single quotes around the value, '' for nil"

	| text |
	text := aField ifNil: [ '' ] ifNotNil: [ :field | field trim ].
	(text size >= 2 and: [ text first = $' and: [ text last = $' ] ]) ifTrue: [ text := text copyFrom: 2 to: text size - 1 ].
	^ text
]

{ #category : 'writing' }
HYECsv class >> fieldFor: aValue [
	"Answer the text of a value for a CSV line: strings as they are, other values with displayString (nil is empty), between quotes when they contain a comma, a quote or a line break"

	| text |
	text := aValue ifNil: [ '' ] ifNotNil: [ :value |
			        value isString
				        ifTrue: [ value ]
				        ifFalse: [ value displayString ] ].
	^ (text anySatisfy: [ :char | char = $, or: [ char = $" or: [ char = Character lf or: [ char = Character cr ] ] ] ])
		  ifTrue: [ '"' , (text copyReplaceAll: '"' with: '""') , '"' ]
		  ifFalse: [ text ]
]

{ #category : 'reading' }
HYECsv class >> record: aRecord valueAt: someColumnNames [
	"Answer the value of the first of the columns that exists and is not empty, nil if none"

	someColumnNames do: [ :name | (aRecord at: name ifAbsent: [ '' ]) ifNotEmpty: [ :value | ^ value ] ].
	^ nil
]

{ #category : 'reading' }
HYECsv class >> recordsFrom: aFileOrString [
	"Answer the records (dictionaries column name -> value) of a CSV file with a header line. Blank lines are skipped."

	| rows header |
	rows := aFileOrString asFileReference readStreamDo: [ :stream | (NeoCSVReader on: stream) upToEnd ].
	rows isEmpty ifTrue: [ ^ OrderedCollection new ].
	header := rows first collect: [ :name | name trim asLowercase ].
	^ (rows allButFirst reject: [ :row | row allSatisfy: [ :field | field isNil or: [ field trim isEmpty ] ] ]) collect: [ :row |
			  | record |
			  record := Dictionary new.
			  header withIndexDo: [ :name :index | record at: name put: (self clean: (row at: index ifAbsent: [ '' ])) ].
			  record ]
]

{ #category : 'writing' }
HYECsv class >> write: someRows to: aFileOrString [
	"Write rows (arrays of values) as a CSV file; values that contain a comma, a quote or a line break are quoted. Answer the file."

	| file text |
	file := aFileOrString asFileReference.
	file ensureDelete.
	file parent ensureCreateDirectory.
	text := String streamContents: [ :stream |
			        someRows do: [ :row |
					        row do: [ :value | stream nextPutAll: (self fieldFor: value) ] separatedBy: [ stream nextPut: $, ].
					        stream lf ] ].
	file binaryWriteStreamDo: [ :stream | stream nextPutAll: text utf8Encoded ].
	^ file
]
