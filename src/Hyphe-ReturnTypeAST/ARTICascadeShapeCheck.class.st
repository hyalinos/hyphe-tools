"
Check 9 (Cascade shape). Not an independent return-type shape of its own -- a wrapper
that, given a cascade expression, checks whether (a) the cascade's receiver sub-expression independently
matches check 1, 2, 3, 4, or 7 (via their shared #matchExpr:context: entry point) and (b) the cascade's
last message is #yourself; if both hold, delegates to the matched check's result (e.g.
^ OrderedCollection new add: 1; yourself delegates to check 7 on the `OrderedCollection new` receiver).
TypeVar and BlockLiteral are deliberately not among the delegate checks.
"
Class {
	#name : 'ARTICascadeShapeCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTICascadeShapeCheck class >> classify: aTerminal context: aContext [

	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	^ self matchExpr: aTerminal returnValueNode context: aContext
]

{ #category : 'accessing' }
ARTICascadeShapeCheck class >> delegateCheckClasses [
	"Only these six checks may match a cascade's receiver sub-expression; TypeVar and BlockLiteral
	are intentionally excluded, and check 9 is deliberately not in its own delegate list."

	^ {
		  ARTILiteralCheck.
		  ARTIClassGlobalReadCheck.
		  ARTISelfCheck.
		  ARTISelfClassCheck.
		  ARTIClassNameNewCheck.
		  ARTIDynamicArrayCheck }
]

{ #category : 'classifying' }
ARTICascadeShapeCheck class >> matchExpr: exprNode context: aContext [
	"Matches a cascade, e.g. ^ OrderedCollection new add: 1; yourself, whose receiver independently
	matches one of checks 1/2/3/4/7 and whose last cascaded message is yourself; delegates to that
	matched check's result. Otherwise reports no match."

	(exprNode isKindOf: OCCascadeNode) ifFalse: [ ^ nil ].
	exprNode messages isEmpty ifTrue: [ ^ nil ].
	exprNode messages last selector = #yourself ifFalse: [ ^ nil ].
	^ self matchReceiver: exprNode receiver context: aContext
]

{ #category : 'private' }
ARTICascadeShapeCheck class >> matchReceiver: receiverNode context: aContext [

	self delegateCheckClasses do: [ :checkClass |
			| result |
			result := checkClass matchExpr: receiverNode context: aContext.
			result ifNotNil: [ ^ result ] ].
	^ nil
]
