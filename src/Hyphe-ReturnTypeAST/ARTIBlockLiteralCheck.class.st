"
Check 10 (Block literal). Matches ExplicitReturn(Expr) where Expr is a block literal
(OCBlockNode) whose body contains no ^ return anywhere inside it, including inside any block nested
within it (OCBlockNode>>containsReturn already recurses), and returns ClassRef(#BlockClosure). A block
literal containing an internal non-local return does not match.
"
Class {
	#name : 'ARTIBlockLiteralCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTIBlockLiteralCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'classifying' }
ARTIBlockLiteralCheck class >> matchExpr: exprNode context: aContext [
	"Matches a block literal with no ^ return anywhere inside it, including nested blocks, e.g.
	^ [ :x | x + 1 ]. A block containing an internal non-local return does not match."

	(exprNode isKindOf: OCBlockNode) ifFalse: [ ^ nil ].
	exprNode containsReturn ifTrue: [ ^ nil ].
	^ HTMClassRef named: #BlockClosure
]
