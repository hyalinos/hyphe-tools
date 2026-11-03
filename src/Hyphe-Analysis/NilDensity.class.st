"
I calculate the number of nil checks per LOC in a given method. A nil check is isNil, notNil, isNotNil, ifNil:, ifNotNil:, ifNil:ifNotNil:, ifNotNil:ifNil: or a comparison (==, =, ~~, ~=) with nil, with nil on either side. I do not consider ^ nil, := nil (they are not checks).

To run this code:
	use a method := aClass >> aMethod as argument of the method who calculate the Nil-check density: nilCountIn: method.
"
Class {
	#name : 'NilDensity',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'nilCount'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'examples' }
NilDensity class >> exampleNilDensity [
	<script>
	| method count |
	"Compiled method to analyze, as an argument"
	method := NilDensityTestData >> #methodWithMultipleNilChecks.
	"Return the number of nil checks (isNil, notNil, ifNil:, ifNotNil:, == nil ...) per LOC."
	count := self new nilCountIn: method.
	count inspect.
]

{ #category : 'initialization' }
NilDensity >> initialize [ 
   super initialize.
	nilCount := 0.
	
]

{ #category : 'private' }
NilDensity >> isNilCheckMessage: aMessageNode [
	"Answer whether the message is a nil check: a test sent to a value (isNil, notNil, ifNil: ...) or a comparison of a value with the literal nil"
	| selector |
	selector := aMessageNode selector.
	(#(#isNil #notNil #isNotNil #ifNil: #ifNotNil: #ifNil:ifNotNil: #ifNotNil:ifNil:) includes: selector) ifTrue: [ ^ true ].
	(#(#== #= #~~ #~=) includes: selector) ifFalse: [ ^ false ].
	^ (self isNilLiteral: aMessageNode receiver) or: [ self isNilLiteral: aMessageNode arguments first ]
]

{ #category : 'private' }
NilDensity >> isNilLiteral: aNode [
	^ aNode isLiteralNode and: [ aNode value isNil ]
]

{ #category : 'as yet unclassified' }
NilDensity >> nilCountIn: aMethod [
	|locCounter loc|
	locCounter := LOCCounter new.
	loc := locCounter linesOfCode: aMethod.
	aMethod ast acceptVisitor: self.
	
   ^ nilCount / loc
]

{ #category : 'visiting' }
NilDensity >> visitMessageNode: aMessageNode [
	"Count the nil checks: isNil, notNil, isNotNil, ifNil:, ifNotNil:, ifNil:ifNotNil:, ifNotNil:ifNil: and the comparisons ==, =, ~~, ~= with nil. ^ nil and x := nil are not checks."
	(self isNilCheckMessage: aMessageNode) ifTrue: [ nilCount := nilCount + 1 ].
	super visitMessageNode: aMessageNode
]
