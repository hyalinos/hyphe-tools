"
A reachable terminal (see ARTIReachabilityEngine) for an explicit ^ Expr return
statement. Carries the OCReturnNode; #returnValueNode answers the AST node for Expr, the value being
returned, which is what the 10 classification checks actually pattern-match against.
"
Class {
	#name : 'ARTIExplicitReturnTerminal',
	#superclass : 'ARTITerminal',
	#instVars : [
		'returnNode'
	],
	#category : 'Hyphe-ReturnTypeAST-Reachability',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Reachability'
}

{ #category : 'instance creation' }
ARTIExplicitReturnTerminal class >> on: aReturnNode [

	^ self new
		  setReturnNode: aReturnNode;
		  yourself
]

{ #category : 'printing' }
ARTIExplicitReturnTerminal >> printOn: aStream [

	aStream
		nextPutAll: 'ExplicitReturn(';
		print: self returnValueNode;
		nextPut: $)
]

{ #category : 'accessing' }
ARTIExplicitReturnTerminal >> returnNode [

	^ returnNode
]

{ #category : 'accessing' }
ARTIExplicitReturnTerminal >> returnValueNode [
	"The AST node for the expression being returned, e.g. the 5 in ^ 5."

	^ returnNode value
]

{ #category : 'private' }
ARTIExplicitReturnTerminal >> setReturnNode: aReturnNode [

	returnNode := aReturnNode
]
