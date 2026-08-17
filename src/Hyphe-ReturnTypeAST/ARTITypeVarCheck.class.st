"
Check 8 (TypeVar). Matches ExplicitReturn(Expr) where Expr is a read of one of the method's
own formal parameters, provided that parameter is never reassigned anywhere in the method body (scanned
via OCMethodNode>>assignmentNodes, which already walks nested blocks and branches). Returns TypeVar(N)
where N is the parameter's 1-based position in the method's argument list, not its name.
"
Class {
	#name : 'ARTITypeVarCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTITypeVarCheck class >> classify: aTerminal context: aContext [
	"Matches a return of one of the method's own formal parameters, unmodified anywhere in the
	method body. Excluded (reports no match, not Unknown) when that parameter is reassigned."

	| exprNode methodNode position |
	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	exprNode := aTerminal returnValueNode.
	(exprNode isKindOf: OCVariableNode) ifFalse: [ ^ nil ].
	(exprNode variable isKindOf: ArgumentVariable) ifFalse: [ ^ nil ].

	methodNode := aContext methodNode.
	position := methodNode arguments findFirst: [ :arg |
		            arg name = exprNode variable name ].
	position = 0 ifTrue: [ ^ nil ].

	(self
		 isParameterNamed: exprNode variable name
		 reassignedIn: methodNode) ifTrue: [ ^ nil ].
	^ ARTITypeVarType position: position
]

{ #category : 'testing' }
ARTITypeVarCheck class >> isParameterNamed: aName reassignedIn: methodNode [
	"Scans the whole method body -- including inside nested blocks and conditional branches --
	for any assignment to a variable with this name."

	^ methodNode assignmentNodes anySatisfy: [ :assignment |
		  assignment variable name = aName ]
]
