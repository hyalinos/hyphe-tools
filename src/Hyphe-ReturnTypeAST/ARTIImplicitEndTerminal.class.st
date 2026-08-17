"
A reachable terminal (see ARTIReachabilityEngine) representing the method falling off
the end of its top-level statement sequence without an explicit return on every path, which implicitly
answers self. Carries the enclosing OCMethodNode for context; there is at most one of these per method.
"
Class {
	#name : 'ARTIImplicitEndTerminal',
	#superclass : 'ARTITerminal',
	#instVars : [
		'methodNode'
	],
	#category : 'Hyphe-ReturnTypeAST-Reachability',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Reachability'
}

{ #category : 'instance creation' }
ARTIImplicitEndTerminal class >> forMethod: aMethodNode [

	^ self new
		  setMethodNode: aMethodNode;
		  yourself
]

{ #category : 'accessing' }
ARTIImplicitEndTerminal >> methodNode [

	^ methodNode
]

{ #category : 'printing' }
ARTIImplicitEndTerminal >> printOn: aStream [

	aStream nextPutAll: 'ImplicitEnd'
]

{ #category : 'private' }
ARTIImplicitEndTerminal >> setMethodNode: aMethodNode [

	methodNode := aMethodNode
]
