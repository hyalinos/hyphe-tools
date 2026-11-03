"
Tests of the inference tools: recorded results, block tools, the AST based inferencer, and HyToolPrediction.
"
Class {
	#name : 'HyToolsTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Tools',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Tools'
}

{ #category : 'tests' }
HyToolsTest >> testARTIToolOnAClassResult [
	"ARTI infers Boolean for a method that returns false"

	self
		assert: (HyARTITool new predictionFor: (self refOf: #isTerminal in: HyCFGNode)) types
		equals: (HyTypeExpression parse: 'Boolean')
]

{ #category : 'tests' }
HyToolsTest >> testARTIToolOnSelf [
	"A method that returns self gives r"

	self assert: (HyARTITool new predictionFor: (self refOf: #yourself in: Object)) types equals: (HyTypeExpression parse: 'r')
]

{ #category : 'tests' }
HyToolsTest >> testARTIToolWithoutAnswer [
	"Unknown types, and methods that are not in the image, give no answer"

	self assert: (HyARTITool new predictionFor: (self refOf: #findRootsOf: in: HyCFGNode)) isNothing.
	self assert: (HyARTITool new predictionFor: (HyMethodRef package: 'P' class: 'NoSuchClassAnywhere' selector: #foo)) isNothing
]

{ #category : 'tests' }
HyToolsTest >> testARTITypeConversion [
	"Classes, metaclasses, unions and arguments of the type model"

	| tool |
	tool := HyARTITool new.

	self assert: (tool expressionFor: (HTMClassRef new setClassName: 'Integer')) equals: (HyTypeExpression parse: 'Integer').
	self assert: (tool expressionFor: (HTMMetaclass new setClassName: 'Foo class')) equals: (HyTypeExpression parse: 'Foo class').
	self assert: (tool expressionFor: HTMSelf new) equals: (HyTypeExpression parse: 'r').
	self assert: (tool expressionFor: (HTMTypeVar new setArgumentIndex: 2)) equals: (HyTypeExpression parse: 'a2').
	self assert: (tool expressionFor: HTMUnknown new) isNil.
	self assert: (tool expressionFor: HTMBottom new) isNil
]

{ #category : 'tests' }
HyToolsTest >> testAstBasedMarker [
	"Only the tool marked as AST based is"

	self deny: (HyBlockTool name: 'a' block: [ :r | nil ]) isAstBased.
	self assert: (HyBlockTool name: 'a' block: [ :r | nil ]) beAstBased isAstBased.
	self assert: HyARTITool new isAstBased
]

{ #category : 'tests' }
HyToolsTest >> testBlockTool [
	"The block can answer a string, a type, a prediction or nil"

	| ref |
	ref := self metricsRef: #mixedSends.

	self
		assert: ((HyBlockTool name: 'a' block: [ :r | 'Integer | String' ]) predictionFor: ref) types
		equals: (HyTypeExpression parse: 'Integer | String').
	self
		assert: ((HyBlockTool name: 'b' block: [ :r | HyTypeExpression parse: 'r' ]) predictionFor: ref) types
		equals: (HyTypeExpression parse: 'r').
	self
		assert:
			((HyBlockTool name: 'c' block: [ :r | HyToolPrediction tool: 'c' types: (HyTypeExpression parse: 'Foo') confidence: 0.5 ])
				 predictionFor: ref) confidence
		equals: 0.5.
	self assert: ((HyBlockTool name: 'd' block: [ :r | nil ]) predictionFor: ref) isNothing.
	self
		assert: ((HyBlockTool name: 'e' block: [ :r | r selector ]) predictionFor: ref) types
		equals: (HyTypeExpression parse: 'mixedSends')
]

{ #category : 'tests' }
HyToolsTest >> testPredictionBasics [
	"No answer, keys, confidence, resolving r"

	| prediction ref |
	ref := HyMethodRef package: 'P' class: 'Foo' selector: #bar.
	prediction := HyToolPrediction tool: 'T' types: (HyTypeExpression parse: 'r | Integer') confidence: nil.

	self assert: (HyToolPrediction nothingFrom: 'T') isNothing.
	self assert: (HyToolPrediction nothingFrom: 'T') keys isEmpty.
	self assert: prediction effectiveConfidence equals: 1.
	self assert: (prediction resolvedFor: ref) keys equals: #( 'Foo' 'Integer' ).
	self assert: (prediction resolvedFor: ref) toolName equals: 'T'.
	self assert: ((HyToolPrediction nothingFrom: 'T') resolvedFor: ref) isNothing.
	self assert: (prediction printString includesSubstring: 'r | Integer')
]

{ #category : 'tests' }
HyToolsTest >> testRecordedToolAnswersWhatWasRecorded [
	"The recorded type, a set of types, and no answer for nil"

	| tool |
	tool := HyRecordedTool fromCsv: self toolFile name: 'Recorded'.

	self assert: tool size equals: 4.
	self assert: (tool predictionFor: (self refOf: #isTerminal in: HyCFGNode)) types equals: (HyTypeExpression parse: 'Boolean').
	self assert: (tool predictionFor: (self refOf: #nestingDepth in: HyCFGNode)) isNothing.
	self
		assert: (tool predictionFor: (self refOf: #edges in: HyCFG)) types
		equals: (HyTypeExpression parse: 'Array | OrderedCollection').
	self assert: (tool predictionFor: (self refOf: #isTerminal in: HyCFGNode)) toolName equals: 'Recorded'
]

{ #category : 'tests' }
HyToolsTest >> testRecordedToolIsSilentAboutOtherMethods [
	"A method that is not in the files has no answer"

	| tool |
	tool := HyRecordedTool fromCsv: self toolFile name: 'Recorded'.

	self assert: (tool predictionFor: (self metricsRef: #mixedSends)) isNothing
]

{ #category : 'tests' }
HyToolsTest >> testRecordedToolWithConfidence [
	"A confidence column is kept"

	| tool |
	tool := HyRecordedTool
		        fromCsv:
		        (self write: { 'selector,class,package,type,confidence'. 'foo,Foo,P,Integer,0.75' } to: (self memoryFile: 'c.csv'))
		        name: 'T'.

	self assert: (tool predictionFor: (HyMethodRef package: 'P' class: 'Foo' selector: #foo)) confidence equals: 0.75
]

{ #category : 'tests' }
HyToolsTest >> testSeveralFilesAndMissingFiles [
	"The answers of one file per group are put together; a file that does not exist (the tool was not run on that group) is skipped"

	| tool |
	tool := HyRecordedTool
		        fromCsvFiles: {
				        self toolFile.
				        (self memoryFile: 'missing.csv') }
		        name: 'T'.

	self assert: tool size equals: 4
]

{ #category : 'helpers' }
HyToolsTest >> toolFile [
	"A tool result file, in the format of the files of the experiment (quotes around names, #Type, nil)"

	^ self
		  write: { 'selector,class,package,type'. '''isTerminal'',''HyCFGNode'',''Hyphe-CFG'',#Boolean'.
			  '''nestingDepth'',''HyCFGNode'',''Hyphe-CFG'',nil'. '''edges'',''HyCFG'',''Hyphe-CFG'',#OrderedCollection | Array'.
			  '''isComplete'',''HyCFG'',''Hyphe-CFG'',#Boolean' }
		  to: (self memoryFile: 'tool.csv')
]
