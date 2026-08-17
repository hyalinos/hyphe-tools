"
Type ::= Self class: the metaclass of the receiver's own class, e.g. a method that answers
^ self class.
"
Class {
	#name : 'ARTISelfClassType',
	#superclass : 'ARTIType',
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'printing' }
ARTISelfClassType >> printOn: aStream [

	aStream nextPutAll: 'Self class'
]
