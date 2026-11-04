"
The AST based inferencer of Hyphe-ReturnTypeAST (ARTI) as a tool, run on the compiled method of the reference: a class gives that class, Self gives r, a union gives the union, a type variable gives the type of an argument; Unknown, Bottom (never returns), self class and methods that are excluded (primitives) give no answer; a method that is not in the image gives no answer too.
"
Class {
	#name : 'HYEARTITool',
	#superclass : 'HYEExpInferenceTool',
	#category : 'Hyphe-Experiments-Tools',
	#package : 'Hyphe-Experiments',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
HYEARTITool class >> new [
	"Create the tool, named AST-based and marked as the AST based inferencer"

	^ super new
		  name: 'AST-based';
		  beAstBased;
		  yourself
]

{ #category : 'converting' }
HYEARTITool >> expressionFor: aType [
	"Answer the HYETypeExpression of a type of the type model (Hyphe-TypeModel), nil if it says nothing"

	| atoms |
	(aType isKindOf: HTMClassRef) ifTrue: [ ^ HYETypeExpression classNames: { aType className } ].
	(aType isKindOf: HTMMetaclass) ifTrue: [ ^ HYETypeExpression classNames: { aType className } ].
	(aType isKindOf: HTMSelf) ifTrue: [ ^ HYETypeExpression atoms: { HYETypeAtom receiver } ].
	(aType isKindOf: HTMTypeVar) ifTrue: [ ^ HYETypeExpression atoms: { (HYETypeAtom argument: aType argumentIndex) } ].
	(aType isKindOf: HTMUnion) ifTrue: [
			atoms := OrderedCollection new.
			aType members do: [ :member | (self expressionFor: member) ifNotNil: [ :expression | atoms addAll: expression atoms ] ].
			^ atoms ifEmpty: [ nil ] ifNotEmpty: [ HYETypeExpression atoms: atoms ] ].
	^ nil
]

{ #category : 'inferring' }
HYEARTITool >> predictionFor: aMethodRef [
	"Run the AST based inferencer on the method"

	| method report |
	method := aMethodRef compiledMethod ifNil: [ ^ self nothing ].
	report := ARTIReturnTypeInferrer inferMethods: { method }.
	report results isEmpty ifTrue: [ ^ self nothing ].
	^ (self expressionFor: report results first type)
		  ifNil: [ self nothing ]
		  ifNotNil: [ :expression | HYEToolPrediction tool: name types: expression confidence: nil ]
]
