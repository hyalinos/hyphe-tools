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
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

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
