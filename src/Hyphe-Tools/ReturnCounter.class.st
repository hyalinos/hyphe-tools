Class {
	#name : 'ReturnCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'returnNumber'
	],
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'as yet unclassified' }
ReturnCounter >> initialize [
	super initialize.
	returnNumber := 0.
]

{ #category : 'visiting' }
ReturnCounter >> returnInMethod: aMethod [
	aMethod ast acceptVisitor: self.
	^ returnNumber
]

{ #category : 'visiting' }
ReturnCounter >> visitReturnNode: aReturnNode [
	returnNumber := returnNumber + 1.
	super visitReturnNode: aReturnNode 
]
