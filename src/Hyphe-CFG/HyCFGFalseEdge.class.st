"
Edge taken when the condition of a control flow node does not hold (or, for a loop, when the loop is left).
"
Class {
	#name : 'HyCFGFalseEdge',
	#superclass : 'HyCFGConditionalEdge',
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'initialization' }
HyCFGFalseEdge >> initialize [
	"The false edge is never the true branch"

	super initialize.
	isTrueBranch := false
]
