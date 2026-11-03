"
The analysis of one selector sent by a method: its name, how many classes implement it (size) and, for each of these classes, whether its implementation overrides the base implementation, i.e. whether one of its superclasses also implements the selector. For capacity: SelectorAnalysisResult(name: capacity, size: 8, implementors: [Collection -> false, HashedCollection -> true, ...]). Created by SelectorAnalyzer.
"
Class {
	#name : 'SelectorAnalysisResult',
	#superclass : 'Object',
	#instVars : [
		'name',
		'implementors'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'testing' }
SelectorAnalysisResult class >> does: aBehavior override: aSelector [
	"Answer true if a superclass of aBehavior also implements aSelector, i.e. the implementation of aBehavior overrides another one"

	^ aBehavior allSuperclasses anySatisfy: [ :superclass | superclass includesSelector: aSelector ]
]

{ #category : 'instance creation' }
SelectorAnalysisResult class >> name: aSelector implementors: anAssociationCollection [
	"Create the result for a selector; the implementors are associations class name -> overrides (true or false)"

	^ self new
		  setName: aSelector implementors: anAssociationCollection;
		  yourself
]

{ #category : 'accessing' }
SelectorAnalysisResult >> baseImplementors [
	"Answer the names of the classes whose implementation does not override another one"

	^ (implementors reject: [ :association | association value ]) collect: [ :association | association key ]
]

{ #category : 'accessing' }
SelectorAnalysisResult >> implementorNames [
	"Answer the names of the classes that implement the selector"

	^ implementors collect: [ :association | association key ]
]

{ #category : 'accessing' }
SelectorAnalysisResult >> implementors [
	"Answer the implementors as associations class name -> true if the implementation overrides one of a superclass, false if it is the base one"

	^ implementors
]

{ #category : 'accessing' }
SelectorAnalysisResult >> name [
	"Answer the selector"

	^ name
]

{ #category : 'accessing' }
SelectorAnalysisResult >> overrides: aClassName [
	"Answer whether the implementation of a class (by name) overrides another one; nil if the class does not implement the selector"

	^ (implementors detect: [ :association | association key = aClassName ] ifNone: [ nil ]) ifNotNil: [ :association |
		  association value ]
]

{ #category : 'accessing' }
SelectorAnalysisResult >> overridingImplementors [
	"Answer the names of the classes whose implementation overrides another one"

	^ (implementors select: [ :association | association value ]) collect: [ :association | association key ]
]

{ #category : 'printing' }
SelectorAnalysisResult >> printOn: aStream [
	"Print as SelectorAnalysisResult(name: capacity, size: 8, implementors: [Collection -> false, ...])"

	aStream
		nextPutAll: 'SelectorAnalysisResult(name: ';
		nextPutAll: name asString;
		nextPutAll: ', size: ';
		print: self size;
		nextPutAll: ', implementors: [';
		nextPutAll: (', ' join: (implementors collect: [ :association | association key , ' -> ' , association value printString ]));
		nextPutAll: '])'
]

{ #category : 'initialization' }
SelectorAnalysisResult >> setName: aSelector implementors: anAssociationCollection [
	"Set the selector and its implementors"

	name := aSelector.
	implementors := anAssociationCollection asOrderedCollection
]

{ #category : 'accessing' }
SelectorAnalysisResult >> size [
	"Answer the number of classes that implement the selector"

	^ implementors size
]
