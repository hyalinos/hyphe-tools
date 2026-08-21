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
	a := HTMClassRef named: #Integer.
	b := HTMClassRef named: #Integer.
	c := HTMClassRef named: #String.
	self assert: a = b.
	self assert: a hash = b hash.
	self deny: a = c.
	self assert: a printString equals: 'ClassRef(Integer)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testMetaclassEqualityAndPrinting [

	| a b |
	a := HTMMetaclass named: #Integer.
	b := HTMMetaclass named: #Integer.
	self assert: a = b.
	self deny: a = (HTMClassRef named: #Integer).
	self assert: a printString equals: 'Metaclass(Integer)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testSelfSelfClassBottomUnknownAreSingletonLike [

	self assert: HTMSelf new = HTMSelf new.
	self assert: HTMSelfClass new = HTMSelfClass new.
	self assert: HTMBottom new = HTMBottom new.
	self assert: HTMUnknown new = HTMUnknown new.
	self deny: HTMSelf new = HTMSelfClass new.
	self assert: HTMSelf new printString equals: 'Self'.
	self assert: HTMSelfClass new printString equals: 'Self class'.
	self assert: HTMBottom new printString equals: 'Bottom'.
	self assert: HTMUnknown new printString equals: 'Unknown'
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
	a := HTMTypeVar position: 1.
	b := HTMTypeVar position: 1.
	c := HTMTypeVar position: 2.
	self assert: a = b.
	self deny: a = c.
	self assert: a printString equals: 'TypeVar(1)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testUnionCollapsesSingleMember [

	| u |
	u := HTMUnion withMembers: { (HTMClassRef named: #Integer) }.
	self assert: (u isKindOf: HTMClassRef).
	self deny: u isUnion
]

{ #category : 'tests' }
ARTITypeModelTest >> testUnionDeduplicatesMembers [

	| u |
	u := HTMUnion withMembers: {
			     (HTMClassRef named: #Integer).
			     HTMUnknown new.
			     (HTMClassRef named: #Integer) }.
	self assert: u isUnion.
	self assert: u members size equals: 2.
	self
		assert: u printString
		equals: 'Union(ClassRef(Integer), Unknown)'
]

{ #category : 'tests' }
ARTITypeModelTest >> testUnionEqualityIsOrderIndependent [

	| u1 u2 |
	u1 := HTMUnion withMembers: {
			      (HTMClassRef named: #Integer).
			      HTMUnknown new }.
	u2 := HTMUnion withMembers: {
			      HTMUnknown new.
			      (HTMClassRef named: #Integer) }.
	self assert: u1 = u2
]
