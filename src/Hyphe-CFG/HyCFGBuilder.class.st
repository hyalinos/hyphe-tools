Class {
	#name : 'HyCFGBuilder',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'cfg',
		'currentNode',
		'currentNestingDepth',
		'methodNode'
	],
	#classInstVars : [
		'PatternRegistry'
	],
	#category : 'Hyphe-CFG-Builder',
	#package : 'Hyphe-CFG',
	#tag : 'Builder'
}

{ #category : 'class initialization' }
HyCFGBuilder class >> buildFrom: aOCMethodNode [ 
	
	^ self new buildFrom: aOCMethodNode
]

{ #category : 'class initialization' }
HyCFGBuilder class >> handlerFor: selector [ 
	
	^ self patternRegistry at: selector ifAbsent: [ nil ]
]

{ #category : 'class initialization' }
HyCFGBuilder class >> initialize [ 
	
	self initializePatternRegistry
]

{ #category : 'class initialization' }
HyCFGBuilder class >> initializePatternRegistry [
	"Set up the default pattern registry with all recognized control flow patterns"

	PatternRegistry := Dictionary new. 
	
	"Conditionals on Boolean"
	self registerPattern: #ifTrue: handler: #handleIfTrue:.
	self registerPattern: #ifFalse: handler: #handleIfFalse:.
	self registerPattern: #ifTrue:ifFalse: handler: #handleIfTrueIfFalse:.
	self registerPattern: #ifFalse:ifTrue: handler: #handleIfFalseIfTrue:. 
	
	"Nil checks"
	self registerPattern: #ifNil: handler: #handleIfNil:.
	self registerPattern: #ifNotNil: handler: #handleIfNotNil:.
	self registerPattern: #ifNil:ifNotNil: handler: #handleIfNilIfNotNil:.
	self registerPattern: #ifNotNil:ifNil: handler: #handleIfNotNilIfNil:. 
	
	"Empty checks"
	self registerPattern: #ifEmpty: handler: #handleIfEmpty:.
	self registerPattern: #ifNotEmpty: handler: #handleIfNotEmpty:.
	self registerPattern: #ifEmpty:ifNotEmpty: handler: #handleIfEmptyIfNotEmpty:.
	self registerPattern: #ifNotEmpty:ifEmpty: handler: #handleIfNotEmptyIfEmpty:. 
	
	"Loops"
	self registerPattern: #whileTrue: handler: #handleWhileTrue:.
	self registerPattern: #whileFalse: handler: #handleWhileFalse:.
	self registerPattern: #whileTrue handler: #handleWhileTrueNoArg.
	self registerPattern: #whileFalse handler: #handleWhileFalseNoArg.
	self registerPattern: #timesRepeat: handler: #handleTimesRepeat:.
	self registerPattern: #to:do: handler: #handleToDo:.
	self registerPattern: #to:by:do: handler: #handleToByDo:. 
	
	"Collection iteration"
	self registerPattern: #do: handler: #handleDo:.
	self registerPattern: #collect: handler: #handleCollect:.
	self registerPattern: #select: handler: #handleSelect:.
	self registerPattern: #reject: handler: #handleReject:.
	self registerPattern: #detect: handler: #handleDetect:.
	self registerPattern: #detect:ifNone: handler: #handleDetectIfNone:.
	self registerPattern: #with:do: handler: #handleWithDo:.
	self registerPattern: #withIndexDo: handler: #handleWithIndexDo:.
	self registerPattern: #inject:into: handler: #handleInjectInto:. 
	
	"Switch-like"
	self registerPattern: #caseOf: handler: #handleCaseOf:.
	self registerPattern: #caseOf:otherwise: handler: #handleCaseOfOtherwise:. 
	
	"Exception handling"
	self registerPattern: #on:do: handler: #handleOnDo:.
	self registerPattern: #ensure: handler: #handleEnsure:.
	self registerPattern: #ifCurtailed: handler: #handleIfCurtailed:
]

{ #category : 'class initialization' }
HyCFGBuilder class >> isRecognizedPattern: selector [
	
	^ self patternRegistry includesKey: selector
]

{ #category : 'class initialization' }
HyCFGBuilder class >> patternRegistry [ 
	
	^ PatternRegistry ifNil: [ self initializePatternRegistry. PatternRegistry ]
]

{ #category : 'class initialization' }
HyCFGBuilder class >> registerPattern: selector handler: handlerSelector [
	
	PatternRegistry at: selector put: handlerSelector
]

{ #category : 'initialization' }
HyCFGBuilder >> buildFrom: aOCMethodNode [

	methodNode := aOCMethodNode.
	cfg entryNode: HyCFGEntryNode new.
	cfg exitNode: HyCFGExitNode new.
	cfg addNode: cfg entryNode.
	cfg addNode: cfg exitNode.
	currentNode := cfg entryNode.
	aOCMethodNode body ifNotNil: [ :body | self visitSequenceNode: body ].

	((currentNode isTerminal = false) and: [ currentNode ~= cfg exitNode ]) ifTrue: [ self connectNode: currentNode to: cfg exitNode ].

	^ cfg
]

{ #category : 'initialization' }
HyCFGBuilder >> connectNode: sourceNode to: targetNode [
	
	| edge |
	edge := HyCFGSequentialEdge from: sourceNode to: targetNode.
	cfg addEdge: edge
]

{ #category : 'initialization' }
HyCFGBuilder >> connectNode: sourceNode to: targetNode withEdge: edgeClass [

	| edge |
	edge := edgeClass from: sourceNode to: targetNode.
	cfg addEdge: edge
]

{ #category : 'visiting' }
HyCFGBuilder >> createControlFlowNode: aMessageNode [

	^ cfg addNode: (HyCFGControlFlowNode new
			   astNode: aMessageNode;
			   nestingDepth: currentNestingDepth;
			   yourself)
]

{ #category : 'visiting' }
HyCFGBuilder >> createNode: aNode [

	| node |
	node := currentNestingDepth = 0
		        ifTrue: [ HyCFGStatementNode new ]
		        ifFalse: [ HyCFGBlockScopeNode new ].

	node astNode: aNode.
	node nestingDepth: currentNestingDepth.
	cfg addNode: node.

	^ node
]

{ #category : 'visiting' }
HyCFGBuilder >> createNode: aNode withEdge: anEdge [

	| node |
	node := currentNestingDepth = 0
		        ifTrue: [ HyCFGStatementNode new ]
		        ifFalse: [ HyCFGBlockScopeNode new ].

	node astNode: aNode.
	node nestingDepth: currentNestingDepth.
	cfg addNode: node.

	currentNode isTerminal ifFalse: [	cfg addEdge: (anEdge from: currentNode to: node) ].
	currentNode := node.
	^ node
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfTrue: aMessageNode [
	"Handle ifTrue single branch conditional"
	"check if condition is a block, if it is empty and if it is have local return"

	| cfNode trueBlock localEntry localExit savedCurrent |
	trueBlock := aMessageNode arguments first.
	trueBlock isBlock ifFalse: [ 1 halt "to be implemented" ]. 
	cfNode := self createControlFlowNode: aMessageNode.
	self connectNode: currentNode to: cfNode.
	localExit := HyCFGLocalExitNode new
		             nestingDepth: currentNestingDepth;
		             yourself.
	cfg addNode: localExit.

	trueBlock statements isEmpty
		ifTrue: [ cfg addEdge: (HyCFGTrueEdge from: cfNode to: localExit) ]
		ifFalse: [ "add local entry"
				localEntry := HyCFGLocalEntryNode new
					              nestingDepth: currentNestingDepth;
					              yourself.
				cfg addNode: localEntry.
				self connectNode: cfNode to: localEntry withEdge: HyCFGTrueEdge.
				currentNode := localEntry.

				savedCurrent := currentNode.
				self withIncrementedNesting: [ trueBlock body ifNotNil: [ :body | self visitSequenceNode: body ] ].
				currentNode isTerminal 
					ifFalse: [ cfg addEdge: (HyCFGSequentialEdge from: currentNode to: localExit) ]
		].

	cfg addEdge: (HyCFGFalseEdge from: cfNode to: localExit).
	currentNode := localExit
]

{ #category : 'initialization' }
HyCFGBuilder >> initialize [ 

	super initialize.
	cfg := HyCFG new.
	currentNestingDepth := 0
]

{ #category : 'visiting' }
HyCFGBuilder >> visitAssignmentNode: aNode [

	self createNode: aNode withEdge: HyCFGSequentialEdge.
	super visitAssignmentNode: aNode
]

{ #category : 'visiting' }
HyCFGBuilder >> visitMessageNode: aNode [

	| selector handler |
	
	selector := aNode selector.
	(self class isRecognizedPattern: selector) 
	ifTrue: [
		handler := self class handlerFor: selector.
		self perform: handler with: aNode ]
	ifFalse: [  
		self createNode: aNode withEdge: HyCFGSequentialEdge.
		super visitMessageNode: aNode 
	].	
	
]

{ #category : 'visiting' }
HyCFGBuilder >> visitReturnNode: aNode [

	| node edge |
	node := self createNode: aNode withEdge: HyCFGSequentialEdge.

	edge := HyCFGReturnEdge from: node to: cfg exitNode.
	cfg addEdge: edge.
	currentNode := cfg exitNode.

	super visitReturnNode: aNode
]

{ #category : 'util' }
HyCFGBuilder >> withIncrementedNesting: aBlock [ 
	"Execute a block with incremented nesting depth"
	
	currentNestingDepth := currentNestingDepth + 1.
	aBlock ensure: [ currentNestingDepth := currentNestingDepth - 1 ]
]
