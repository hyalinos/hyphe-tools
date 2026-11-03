"
An edge leaving a branching node (conditional, loop header, ...). It is either the branch taken when the condition holds (isTrueBranch = true, HyCFGTrueEdge) or the one taken otherwise (HyCFGFalseEdge).
"
Class {
	#name : 'HyCFGConditionalEdge',
	#superclass : 'HyCFGEdge',
	#instVars : [
		'isTrueBranch'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'copying' }
HyCFGConditionalEdge >> copyFrom: sourceNode to: targetNode [
	"Answer a new edge between two other nodes that is the same branch as the receiver"

	^ (super copyFrom: sourceNode to: targetNode)
		  isTrueBranch: isTrueBranch;
		  yourself
]

{ #category : 'copying' }
HyCFGConditionalEdge >> detachedCopyFrom: sourceNode to: targetNode [
	"Answer a new unregistered edge that is the same branch as the receiver"

	^ (super detachedCopyFrom: sourceNode to: targetNode)
		  isTrueBranch: isTrueBranch;
		  yourself
]

{ #category : 'initialization' }
HyCFGConditionalEdge >> initialize [
	"A plain conditional edge is the true branch by default"

	super initialize.
	isTrueBranch := true
]

{ #category : 'accessing' }
HyCFGConditionalEdge >> isTrueBranch [
	"Answer true if this edge is taken when the condition holds"

	^ isTrueBranch
]

{ #category : 'accessing' }
HyCFGConditionalEdge >> isTrueBranch: aBoolean [
	"Set whether this edge is the branch taken when the condition holds"

	isTrueBranch := aBoolean
]
