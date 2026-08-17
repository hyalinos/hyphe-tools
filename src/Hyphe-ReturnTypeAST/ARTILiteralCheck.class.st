"
Check 1 (Literal). Matches ExplicitReturn(Expr) where Expr is a literal value or literal-array
node (e.g. ^ 5, ^ true, ^ 'x', ^ #(1 2 3)) and returns the literal's normalized ClassRef, using the
same class-name normalization idea as TypeMe's typeNameReplacements (see ARTITypeNameNormalizer), but
maintained independently. The dynamic-array syntax { expr. expr } is a different AST node (OCArrayNode)
and deliberately never matches here.
"
Class {
	#name : 'ARTILiteralCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTILiteralCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'classifying' }
ARTILiteralCheck class >> matchExpr: exprNode context: aContext [
	"Matches OCLiteralValueNode (^5, ^true, ^'x', ^nil, ^#sym) and OCLiteralArrayNode (^#(1 2 3)).
	The dynamic-array syntax { expr. expr } compiles to an OCArrayNode, a different node class,
	and deliberately does not match here."

	((exprNode isKindOf: OCLiteralValueNode) or: [
		 exprNode isKindOf: OCLiteralArrayNode ]) ifFalse: [ ^ nil ].
	^ ARTIClassRef named:
		  (ARTITypeNameNormalizer normalize: exprNode value class name)
]
