"
I count the number of explicit return in a method
"
Class {
	#name : 'ReturnCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'returnNumber'
	],
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'as yet unclassified' }
ReturnCounter class >> exampleReturnCounter [
  <script>
   | method count| 
	"Compiled method to analyze, as an argument"
	method := ReturnCountersTestData >> #multipleReturns.
   "Return the number of explicit returns (^) in a method"
	count := self new returnInMethod: method.
	count inspect.
]

{ #category : 'as yet unclassified' }
ReturnCounter >> initialize [
	super initialize.
	returnNumber := 0.
]

{ #category : 'visiting' }
ReturnCounter >> returnInMethod: aMethod [
	aMethod ast acceptVisitor: self.
	^ returnNumber
]

{ #category : 'visiting' }
ReturnCounter >> visitReturnNode: aReturnNode [
	returnNumber := returnNumber + 1.
	super visitReturnNode: aReturnNode 
]
