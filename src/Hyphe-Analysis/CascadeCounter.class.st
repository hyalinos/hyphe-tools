"
I count cascade in a method
To run this code, take a compiled method as argument
	counterCascade: aCompiledMethod
"
Class {
	#name : 'CascadeCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'cascadeNumber'
	],
	#category : 'Hyphe-Analysis',
	#package : 'Hyphe-Analysis'
}

{ #category : 'as yet unclassified' }
CascadeCounter class >> examplecCascadeCounter [
  <script>
   | method count| 
	"Compiled method to analyze, as an argument"
	method := CascadeCounterTestData >> #separateCascades.
   "Return the number cascade in the method"
	count := self new counterCascade: method.
	count inspect.
]

{ #category : 'initialization' }
CascadeCounter >> counterCascade: aMethod [
 	aMethod ast acceptVisitor: self.
	^ cascadeNumber 
]

{ #category : 'initialization' }
CascadeCounter >> initialize [ 
 super initialize.
 cascadeNumber := 0.
]

{ #category : 'initialization' }
CascadeCounter >> visitCascadeNode: aCascade [
	cascadeNumber := cascadeNumber + 1.
	super visitCascadeNode: aCascade .
]
