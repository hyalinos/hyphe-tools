"
Where the execution of the method ends (return or end of the method). There is exactly one in a CFG and it is terminal: nothing follows it.
"
Class {
	#name : 'HyCFGExitNode',
	#superclass : 'HyCFGStructureNode',
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'testin' }
HyCFGExitNode >> isTerminal [
	"Nothing follows the exit node"

	^ true
]
