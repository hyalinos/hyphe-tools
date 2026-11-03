"
The AST based inferencer of Hyphe-ReturnTypeAST (ARTI) as a tool, run on the compiled method of the reference: a class gives that class, Self gives r, a union gives the union, a type variable gives the type of an argument; Unknown, Bottom (never returns), self class and methods that are excluded (primitives) give no answer; a method that is not in the image gives no answer too.
"
Class {
	#name : 'HyARTITool',
	#superclass : 'HyExpInferenceTool',
	#category : 'Hyphe-Experiments-Tools',
	#package : 'Hyphe-Experiments',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
HyARTITool class >> new [
	"Create the tool, named AST-based and marked as the AST based inferencer"

	^ super new
		  name: 'AST-based';
		  beAstBased;
		  yourself
]

{ #category : 'converting' }
HyARTITool >> expressionFor: aType [
	"Answer the HyTypeExpression of a type of the type model (Hyphe-TypeModel), nil if it says nothing"

	| atoms |
	(aType isKindOf: HTMClassRef) ifTrue: [ ^ HyTypeExpression classNames: { aType className } ].
	(aType isKindOf: HTMMetaclass) ifTrue: [ ^ HyTypeExpression classNames: { aType className } ].
	(aType isKindOf: HTMSelf) ifTrue: [ ^ HyTypeExpression atoms: { HyTypeAtom receiver } ].
	(aType isKindOf: HTMTypeVar) ifTrue: [ ^ HyTypeExpression atoms: { (HyTypeAtom argument: aType argumentIndex) } ].
	(aType isKindOf: HTMUnion) ifTrue: [
			atoms := OrderedCollection new.
			aType members do: [ :member | (self expressionFor: member) ifNotNil: [ :expression | atoms addAll: expression atoms ] ].
			^ atoms ifEmpty: [ nil ] ifNotEmpty: [ HyTypeExpression atoms: atoms ] ].
	^ nil
]

{ #category : 'inferring' }
HyARTITool >> predictionFor: aMethodRef [
	"Run the AST based inferencer on the method"

	| method report |
	method := aMethodRef compiledMethod ifNil: [ ^ self nothing ].
	report := ARTIReturnTypeInferrer inferMethods: { method }.
	report results isEmpty ifTrue: [ ^ self nothing ].
	^ (self expressionFor: report results first type)
		  ifNil: [ self nothing ]
		  ifNotNil: [ :expression | HyToolPrediction tool: name types: expression confidence: nil ]
]
