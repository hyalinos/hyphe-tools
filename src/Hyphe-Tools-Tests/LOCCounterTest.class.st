Class {
	#name : 'LOCCounterTest',
	#superclass : 'TestCase',
	#instVars : [
		'counter'
	],
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'running' }
LOCCounterTest >> setUp [
	super setUp.
	counter := LOCCounter new
]

{ #category : 'running' }
LOCCounterTest >> testMethodBasic [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodBasic.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodEmpty [	
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodEmpty.
	
	self assert: loc equals: 0
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithBlankLines [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithBlankLines.
	
	self assert: loc equals: 4
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithBlock [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithBlock.
	
	self assert: loc equals: 4
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithCascade [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithCascade.
	
	self assert: loc equals: 7
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithEscapedQuotes [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithEscapedQuotes.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithInlineComment [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithInlineComment.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithMultiLineComment [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithMultiLineComment.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithMultilineSignature [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithMultilineSignature:with:and:.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithMultipleQuotesInString [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithMultipleQuotesInString.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithMultipleStatementsPerLine [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithMultipleStatementsPerLine.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithNestedBlocks [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithNestedBlocks.
	
	self assert: loc equals: 4
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithOnlyCommentsAndBlanks [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithOnlyComments:andBlanks:.
	
	self assert: loc equals: 0
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithPragma [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithPragma.
	
	self assert: loc equals: 0
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithQuoteInString [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithQuoteInString.
	
	self assert: loc equals: 3
]

{ #category : 'running' }
LOCCounterTest >> testMethodWithSingleLineComment [
	| loc |
	loc := counter linesOfCode: LOCCounterTestData >> #methodWithSingleLineComment.
	
	self assert: loc equals: 3
]
