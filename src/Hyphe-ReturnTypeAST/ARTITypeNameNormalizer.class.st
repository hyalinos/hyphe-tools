"
Normalizes runtime literal classes to their public-facing type name (e.g. SmallInteger -> Integer),
for use only by ARTILiteralCheck.
"
Class {
	#name : 'ARTITypeNameNormalizer',
	#superclass : 'Object',
	#classInstVars : [
		'typeNameReplacements'
	],
	#category : 'Hyphe-ReturnTypeAST-Model',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Model'
}

{ #category : 'utilities' }
ARTITypeNameNormalizer class >> normalize: aClassNameSymbol [

	^ self typeNameReplacements
		  at: aClassNameSymbol
		  ifAbsent: [ aClassNameSymbol ]
]

{ #category : 'class initialization' }
ARTITypeNameNormalizer class >> reset [

	<script>
	typeNameReplacements := nil
]

{ #category : 'accessing' }
ARTITypeNameNormalizer class >> typeNameReplacements [

	^ typeNameReplacements ifNil: [
			  typeNameReplacements := {
				                          (#True -> #Boolean).
				                          (#False -> #Boolean).
				                          (#ByteString -> #String).
				                          (#ByteSymbol -> #String).
				                          (#WideString -> #String).
				                          (#WideSymbol -> #String).
				                          (#BoxedFloat64 -> #Float).
				                          (#SmallFloat64 -> #Float).
				                          (#LargeNegativeInteger -> #Integer).
				                          (#LargePositiveInteger -> #Integer).
				                          (#LargeInteger -> #Integer).
				                          (#SmallInteger -> #Integer) }
				                          asDictionary ]
]
