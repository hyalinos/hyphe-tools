"
Check 3 (Self / super). Matches ExplicitReturn(Expr) where Expr is the bare self or super
pseudo-variable (e.g. ^ self) and returns Self.
"
Class {
	#name : 'ARTISelfCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTISelfCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'classifying' }
ARTISelfCheck class >> matchExpr: exprNode context: aContext [
	"Matches the bare self or super pseudo-variable, e.g. ^ self."

	exprNode isSelfOrSuperVariable ifFalse: [ ^ nil ].
	^ ARTISelfType new
]
