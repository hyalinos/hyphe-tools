"
Type ::= Self: the receiver's own (unresolved) class -- the method returns self, or falls off
the end of its body without an explicit return (which implicitly answers self).
"
Class {
	#name : 'ARTISelfType',
	#superclass : 'ARTIType',
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'printing' }
ARTISelfType >> printOn: aStream [

	aStream nextPutAll: 'Self'
]
