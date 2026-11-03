"
Edge taken when the condition of a control flow node holds (or, for a loop, when the body is entered).
"
Class {
	#name : 'HyCFGTrueEdge',
	#superclass : 'HyCFGConditionalEdge',
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'initialization' }
HyCFGTrueEdge >> initialize [
	"The true edge is always the true branch"

	super initialize.
	isTrueBranch := true
]
