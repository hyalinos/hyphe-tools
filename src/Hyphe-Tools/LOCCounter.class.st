Class {
	#name : 'LOCCounter',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-StaticAnalysis',
	#package : 'Hyphe-Tools',
	#tag : 'StaticAnalysis'
}

{ #category : 'accessing' }
LOCCounter class >> image [
	
	| result counter |
	result := Dictionary new.
	counter := self new.
	
	Smalltalk globals methods do: [ :method |
		result at: method put: (counter linesOfCode: method)		
	].
	
	^ result
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
	^ ast body formattedCode
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
