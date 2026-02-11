"
A HyCFGTest is a test class for testing the behavior of HyCFG
"
Class {
	#name : 'HyCFGTest',
	#superclass : 'TestCase',
	#instVars : [
		'cfg'
	],
	#category : 'Hyphe-CFG-Tests',
	#package : 'Hyphe-CFG-Tests'
}

{ #category : 'running' }
HyCFGTest >> setUp [ 

	super setUp.
	cfg := HyCFG new
]

{ #category : 'running' }
HyCFGTest >> testAddEdge [ 

	| edge source target |
	source := HyCFGStatementNode new.
	target := HyCFGStatementNode new.
	edge := HyCFGEdge from: source to: target.
	cfg addEdge: edge.
	
	self assert: cfg edges size equals: 1.
	self assert: (cfg edges includes: edge)
]

{ #category : 'running' }
HyCFGTest >> testAddNode [ 

	| node |
	node := HyCFGStatementNode new.
	cfg addNode: node.
	
	self assert: cfg nodes size equals: 1.
	self assert: (cfg nodes includes: node)
]

{ #category : 'running' }
HyCFGTest >> testInitialization [ 

	self assert: cfg nodes isEmpty.
	self assert: cfg edges isEmpty.
	self assert: cfg entryNode isNil.
	self assert: cfg exitNode isNil
]

{ #category : 'running' }
HyCFGTest >> testSetEntryNode [ 

	| entry |
	entry := HyCFGEntryNode new.
	cfg entryNode: entry.
	
	self assert: cfg entryNode equals: entry
]

{ #category : 'running' }
HyCFGTest >> testSetExitNode [ 

	| exit |
	exit := HyCFGExitNode new.
	cfg exitNode: exit.
	
	self assert: cfg exitNode equals: exit
]
