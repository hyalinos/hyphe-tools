"
Tests of the notation of the ground truth: class names, r, a_n, ?, !, unions.
"
Class {
	#name : 'HYETypeExpressionTest',
	#superclass : 'HYEExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Data',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Data'
}

{ #category : 'tests' }
HYETypeExpressionTest >> testClassName [
	"A class name is a concrete type"

	| type |
	type := HYETypeExpression parse: 'Integer'.

	self assert: type classNames asArray equals: #( 'Integer' ).
	self assert: type isConcrete.
	self assert: type printString equals: 'Integer'
]

{ #category : 'tests' }
HYETypeExpressionTest >> testDuplicatesAreRemoved [
	"A | A is A"

	self assert: (HYETypeExpression parse: 'Integer | Integer') atoms size equals: 1
]

{ #category : 'tests' }
HYETypeExpressionTest >> testHashSymbolSyntaxOfTheToolFiles [
	"The tool results write #TextMorph"

	self assert: (HYETypeExpression parse: '#TextMorph') equals: (HYETypeExpression parse: 'TextMorph')
]

{ #category : 'tests' }
HYETypeExpressionTest >> testNamesStartingWithAreClasses [
	"Only a, a1, a_1 are arguments: class names starting with a are classes"

	self assert: (HYETypeExpression parse: 'Array') atoms first isClass.
	self assert: (HYETypeExpression parse: 'aClass') atoms first isClass.
	self assert: (HYETypeExpression parse: 'a1b') atoms first isClass
]

{ #category : 'tests' }
HYETypeExpressionTest >> testNoType [
	"nil, empty and 'nil' are no type"

	self assert: (HYETypeExpression parse: nil) isNil.
	self assert: (HYETypeExpression parse: '') isNil.
	self assert: (HYETypeExpression parse: '  ') isNil.
	self assert: (HYETypeExpression parse: 'nil') isNil
]

{ #category : 'tests' }
HYETypeExpressionTest >> testPrintString [
	"The notation is printed back"

	#( 'r' '?' '!' 'a' 'a1' 'String | ?' 'Integer | r | a2' ) do: [ :text |
		self assert: (HYETypeExpression parse: text) printString equals: text ]
]

{ #category : 'tests' }
HYETypeExpressionTest >> testResolvingTheReceiver [
	"r is the class of the method"

	| ref type |
	ref := HYEMethodRef package: 'P' class: 'Foo' selector: #bar.
	type := HYETypeExpression parse: 'r | Integer'.

	self assert: (type resolvedClassNamesFor: ref) equals: #( 'Foo' 'Integer' ) asSet.
	self assert: (type resolvedFor: ref) equals: (HYETypeExpression parse: 'Foo | Integer')
]

{ #category : 'tests' }
HYETypeExpressionTest >> testSpecialAtoms [
	"r, ?, ! and the arguments"

	self assert: (HYETypeExpression parse: 'r') hasReceiver.
	self assert: (HYETypeExpression parse: '?') hasUnknown.
	self assert: (HYETypeExpression parse: '!') hasAbstract.
	self assert: (HYETypeExpression parse: 'a') hasArgument.
	self assert: (HYETypeExpression parse: 'a1') atoms first index equals: 1.
	self assert: (HYETypeExpression parse: 'a_2') atoms first index equals: 2.
	self assert: (HYETypeExpression parse: 'a') atoms first index isNil.
	self deny: (HYETypeExpression parse: 'r') isConcrete
]

{ #category : 'tests' }
HYETypeExpressionTest >> testUnion [
	"String | ? has two atoms; order and spaces do not matter for equality"

	| type |
	type := HYETypeExpression parse: 'String|?'.

	self assert: type atoms size equals: 2.
	self assert: type hasUnknown.
	self assert: type classNames asArray equals: #( 'String' ).
	self assert: type equals: (HYETypeExpression parse: ' ? | String ').
	self assert: type hash equals: (HYETypeExpression parse: '? | String') hash.
	self deny: type = (HYETypeExpression parse: 'String')
]
