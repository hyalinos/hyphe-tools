"
Tests of HyMethodRef: creation from methods and records, finding the method in the image, equality.
"
Class {
	#name : 'HyMethodRefTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Data',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Data'
}

{ #category : 'tests' }
HyMethodRefTest >> testClassSide [
	"A class side method has the suffix class, its instance class name does not"

	| ref |
	ref := HyMethodRef fromCompiledMethod: MetricsTestData class >> #instantiatesItself.

	self assert: ref className equals: #'MetricsTestData class'.
	self assert: ref isClassSide.
	self assert: ref instanceClassName equals: #MetricsTestData.
	self assert: ref behavior equals: MetricsTestData class.
	self assert: ref compiledMethod equals: MetricsTestData class >> #instantiatesItself
]

{ #category : 'tests' }
HyMethodRefTest >> testEqualityIgnoresThePackage [
	"Class and selector identify the method"

	| a b |
	a := HyMethodRef package: 'P1' class: 'Foo' selector: #bar.
	b := HyMethodRef package: 'P2' class: 'Foo' selector: #bar.

	self assert: a equals: b.
	self assert: a hash equals: b hash.
	self deny: a = (HyMethodRef package: 'P1' class: 'Foo class' selector: #bar).
	self deny: a = (HyMethodRef package: 'P1' class: 'Foo' selector: #baz)
]

{ #category : 'tests' }
HyMethodRefTest >> testFindsTheMethod [
	"compiledMethod answers the method of the image"

	self assert: (self metricsRef: #mixedSends) compiledMethod equals: MetricsTestData >> #mixedSends
]

{ #category : 'tests' }
HyMethodRefTest >> testFromCompiledMethod [
	"The package, class and selector of an instance side method"

	| ref |
	ref := self metricsRef: #mixedSends.

	self assert: ref package equals: #'Hyphe-Analysis-Tests'.
	self assert: ref className equals: #MetricsTestData.
	self assert: ref selector equals: #mixedSends.
	self deny: ref isClassSide
]

{ #category : 'tests' }
HyMethodRefTest >> testFromRecordWithTheNamesOfTheDifferentFiles [
	"class or className, selector or methodSelector, as in the ground truth, the tool results and the old comparison files"

	| ref |
	ref := HyMethodRef fromRecord: (Dictionary new
			        at: 'package' put: 'P';
			        at: 'class' put: 'Foo';
			        at: 'selector' put: 'bar:';
			        yourself).
	self assert: ref selector equals: #bar:.

	ref := HyMethodRef fromRecord: (Dictionary new
			        at: 'classname' put: 'Foo';
			        at: 'methodselector' put: 'bar';
			        yourself).
	self assert: ref className equals: 'Foo'.
	self assert: ref package isNil
]

{ #category : 'tests' }
HyMethodRefTest >> testFromRecordWithoutClassOrSelector [
	"Such a record is no method"

	self assert: (HyMethodRef fromRecord: (Dictionary new
				  at: 'class' put: 'Foo';
				  yourself)) isNil.
	self assert: (HyMethodRef fromRecord: (Dictionary new
				  at: 'selector' put: 'foo';
				  yourself)) isNil
]

{ #category : 'tests' }
HyMethodRefTest >> testMissingMethodAndClass [
	"A reference to something that is not in the image finds nothing"

	self assert: (HyMethodRef package: 'P' class: 'MetricsTestData' selector: #doesNotExistAnywhere) compiledMethod isNil.
	self assert: (HyMethodRef package: 'P' class: 'NoSuchClassAnywhere' selector: #foo) compiledMethod isNil.
	self assert: (HyMethodRef package: 'P' class: 'NoSuchClassAnywhere class' selector: #foo) behavior isNil
]

{ #category : 'tests' }
HyMethodRefTest >> testPrintString [
	"Class>>#selector"

	self assert: (self metricsRef: #mixedSends) printString equals: 'MetricsTestData>>#mixedSends'
]
