"
Tests of the notation of the ground truth: class names, r, a_n, ?, !, unions.
"
Class {
	#name : 'HyTypeExpressionTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Data',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Data'
}

{ #category : 'tests' }
HyTypeExpressionTest >> testClassName [
	"A class name is a concrete type"

	| type |
	type := HyTypeExpression parse: 'Integer'.

	self assert: type classNames asArray equals: #( 'Integer' ).
	self assert: type isConcrete.
	self assert: type printString equals: 'Integer'
]

{ #category : 'tests' }
HyTypeExpressionTest >> testDuplicatesAreRemoved [
	"A | A is A"

	self assert: (HyTypeExpression parse: 'Integer | Integer') atoms size equals: 1
]

{ #category : 'tests' }
HyTypeExpressionTest >> testHashSymbolSyntaxOfTheToolFiles [
	"The tool results write #TextMorph"

	self assert: (HyTypeExpression parse: '#TextMorph') equals: (HyTypeExpression parse: 'TextMorph')
]

{ #category : 'tests' }
HyTypeExpressionTest >> testNamesStartingWithAreClasses [
	"Only a, a1, a_1 are arguments: class names starting with a are classes"

	self assert: (HyTypeExpression parse: 'Array') atoms first isClass.
	self assert: (HyTypeExpression parse: 'aClass') atoms first isClass.
	self assert: (HyTypeExpression parse: 'a1b') atoms first isClass
]

{ #category : 'tests' }
HyTypeExpressionTest >> testNoType [
	"nil, empty and 'nil' are no type"

	self assert: (HyTypeExpression parse: nil) isNil.
	self assert: (HyTypeExpression parse: '') isNil.
	self assert: (HyTypeExpression parse: '  ') isNil.
	self assert: (HyTypeExpression parse: 'nil') isNil
]

{ #category : 'tests' }
HyTypeExpressionTest >> testPrintString [
	"The notation is printed back"

	#( 'r' '?' '!' 'a' 'a1' 'String | ?' 'Integer | r | a2' ) do: [ :text |
		self assert: (HyTypeExpression parse: text) printString equals: text ]
]

{ #category : 'tests' }
HyTypeExpressionTest >> testResolvingTheReceiver [
	"r is the class of the method"

	| ref type |
	ref := HyMethodRef package: 'P' class: 'Foo' selector: #bar.
	type := HyTypeExpression parse: 'r | Integer'.

	self assert: (type resolvedClassNamesFor: ref) equals: #( 'Foo' 'Integer' ) asSet.
	self assert: (type resolvedFor: ref) equals: (HyTypeExpression parse: 'Foo | Integer')
]

{ #category : 'tests' }
HyTypeExpressionTest >> testSpecialAtoms [
	"r, ?, ! and the arguments"

	self assert: (HyTypeExpression parse: 'r') hasReceiver.
	self assert: (HyTypeExpression parse: '?') hasUnknown.
	self assert: (HyTypeExpression parse: '!') hasAbstract.
	self assert: (HyTypeExpression parse: 'a') hasArgument.
	self assert: (HyTypeExpression parse: 'a1') atoms first index equals: 1.
	self assert: (HyTypeExpression parse: 'a_2') atoms first index equals: 2.
	self assert: (HyTypeExpression parse: 'a') atoms first index isNil.
	self deny: (HyTypeExpression parse: 'r') isConcrete
]

{ #category : 'tests' }
HyTypeExpressionTest >> testUnion [
	"String | ? has two atoms; order and spaces do not matter for equality"

	| type |
	type := HyTypeExpression parse: 'String|?'.

	self assert: type atoms size equals: 2.
	self assert: type hasUnknown.
	self assert: type classNames asArray equals: #( 'String' ).
	self assert: type equals: (HyTypeExpression parse: ' ? | String ').
	self assert: type hash equals: (HyTypeExpression parse: '? | String') hash.
	self deny: type = (HyTypeExpression parse: 'String')
]
