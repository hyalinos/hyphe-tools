"
Type ::= Bottom: the method never returns normally along this path, e.g. it always sends
self error:/halt/subclassResponsibility/shouldNotImplement/notYetImplemented.
"
Class {
	#name : 'ARTIBottomType',
	#superclass : 'ARTIType',
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'printing' }
ARTIBottomType >> printOn: aStream [

	aStream nextPutAll: 'Bottom'
]
