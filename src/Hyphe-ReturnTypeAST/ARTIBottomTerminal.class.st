"
A reachable terminal (see ARTIReachabilityEngine) for a standalone send of error:, halt,
subclassResponsibility, shouldNotImplement, or notYetImplemented to self/super -- i.e. a statement
(not itself wrapped in a ^ return) after which the method never returns normally. Carries that
statement's AST node.
"
Class {
	#name : 'ARTIBottomTerminal',
	#superclass : 'ARTITerminal',
	#instVars : [
		'statementNode'
	],
	#category : 'Hyphe-ReturnTypeAST-Reachability',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Reachability'
}

{ #category : 'instance creation' }
ARTIBottomTerminal class >> on: aStatementNode [

	^ self new
		  setStatementNode: aStatementNode;
		  yourself
]

{ #category : 'printing' }
ARTIBottomTerminal >> printOn: aStream [

	aStream
		nextPutAll: 'BottomTerminal(';
		print: statementNode;
		nextPut: $)
]

{ #category : 'private' }
ARTIBottomTerminal >> setStatementNode: aStatementNode [

	statementNode := aStatementNode
]

{ #category : 'accessing' }
ARTIBottomTerminal >> statementNode [

	^ statementNode
]
