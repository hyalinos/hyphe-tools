"
A tool that infers the return type of a method: it answers, for a method reference, a HyToolPrediction (maybe nothing). The experiments use five tools (AST based inferencer, name based heuristics, J2Inferer, RoelTyper, offline test profiler); here a tool is anything that answers predictionFor:. HyRecordedTool replays results saved in CSV files, HyBlockTool wraps a block, HyARTITool runs the AST based inferencer of Hyphe-ReturnTypeAST. astBased marks the tool that biased strategies favour.
"
Class {
	#name : 'HyExpInferenceTool',
	#superclass : 'Object',
	#instVars : [
		'name',
		'astBased'
	],
	#category : 'Hyphe-Experiments-Tools',
	#package : 'Hyphe-Experiments',
	#tag : 'Tools'
}

{ #category : 'configuring' }
HyExpInferenceTool >> beAstBased [
	"Mark the tool as the AST based inferencer"

	astBased := true
]

{ #category : 'testing' }
HyExpInferenceTool >> isAstBased [
	"Answer true for the AST based inferencer, the tool that biased strategies favour"

	^ astBased ifNil: [ false ]
]

{ #category : 'accessing' }
HyExpInferenceTool >> name [
	"Answer the name of the tool, used as column name in the results"

	^ name
]

{ #category : 'accessing' }
HyExpInferenceTool >> name: aString [
	"Set the name of the tool"

	name := aString
]

{ #category : 'private' }
HyExpInferenceTool >> nothing [
	"Answer the prediction of a tool that gives no answer"

	^ HyToolPrediction nothingFrom: name
]

{ #category : 'inferring' }
HyExpInferenceTool >> predictionFor: aMethodRef [
	"Answer the HyToolPrediction of the tool for a method"

	^ self subclassResponsibility
]
