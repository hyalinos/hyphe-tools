"
I count the distinct selectors sent by a method (NDS, Number of Distinct Selectors): a selector sent three times counts once. Every message of a cascade counts. Use: DistinctSelectorsCounter new countIn: aCompiledMethod, or selectorsIn: for the selectors themselves.
"
Class {
	#name : 'DistinctSelectorsCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'selectors'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'analysis' }
DistinctSelectorsCounter >> analyzeMethod: aCompiledMethod [
	"Collect the selectors sent by the method. Answer the receiver."

	selectors := Set new.
	aCompiledMethod ast acceptVisitor: self
]

{ #category : 'analysis' }
DistinctSelectorsCounter >> countIn: aCompiledMethod [
	"Answer the number of distinct selectors the method sends (NDS)"

	self analyzeMethod: aCompiledMethod.
	^ selectors size
]

{ #category : 'initialization' }
DistinctSelectorsCounter >> initialize [
	"Start with no selector"

	super initialize.
	selectors := Set new
]

{ #category : 'analysis' }
DistinctSelectorsCounter >> selectorsIn: aCompiledMethod [
	"Answer the set of the selectors the method sends"

	self analyzeMethod: aCompiledMethod.
	^ selectors copy
]

{ #category : 'visiting' }
DistinctSelectorsCounter >> visitMessageNode: aMessageNode [
	"Remember the selector, then look inside the receiver and the arguments"

	selectors add: aMessageNode selector.
	super visitMessageNode: aMessageNode
]
