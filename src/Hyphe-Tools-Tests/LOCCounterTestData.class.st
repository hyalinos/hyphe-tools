Class {
	#name : 'LOCCounterTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodBasic [
	| temp |
	temp := 1 + 2.
	^ temp
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodEmpty [
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithBlankLines [
	| a b |
	
	a := 1.
	
	b := 2.
	
	^ a + b
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithBlock [
	| collection result |
	collection := #(1 2 3 4 5).
	result := collection select: [ :each | each > 2 ].
	^ result
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithCascade [
	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Hello';
		space;
		nextPutAll: 'World'.
	^ stream contents
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithEscapedQuotes [
	| str |
	str := 'It''s a string with escaped quote'.
	^ str
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithInlineComment [
	| value |
	value := 5. "This is an inline comment"
	^ value + 1
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithMultiLineComment [
	"This is a
	multi-line on
	several lines"
	| x |
	x := 10.
	^ x * 2
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithMultilineSignature: firstArg
	with: secondArg
	and: thirdArg [
	| result |
	result := firstArg + secondArg + thirdArg.
	^ result
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithMultipleQuotesInString [
	| str |
	str := 'There is a " quote "here" too'.
	^ str
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithMultipleStatementsPerLine [
	| a b |
	a := 1. b := 2.
	^ a + b
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithNestedBlocks [
	"This tests nested blocks"
	| data |
	data := #(1 2 3).
	^ data collect: [ :x |
		x * 2 ] "Comment after block"
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithOnlyComments: aComment 
	andBlanks: aBlank [
	
	"Comment one"
	
	"Comment two"
	
	"Comment three"
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithPragma [
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithQuoteInString [
	| str |
	str := 'This string contains a " symbol'.
	^ str size
]

{ #category : 'as yet unclassified' }
LOCCounterTestData >> methodWithSingleLineComment [
	"This is a comment"
	| result |
	result := 42.
	^ result
]
