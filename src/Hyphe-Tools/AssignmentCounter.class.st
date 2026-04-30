"
I calculate the amount of assignement in a given method.
I consider all of the assignments in a method. 
To run this code
	- use a 'method:=  aClass >> #aMethod ' as argument of the method who calculate the amount of assignment:
		countAssignment: method. 
		

"
Class {
	#name : 'AssignmentCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'assignNumber'
	],
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'as yet unclassified' }
AssignmentCounter >> countAssignment: aMethod [
	aMethod ast acceptVisitor: self.
	^ assignNumber 
	
]

{ #category : 'initialization' }
AssignmentCounter >> initialize [ 
	super initialize.
	assignNumber := 0.
]

{ #category : 'visiting' }
AssignmentCounter >> visitAssignmentNode: anAssignement [
	assignNumber := assignNumber +1.
	super visitAssignmentNode: anAssignement 
]
