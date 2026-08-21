"
Check 4 (Self class / super class). Matches ExplicitReturn(Expr) where Expr is a
zero-argument #class message sent to bare self/super (e.g. ^ self class) and returns Self class.
"
Class {
	#name : 'ARTISelfClassCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTISelfClassCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'classifying' }
ARTISelfClassCheck class >> matchExpr: exprNode context: aContext [
	"Matches a zero-argument #class message sent to bare self/super, e.g. ^ self class."

	(exprNode isKindOf: OCMessageNode) ifFalse: [ ^ nil ].
	exprNode selector = #class ifFalse: [ ^ nil ].
	exprNode arguments isEmpty ifFalse: [ ^ nil ].
	exprNode receiver isSelfOrSuperVariable ifFalse: [ ^ nil ].
	^ HTMSelfClass new
]
