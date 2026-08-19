"
Extension check (added after the original 10; see the comparison-with-OCTypingVisitor findings).
Matches ExplicitReturn(Expr) where Expr is a dynamic array literal, e.g. ^ { a. b. c } (an OCArrayNode --
distinct from OCLiteralArrayNode, which check 1 already handles). The {...} syntax is guaranteed by the
language to construct an Array, unconditionally, regardless of what its elements evaluate to -- the same
correct-by-construction reasoning as check 1, just for a different, disjoint AST node shape.
"
Class {
	#name : 'ARTIDynamicArrayCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTIDynamicArrayCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'classifying' }
ARTIDynamicArrayCheck class >> matchExpr: exprNode context: aContext [
	"Matches a dynamic array literal, e.g. ^ { 1. 2 }. OCArrayNode is a different, disjoint AST node
	from OCLiteralValueNode/OCLiteralArrayNode (check 1's territory) -- the {...} syntax always builds
	an Array, so no runtime-value inspection is needed the way check 1 needs it for normalization."

	(exprNode isKindOf: OCArrayNode) ifFalse: [ ^ nil ].
	^ ARTIClassRef named: #Array
]
