"
Check 7 (ClassName new). Matches ExplicitReturn(Expr) where Expr is a #new message sent
to a global-class-name-binding receiver (e.g. ^ Array new), provided the Layer-0 safety table
(ARTINewSafetyTable) judges that class's new/basicNew unoverridden between it and Object; otherwise
reports no match (not Unknown -- the pipeline is what turns a lingering no-match into Unknown). self new
and super new are explicitly out of scope and never match here.
"
Class {
	#name : 'ARTIClassNameNewCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTIClassNameNewCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'classifying' }
ARTIClassNameNewCheck class >> matchExpr: exprNode context: aContext [
	"Matches a #new message sent to a global-class-name-binding receiver, e.g. ^ Array new, provided
	the Layer-0 safety table judges that class's new/basicNew unoverridden between it and Object.
	self new and super new are explicitly out of scope and never match here (their receiver is a
	SelfVariable/SuperVariable, not a GlobalVariable)."

	(exprNode isKindOf: OCMessageNode) ifFalse: [ ^ nil ].
	exprNode selector = #new ifFalse: [ ^ nil ].
	(exprNode receiver isKindOf: OCVariableNode) ifFalse: [ ^ nil ].
	(exprNode receiver variable isKindOf: GlobalVariable) ifFalse: [
		^ nil ].
	exprNode receiver variable isGlobalClassNameBinding ifFalse: [ ^ nil ].
	(aContext safetyTable isSafe: exprNode receiver variable value)
		ifFalse: [ ^ nil ].
	^ ARTIClassRef named: exprNode receiver variable name
]
