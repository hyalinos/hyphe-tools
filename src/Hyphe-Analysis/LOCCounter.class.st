"
I calculate LOC for a given method.

I calculate:  
	- temporary variable declarations
	- assignment statements
   - return statements
   - message sends
   - block definitions

I do not calculate: 
   - method signatures (single ot multilines)
   - comments (single ot multilines)
   - blank lines
	- pragmas
"
Class {
	#name : 'LOCCounter',
	#superclass : 'Object',
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'accessing' }
LOCCounter class >> example [

	<script>
	| collection |
	collection := self imageMethodsLoc. 
	
	"print first 100 random methods with loc = 1" 
	self printResults: (self methods: collection withLoc: 1) ofSize: 100 to: 'methods_random_100_loc_equal_1'.  
	
	"print first 100 random methods with loc > 1 and loc < 15" 
	self printResults: (self methods: collection withLocFrom: 1 to: 15) ofSize: 100 to: 'methods_random_100_loc_above_1_below_15'.
	
	
	"print first 100 random methods with loc > 15"
	self printResults: (self methods: collection withLocFrom: 15) ofSize: 100 to: 'methods_random_100_loc_above_15'.
]

{ #category : 'accessing' }
LOCCounter class >> imageMethodsLoc [

	| result counter |
	result := Dictionary new.
	counter := self new.

	Smalltalk globals methods do: [ :method | result at: method put: (counter linesOfCode: method) ].

	^ result
]

{ #category : 'accessing' }
LOCCounter class >> methods: methodsCollection withLoc: locNumber [

	^ (methodsCollection keys select: [ :method | (methodsCollection at: method) = locNumber ]) asOrderedCollection
]

{ #category : 'accessing' }
LOCCounter class >> methods: methodsCollection withLocBelow: locNumber [

	^ (methodsCollection keys select: [ :method | (methodsCollection at: method) < locNumber ]) asOrderedCollection
]

{ #category : 'accessing' }
LOCCounter class >> methods: methodsCollection withLocFrom: locNumber [

	^ (methodsCollection keys select: [ :method | (methodsCollection at: method) > locNumber ]) asOrderedCollection
]

{ #category : 'accessing' }
LOCCounter class >> methods: methodsCollection withLocFrom: minLocNumber to: maxLocNumber [

	^ (methodsCollection keys select: [ :method |
			   | num |
			   num := methodsCollection at: method.
			   num > minLocNumber and: num < maxLocNumber ]) asOrderedCollection
]

{ #category : 'accessing' }
LOCCounter class >> printResults: sample ofSize: sampleSize to: fileName [

	| stream |

	stream := WriteStream on: String new.
	stream
		nextPutAll: 'package,class,selector';
		cr.

	(sample asOrderedCollection shuffled first: sampleSize) do: [ :method |
			stream
				nextPutAll: method methodClass package name;
				nextPut: $,;
				nextPutAll: method methodClass name;
				nextPut: $,;
				nextPutAll: method selector;
				cr ].

	(fileName , '.csv') asFileReference writeStreamDo: [ :f | f nextPutAll: stream contents ]
]

{ #category : 'accessing' }
LOCCounter class >> trivial [

	|collection sample stream|
	
collection := self image.

sample := (collection keys select: [ :method |
    (collection at: method) = 1
]) asOrderedCollection shuffled first: 100.

stream := WriteStream on: String new.
stream nextPutAll: 'package,class,selector'; cr.

sample do: [ :method |
    stream
        nextPutAll: method methodClass package name; nextPut: $,;
        nextPutAll: method methodClass name; nextPut: $,;
        nextPutAll: method selector; cr.
].

'trivial_sample.csv' asFileReference
    writeStreamDo: [ :f | f nextPutAll: stream contents ].
]

{ #category : 'helpers' }
LOCCounter >> countNonBlankLines: sourceString [
	"Count the number of non-blank lines in the source.
	Returns: Integer"
	
	^ sourceString lines count: [ :line | line trimBoth isNotEmpty ]
]

{ #category : 'helpers' }
LOCCounter >> extractMethodBody: aCompiledMethod [
	"Extract the method body using AST, excluding the signature.
	Returns: String containing only the method body."
	
	| ast |
	ast := aCompiledMethod ast.
	^ ast body sourceCode
]

{ #category : 'helpers' }
LOCCounter >> handleDoubleQuote: inString writingTo: result [
	"Handle a double quote character (comment delimiter or string content).
	Returns: Boolean indicating whether to toggle comment state"
	
	inString
		ifTrue: [
			"Double quote is part of string content - don't toggle comment"
			result nextPut: $".
			^ false ]
		ifFalse: [
			"Double quote starts/ends comment - toggle comment state"
			^ true ]
]

{ #category : 'helpers' }
LOCCounter >> handleSingleQuote: sourceString at: index writingTo: result [
	"Handle a single quote character, including escaped quotes.
	Returns: Association of (newIndex -> shouldToggleString)"
	
	| char nextChar |
	char := sourceString at: index.
	
	"Check for escaped quote ''"
	nextChar := (index < sourceString size)
		ifTrue: [ sourceString at: index + 1 ]
		ifFalse: [ nil ].
	
	(nextChar = $')
		ifTrue: [
			"Escaped quote - write both and skip ahead, don't toggle"
			result nextPut: char; nextPut: char.
			^ (index + 2) -> false ]
		ifFalse: [
			"Regular quote - toggle string state"
			result nextPut: char.
			^ (index + 1) -> true ]
]

{ #category : 'calculating' }
LOCCounter >> linesOfCode: aCompiledMethod [
	
	^ self countNonBlankLines: (self removeComments: (self extractMethodBody: aCompiledMethod))
]

{ #category : 'calculating' }
LOCCounter >> linesOfCode: aClass selector: aSelector [
	
	| compiledMethod |
	compiledMethod := aClass >> aSelector.
	^ self linesOfCode: compiledMethod
]

{ #category : 'helpers' }
LOCCounter >> removeComments: sourceString [
	
	| result inString inComment i char update |
	result := WriteStream on: String new.
	inString := false.
	inComment := false.
	i := 1.
	
	[ i <= sourceString size ] whileTrue: [
		char := sourceString at: i.
		
		"Handle single quotes (string delimiters)"
		char = $'
			ifTrue: [
				update := self handleSingleQuote: sourceString at: i writingTo: result.
				i := update key.
				update value ifTrue: [ inString := inString not ] ]
			ifFalse: [
				"Handle double quotes (comment delimiters)"
				char = $"
					ifTrue: [
						update := self handleDoubleQuote: inString writingTo: result.
						i := i + 1.
						update ifTrue: [ inComment := inComment not ] ]
					ifFalse: [
						"Regular character - write it if not in comment"
						inComment ifFalse: [ result nextPut: char ].
						i := i + 1 ] ]
	].
	
	^ result contents
]
