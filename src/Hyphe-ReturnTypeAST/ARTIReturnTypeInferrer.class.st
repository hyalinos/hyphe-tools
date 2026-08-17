"
Entry point (facade) for the tool. Accepts exactly one of: a package name, a class, or no argument
(whole image) and returns an ARTIInferenceReport.
"
Class {
	#name : 'ARTIReturnTypeInferrer',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Pipeline',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Pipeline'
}

{ #category : 'entry points' }
ARTIReturnTypeInferrer class >> inferClass: aClass [
	"§4: infer over all methods (instance-side and class-side) of aClass."

	^ self inferMethods: (self methodsOfClass: aClass)
]

{ #category : 'entry points' }
ARTIReturnTypeInferrer class >> inferImage [
	"§4: infer over every method reachable from Smalltalk globals, i.e. the whole image."

	^ self inferMethods: self methodsOfImage
]

{ #category : 'running' }
ARTIReturnTypeInferrer class >> inferMethods: aCompiledMethodCollection [
	"REQ-S1: one safety table, built once, is shared read-only across every method in this invocation."

	| safetyTable results excludedPrimitive |
	safetyTable := ARTINewSafetyTable new.
	results := OrderedCollection new.
	excludedPrimitive := OrderedCollection new.

	aCompiledMethodCollection do: [ :method |
			| outcome |
			outcome := ARTIPipeline inferType: method safetyTable: safetyTable.
			outcome = #excludedPrimitive
				ifTrue: [ excludedPrimitive add: method ]
				ifFalse: [
						outcome = #excludedEmpty ifFalse: [
							results add: (self resultFor: method type: outcome) ] ] ].

	^ ARTIInferenceReport
		  results: results
		  excludedPrimitive: excludedPrimitive
]

{ #category : 'entry points' }
ARTIReturnTypeInferrer class >> inferPackage: aPackageName [
	"§4: infer over all methods (instance-side and class-side) of all classes belonging to aPackageName."

	^ self inferMethods: (self methodsOfPackage: aPackageName)
]

{ #category : 'method collecting' }
ARTIReturnTypeInferrer class >> methodsOfClass: aClass [

	| collectedMethods |
	collectedMethods := OrderedCollection new.
	collectedMethods addAll: aClass methods.
	collectedMethods addAll: aClass class methods.
	^ collectedMethods
]

{ #category : 'method collecting' }
ARTIReturnTypeInferrer class >> methodsOfImage [

	^ Smalltalk globals methods
]

{ #category : 'method collecting' }
ARTIReturnTypeInferrer class >> methodsOfPackage: aPackageName [

	^ (Smalltalk globals organization packageNamed: aPackageName) methods
]

{ #category : 'private' }
ARTIReturnTypeInferrer class >> resultFor: aCompiledMethod type: aType [

	| behaviorSide isClassSide className |
	behaviorSide := aCompiledMethod methodClass.
	isClassSide := behaviorSide isClassSide.
	className := isClassSide
		             ifTrue: [ behaviorSide soleInstance name ]
		             ifFalse: [ behaviorSide name ].
	^ ARTIMethodResult
		  package: aCompiledMethod package name
		  class: className
		  selector: aCompiledMethod selector
		  classSide: isClassSide
		  type: aType
]
