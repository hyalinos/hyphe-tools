"
Tests of HYECsv: reading records with the names of the columns normalized, cleaning of the quotes of the tool files, writing with quoting.
"
Class {
	#name : 'HYECsvTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Data',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Data'
}

{ #category : 'tests' }
HYECsvTest >> testBlankLinesAreSkipped [
	"Lines without any value (a spreadsheet exports them) are not records"

	| records |
	records := HYECsv recordsFrom: (self write: { 'a,b'. '1,2'. ',,'. ''. '3,4' } to: (self memoryFile: 'a.csv')).

	self assert: records size equals: 2
]

{ #category : 'tests' }
HYECsvTest >> testEmptyFile [
	"A file without header gives no record"

	self assert: (HYECsv recordsFrom: (self write: #(  ) to: (self memoryFile: 'a.csv'))) isEmpty
]

{ #category : 'tests' }
HYECsvTest >> testRecordsHaveNormalizedColumnNames [
	"The names of the columns are trimmed and lower cased, the values trimmed"

	| records |
	records := HYECsv recordsFrom:
		           (self write: { ' Package , Class,Selector '. ' Kernel , Object ,yourself ' } to: (self memoryFile: 'a.csv')).

	self assert: records size equals: 1.
	self assert: (records first at: 'package') equals: 'Kernel'.
	self assert: (records first at: 'class') equals: 'Object'.
	self assert: (records first at: 'selector') equals: 'yourself'
]

{ #category : 'tests' }
HYECsvTest >> testSingleQuotesOfTheToolFilesAreRemoved [
	"The tool results write 'selector','Class' with single quotes"

	| records |
	records := HYECsv recordsFrom: (self
			            write: { 'selector,class,package,type'. '''openFindDialog'',''TextMorph'',''Morphic-Base'',#TextMorph' }
			            to: (self memoryFile: 'a.csv')).

	self assert: (records first at: 'selector') equals: 'openFindDialog'.
	self assert: (records first at: 'package') equals: 'Morphic-Base'.
	self assert: (records first at: 'type') equals: '#TextMorph'
]

{ #category : 'tests' }
HYECsvTest >> testValueAtAliases [
	"The first column that exists and is not empty gives the value, nil if none"

	| record |
	record := Dictionary new
		          at: 'methodname' put: 'foo';
		          at: 'selector' put: '';
		          yourself.

	self assert: (HYECsv record: record valueAt: #( 'selector' 'methodname' )) equals: 'foo'.
	self assert: (HYECsv record: record valueAt: #( 'other' )) isNil
]

{ #category : 'tests' }
HYECsvTest >> testWriteAndReadBack [
	"Values with a comma, a quote or a line break survive; nil is an empty value; numbers are written as numbers"

	| file records |
	file := self memoryFile: 'out' , '/b.csv'.
	HYECsv
		write: {
				#( 'a' 'b' 'c' ).
				{ 'x, y'. 'say "hi"'. 3 }.
				{ nil. 'line
break'. 1.5 } }
		to: file.
	records := HYECsv recordsFrom: file.

	self assert: records size equals: 2.
	self assert: (records first at: 'a') equals: 'x, y'.
	self assert: (records first at: 'b') equals: 'say "hi"'.
	self assert: (records first at: 'c') equals: '3'.
	self assert: (records last at: 'a') equals: ''.
	self assert: (records last at: 'b') equals: 'line
break'
]

{ #category : 'tests' }
HYECsvTest >> testWriteReplacesTheFile [
	"An existing file is replaced"

	| file |
	file := self memoryFile: 'c.csv'.
	HYECsv
		write: {
				#( 'a' ).
				#( 'old' ) }
		to: file.
	HYECsv
		write: {
				#( 'a' ).
				#( 'new' ) }
		to: file.

	self assert: (HYECsv recordsFrom: file) size equals: 1.
	self assert: ((HYECsv recordsFrom: file) first at: 'a') equals: 'new'
]
