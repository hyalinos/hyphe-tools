"
Entry point of Hyphe-ReturnTypeHeuristic, mirroring ARTIReturnTypeInferrer's shape from Hyphe-ReturnTypeAST: #classify:classSide: for a single selector, #classifyClass:/#classifyPackage:/#classifyImage for whole-image sweeps, all producing an ARTHInferenceReport. Package attribution is taken from each CompiledMethod's own #package (not the class's home package), so extension methods are attributed correctly -- this matters for the package-concentration check that the calibration protocol requires. A stateless, pure function of (selector, classSide) with no dependency on the class or its AST: two identically-named selectors on unrelated classes always classify identically.
"
Class {
	#name : 'ARTHClassifier',
	#superclass : 'Object',
	#classInstVars : [
		'CachedCatalog'
	],
	#category : 'Hyphe-ReturnTypeHeuristic',
	#package : 'Hyphe-ReturnTypeHeuristic'
}

{ #category : 'accessing' }
ARTHClassifier class >> catalog [

	^ CachedCatalog ifNil: [ CachedCatalog := ARTHPatternCatalog trusted ]
]

{ #category : 'classifying' }
ARTHClassifier class >> classify: aSelector classSide: isClassSide [

	^ self catalog bestMatchFor: aSelector classSide: isClassSide
]

{ #category : 'classifying' }
ARTHClassifier class >> classifyClass: aClass [

	^ self classifyMethods: aClass methods , aClass class methods
]

{ #category : 'classifying' }
ARTHClassifier class >> classifyImage [

	| allMethods |
	allMethods := OrderedCollection new.
	PackageOrganizer default packages do: [ :p |
		allMethods addAll: p methods ].
	^ self classifyMethods: allMethods
]

{ #category : 'classifying' }
ARTHClassifier class >> classifyMethod: aCompiledMethod [

	| isClassSide plainClassName packageName classification |
	isClassSide := aCompiledMethod methodClass isMeta.
	plainClassName := isClassSide
		                  ifTrue: [
		                  aCompiledMethod methodClass soleInstance name ]
		                  ifFalse: [ aCompiledMethod methodClass name ].
	packageName := aCompiledMethod package
		               ifNil: [ '' ]
		               ifNotNil: [ :p | p name ].
	classification := self
		                  classify: aCompiledMethod selector
		                  classSide: isClassSide.
	^ ARTHMethodResult
		  package: packageName
		  class: plainClassName
		  classSide: isClassSide
		  classification: classification
]

{ #category : 'classifying' }
ARTHClassifier class >> classifyMethods: aCollectionOfCompiledMethods [

	| report |
	report := ARTHInferenceReport new.
	aCollectionOfCompiledMethods do: [ :m |
		report addResult: (self classifyMethod: m) ].
	^ report
]

{ #category : 'classifying' }
ARTHClassifier class >> classifyPackage: aPackageNameOrPackage [

	| package |
	package := aPackageNameOrPackage isString
		           ifTrue: [
			           PackageOrganizer default packageNamed:
				           aPackageNameOrPackage asSymbol ]
		           ifFalse: [ aPackageNameOrPackage ].
	^ self classifyMethods: package methods
]

{ #category : 'accessing' }
ARTHClassifier class >> resetCatalog [
	"Forces #catalog to rebuild ARTHPatternCatalog trusted on next access -- use after live-patching\n\tthe seed data during development."

	CachedCatalog := nil
]
