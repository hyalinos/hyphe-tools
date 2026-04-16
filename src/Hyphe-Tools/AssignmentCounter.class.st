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
