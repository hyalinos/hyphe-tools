"
REQ-G1/G2. Stateless method-level gates run before reachability analysis.
"
Class {
	#name : 'ARTIMethodGate',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Gates',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Gates'
}

{ #category : 'testing' }
ARTIMethodGate class >> hasNoStatements: aMethodNode [
	"REQ-G2: a body consisting only of a comment and/or pragmas (no statements) is silently
	excluded from the output collection."

	^ aMethodNode body statements isEmpty
]

{ #category : 'testing' }
ARTIMethodGate class >> isExcludedByPrimitive: aCompiledMethod [
	"REQ-G1: a <primitive: N> pragma means the visible body only describes the primitive-failure
	path, so the method is excluded from reachability analysis and from the output collection
	entirely (though the caller is expected to surface it separately as 'excluded')."

	^ aCompiledMethod ast pragmas anySatisfy: [ :pragma |
		  pragma isPrimitive ]
]
