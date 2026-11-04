"
Tests of the inference tools: recorded results, block tools, the AST based inferencer, and HYEToolPrediction.
"
Class {
	#name : 'HYEToolsTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Tools',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Tools'
}

{ #category : 'tests' }
HYEToolsTest >> testARTIToolOnAClassResult [
	"ARTI infers Boolean for a method that returns false"

	self
		assert: (HYEARTITool new predictionFor: (self refOf: #isTerminal in: HyCFGNode)) types
		equals: (HYETypeExpression parse: 'Boolean')
]

{ #category : 'tests' }
HYEToolsTest >> testARTIToolOnSelf [
	"A method that returns self gives r"

	self assert: (HYEARTITool new predictionFor: (self refOf: #yourself in: Object)) types equals: (HYETypeExpression parse: 'r')
]

{ #category : 'tests' }
HYEToolsTest >> testARTIToolWithoutAnswer [
	"Unknown types, and methods that are not in the image, give no answer"

	self assert: (HYEARTITool new predictionFor: (self refOf: #findRootsOf: in: HyCFGNode)) isNothing.
	self assert: (HYEARTITool new predictionFor: (HYEMethodRef package: 'P' class: 'NoSuchClassAnywhere' selector: #foo)) isNothing
]

{ #category : 'tests' }
HYEToolsTest >> testARTITypeConversion [
	"Classes, metaclasses, unions and arguments of the type model"

	| tool |
	tool := HYEARTITool new.

	self assert: (tool expressionFor: (HTMClassRef new setClassName: 'Integer')) equals: (HYETypeExpression parse: 'Integer').
	self assert: (tool expressionFor: (HTMMetaclass new setClassName: 'Foo class')) equals: (HYETypeExpression parse: 'Foo class').
	self assert: (tool expressionFor: HTMSelf new) equals: (HYETypeExpression parse: 'r').
	self assert: (tool expressionFor: (HTMTypeVar new setArgumentIndex: 2)) equals: (HYETypeExpression parse: 'a2').
	self assert: (tool expressionFor: HTMUnknown new) isNil.
	self assert: (tool expressionFor: HTMBottom new) isNil
]

{ #category : 'tests' }
HYEToolsTest >> testAstBasedMarker [
	"Only the tool marked as AST based is"

	self deny: (HYEBlockTool name: 'a' block: [ :r | nil ]) isAstBased.
	self assert: (HYEBlockTool name: 'a' block: [ :r | nil ]) beAstBased isAstBased.
	self assert: HYEARTITool new isAstBased
]

{ #category : 'tests' }
HYEToolsTest >> testBlockTool [
	"The block can answer a string, a type, a prediction or nil"

	| ref |
	ref := self metricsRef: #mixedSends.

	self
		assert: ((HYEBlockTool name: 'a' block: [ :r | 'Integer | String' ]) predictionFor: ref) types
		equals: (HYETypeExpression parse: 'Integer | String').
	self
		assert: ((HYEBlockTool name: 'b' block: [ :r | HYETypeExpression parse: 'r' ]) predictionFor: ref) types
		equals: (HYETypeExpression parse: 'r').
	self
		assert:
			((HYEBlockTool name: 'c' block: [ :r | HYEToolPrediction tool: 'c' types: (HYETypeExpression parse: 'Foo') confidence: 0.5 ])
				 predictionFor: ref) confidence
		equals: 0.5.
	self assert: ((HYEBlockTool name: 'd' block: [ :r | nil ]) predictionFor: ref) isNothing.
	self
		assert: ((HYEBlockTool name: 'e' block: [ :r | r selector ]) predictionFor: ref) types
		equals: (HYETypeExpression parse: 'mixedSends')
]

{ #category : 'tests' }
HYEToolsTest >> testPredictionBasics [
	"No answer, keys, confidence, resolving r"

	| prediction ref |
	ref := HYEMethodRef package: 'P' class: 'Foo' selector: #bar.
	prediction := HYEToolPrediction tool: 'T' types: (HYETypeExpression parse: 'r | Integer') confidence: nil.

	self assert: (HYEToolPrediction nothingFrom: 'T') isNothing.
	self assert: (HYEToolPrediction nothingFrom: 'T') keys isEmpty.
	self assert: prediction effectiveConfidence equals: 1.
	self assert: (prediction resolvedFor: ref) keys equals: #( 'Foo' 'Integer' ).
	self assert: (prediction resolvedFor: ref) toolName equals: 'T'.
	self assert: ((HYEToolPrediction nothingFrom: 'T') resolvedFor: ref) isNothing.
	self assert: (prediction printString includesSubstring: 'r | Integer')
]

{ #category : 'tests' }
HYEToolsTest >> testRecordedToolAnswersWhatWasRecorded [
	"The recorded type, a set of types, and no answer for nil"

	| tool |
	tool := HYERecordedTool fromCsv: self toolFile name: 'Recorded'.

	self assert: tool size equals: 4.
	self assert: (tool predictionFor: (self refOf: #isTerminal in: HyCFGNode)) types equals: (HYETypeExpression parse: 'Boolean').
	self assert: (tool predictionFor: (self refOf: #nestingDepth in: HyCFGNode)) isNothing.
	self
		assert: (tool predictionFor: (self refOf: #edges in: HyCFG)) types
		equals: (HYETypeExpression parse: 'Array | OrderedCollection').
	self assert: (tool predictionFor: (self refOf: #isTerminal in: HyCFGNode)) toolName equals: 'Recorded'
]

{ #category : 'tests' }
HYEToolsTest >> testRecordedToolIsSilentAboutOtherMethods [
	"A method that is not in the files has no answer"

	| tool |
	tool := HYERecordedTool fromCsv: self toolFile name: 'Recorded'.

	self assert: (tool predictionFor: (self metricsRef: #mixedSends)) isNothing
]

{ #category : 'tests' }
HYEToolsTest >> testRecordedToolWithConfidence [
	"A confidence column is kept"

	| tool |
	tool := HYERecordedTool
		        fromCsv:
		        (self write: { 'selector,class,package,type,confidence'. 'foo,Foo,P,Integer,0.75' } to: (self memoryFile: 'c.csv'))
		        name: 'T'.

	self assert: (tool predictionFor: (HYEMethodRef package: 'P' class: 'Foo' selector: #foo)) confidence equals: 0.75
]

{ #category : 'tests' }
HYEToolsTest >> testSeveralFilesAndMissingFiles [
	"The answers of one file per group are put together; a file that does not exist (the tool was not run on that group) is skipped"

	| tool |
	tool := HYERecordedTool
		        fromCsvFiles: {
				        self toolFile.
				        (self memoryFile: 'missing.csv') }
		        name: 'T'.

	self assert: tool size equals: 4
]

{ #category : 'helpers' }
HYEToolsTest >> toolFile [
	"A tool result file, in the format of the files of the experiment (quotes around names, #Type, nil)"

	^ self
		  write: { 'selector,class,package,type'. '''isTerminal'',''HyCFGNode'',''Hyphe-CFG'',#Boolean'.
			  '''nestingDepth'',''HyCFGNode'',''Hyphe-CFG'',nil'. '''edges'',''HyCFG'',''Hyphe-CFG'',#OrderedCollection | Array'.
			  '''isComplete'',''HyCFG'',''Hyphe-CFG'',#Boolean' }
		  to: (self memoryFile: 'tool.csv')
]
