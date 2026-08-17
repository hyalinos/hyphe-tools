"
Type ::= Unknown: at least one reachable terminal in the method could not be classified by
any of the 10 checks. Distinct from an empty Union -- see ARTIPipeline class>>inferType:safetyTable:.
"
Class {
	#name : 'ARTIUnknownType',
	#superclass : 'ARTIType',
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'printing' }
ARTIUnknownType >> printOn: aStream [

	aStream nextPutAll: 'Unknown'
]
