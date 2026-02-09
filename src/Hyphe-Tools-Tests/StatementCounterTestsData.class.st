"
I count the amount of statement in a fiven message.

I count:
- assignment statements
- message sends
- return statements
- statements within a block clusure
- cascade sequences (each message in a cascade counts as a separate statement)

I don not count
- variable declarations
- method signatures
- comments
- annotations




"
Class {
	#name : 'StatementCounterTestsData',
	#superclass : 'Object',
	#instVars : [
		'x'
	],
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodEmpty [
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithAssignment [

	x := 1

	
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithBinaryMessage [

	1 + 2	
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithBlock [

	1 to: 10 do: [ :i |
			x := x + i.
			x printString ]
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithCascade [ 

	OrderedCollection new
		add: 1;
		add: 2;
		yourself
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithComment [

	"bulochka"

	
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithKeywordMessage [

	',' join: #(1 2 3)
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithPragma [

	<primitive: 123>


	
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithReturn [

	^ x

	
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithUnaryMessage [

	'hello' isString	
]

{ #category : 'as yet unclassified' }
StatementCounterTestsData >> methodWithVariableDeclaration [
	
	| ciao |
	
]
