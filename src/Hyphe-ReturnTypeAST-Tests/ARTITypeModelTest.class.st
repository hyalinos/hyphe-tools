"
Tests for the ARTIType hierarchy: equality/hash, printing, Union de-duplication and
single-member collapsing, and ARTITypeNameNormalizer's replacement table.
"
Class {
	#name : 'ARTITypeModelTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
ARTITypeModelTest >> testClassRefEqualityAndPrinting [

	| a b c |
	a := ARTIClassRef named: #Integer.
	b := ARTIClassRef named: #Integer.
	c := ARTIClassRef named: #String.
	self assert: a = b.
	self assert: a hash = b hash.
	self deny: a = c.
	self assert: a printString equals: 'ClassRef(Integer)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testMetaclassEqualityAndPrinting [

	| a b |
	a := ARTIMetaclass named: #Integer.
	b := ARTIMetaclass named: #Integer.
	self assert: a = b.
	self deny: a = (ARTIClassRef named: #Integer).
	self assert: a printString equals: 'Metaclass(Integer)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testSelfSelfClassBottomUnknownAreSingletonLike [

	self assert: ARTISelfType new = ARTISelfType new.
	self assert: ARTISelfClassType new = ARTISelfClassType new.
	self assert: ARTIBottomType new = ARTIBottomType new.
	self assert: ARTIUnknownType new = ARTIUnknownType new.
	self deny: ARTISelfType new = ARTISelfClassType new.
	self assert: ARTISelfType new printString equals: 'Self'.
	self assert: ARTISelfClassType new printString equals: 'Self class'.
	self assert: ARTIBottomType new printString equals: 'Bottom'.
	self assert: ARTIUnknownType new printString equals: 'Unknown'
]

{ #category : 'tests' }
ARTITypeModelTest >> testTypeNameNormalizerLeavesUnknownNamesAsIs [

	self
		assert: (ARTITypeNameNormalizer normalize: #Array)
		equals: #Array.
	self
		assert: (ARTITypeNameNormalizer normalize: #OrderedCollection)
		equals: #OrderedCollection
]

{ #category : 'tests' }
ARTITypeModelTest >> testTypeNameNormalizerReplacesKnownRuntimeClasses [

	self
		assert: (ARTITypeNameNormalizer normalize: #SmallInteger)
		equals: #Integer.
	self
		assert: (ARTITypeNameNormalizer normalize: #LargePositiveInteger)
		equals: #Integer.
	self
		assert: (ARTITypeNameNormalizer normalize: #True)
		equals: #Boolean.
	self
		assert: (ARTITypeNameNormalizer normalize: #False)
		equals: #Boolean.
	self
		assert: (ARTITypeNameNormalizer normalize: #ByteString)
		equals: #String.
	self
		assert: (ARTITypeNameNormalizer normalize: #BoxedFloat64)
		equals: #Float
]

{ #category : 'tests' }
ARTITypeModelTest >> testTypeVarEqualityAndPrinting [

	| a b c |
	a := ARTITypeVarType position: 1.
	b := ARTITypeVarType position: 1.
	c := ARTITypeVarType position: 2.
	self assert: a = b.
	self deny: a = c.
	self assert: a printString equals: 'TypeVar(1)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testUnionCollapsesSingleMember [

	| u |
	u := ARTIUnionType withMembers: { (ARTIClassRef named: #Integer) }.
	self assert: (u isKindOf: ARTIClassRef).
	self deny: u isUnion
]

{ #category : 'tests' }
ARTITypeModelTest >> testUnionDeduplicatesMembers [

	| u |
	u := ARTIUnionType withMembers: {
			     (ARTIClassRef named: #Integer).
			     ARTIUnknownType new.
			     (ARTIClassRef named: #Integer) }.
	self assert: u isUnion.
	self assert: u members size equals: 2.
	self
		assert: u printString
		equals: 'Union(ClassRef(Integer), Unknown)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testUnionEqualityIsOrderIndependent [

	| u1 u2 |
	u1 := ARTIUnionType withMembers: {
			      (ARTIClassRef named: #Integer).
			      ARTIUnknownType new }.
	u2 := ARTIUnionType withMembers: {
			      ARTIUnknownType new.
			      (ARTIClassRef named: #Integer) }.
	self assert: u1 = u2
]
