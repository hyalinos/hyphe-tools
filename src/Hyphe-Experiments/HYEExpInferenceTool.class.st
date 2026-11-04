"
A tool that infers the return type of a method: it answers, for a method reference, a HYEToolPrediction (maybe nothing). The experiments use five tools (AST based inferencer, name based heuristics, J2Inferer, RoelTyper, offline test profiler); here a tool is anything that answers predictionFor:. HYERecordedTool replays results saved in CSV files, HYEBlockTool wraps a block, HYEARTITool runs the AST based inferencer of Hyphe-ReturnTypeAST. astBased marks the tool that biased strategies favour.
"
Class {
	#name : 'HYEExpInferenceTool',
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
HYEExpInferenceTool >> beAstBased [
	"Mark the tool as the AST based inferencer"

	astBased := true
]

{ #category : 'testing' }
HYEExpInferenceTool >> isAstBased [
	"Answer true for the AST based inferencer, the tool that biased strategies favour"

	^ astBased ifNil: [ false ]
]

{ #category : 'accessing' }
HYEExpInferenceTool >> name [
	"Answer the name of the tool, used as column name in the results"

	^ name
]

{ #category : 'accessing' }
HYEExpInferenceTool >> name: aString [
	"Set the name of the tool"

	name := aString
]

{ #category : 'private' }
HYEExpInferenceTool >> nothing [
	"Answer the prediction of a tool that gives no answer"

	^ HYEToolPrediction nothingFrom: name
]

{ #category : 'inferring' }
HYEExpInferenceTool >> predictionFor: aMethodRef [
	"Answer the HYEToolPrediction of the tool for a method"

	^ self subclassResponsibility
]
