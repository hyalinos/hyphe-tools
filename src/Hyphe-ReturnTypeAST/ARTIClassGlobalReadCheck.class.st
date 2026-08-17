"
Check 2 (Class-global read). Matches ExplicitReturn(Expr) where Expr is a bare read
of a global class-name binding (e.g. ^ Integer) and returns Metaclass(className). The accepted risk of
runtime rebinding via Smalltalk at:put: is documented but not checked.
"
Class {
	#name : 'ARTIClassGlobalReadCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTIClassGlobalReadCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'classifying' }
ARTIClassGlobalReadCheck class >> matchExpr: exprNode context: aContext [
	"Matches a bare read of a global class-name binding, e.g. ^ Integer. The accepted risk of
	runtime rebinding via Smalltalk at:put: is documented but not checked."

	(exprNode isKindOf: OCVariableNode) ifFalse: [ ^ nil ].
	(exprNode variable isKindOf: GlobalVariable) ifFalse: [ ^ nil ].
	exprNode variable isGlobalClassNameBinding ifFalse: [ ^ nil ].
	^ ARTIMetaclass named: exprNode variable name
]
