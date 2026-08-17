"
Check 5 (Implicit no-return). Matches an ImplicitEndTerminal (produced directly by
ARTIReachabilityEngine, never independently re-detected from raw AST shape) and returns Self.
"
Class {
	#name : 'ARTIImplicitNoReturnCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTIImplicitNoReturnCheck class >> classify: aTerminal context: aContext [
	"Matches an ImplicitEnd terminal (REQ-C1: the reachability engine guarantees a standalone
	Bottom-selector statement is never itself reported as ImplicitEnd, so there is no ordering
	ambiguity with check 6 to resolve here)."

	(aTerminal isKindOf: ARTIImplicitEndTerminal) ifFalse: [ ^ nil ].
	^ ARTISelfType new
]
