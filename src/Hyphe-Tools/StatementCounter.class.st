"
I calculate amount of statements for a given method in pharo based on its AST.
I can work with both instance and class methods.
I accept a compiled method as an input and return a count as an integer value.

I consider the following statements:
- Assignment statements (x := value)
- Message sends (unary, binary, and keyword messages)
- Return statements (^ expression)
- Cascade sequences (each message in a cascade counts as a separate statement)
- Statements inside of blocks

I do not consider the following constructs:
- Block closures themselves (only statements within blocks) and their arguments
- The control structure message sends themselves (e.g ifTrue:, do:).
- Variable declarations (temporaries)
- Method signatures
- Comments
- Annotations
"
Class {
	#name : 'StatementCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'count'
	],
	#category : 'Hyphe-Tools-StaticAnalysis',
	#package : 'Hyphe-Tools',
	#tag : 'StaticAnalysis'
}

{ #category : 'as yet unclassified' }
StatementCounter class >> countStatementsIn: aMethod [

    ^ self new countIn: aMethod
]

{ #category : 'initialization' }
StatementCounter >> count [
	
	^ count
]

{ #category : 'initialization' }
StatementCounter >> countIn: aMethod [

    count := 0.
    aMethod ast acceptVisitor: self.
    ^ count
]

{ #category : 'initialization' }
StatementCounter >> initialize [
    super initialize.
    count := 0.
]

{ #category : 'initialization' }
StatementCounter >> visitAssignmentNode: aNode [

    count := count + 1.
    super visitAssignmentNode: aNode
]

{ #category : 'initialization' }
StatementCounter >> visitMessageNode: aNode [

    count := count + 1.
    super visitMessageNode: aNode
]

{ #category : 'initialization' }
StatementCounter >> visitReturnNode: aNode [

    count := count + 1.
    super visitReturnNode: aNode
]
