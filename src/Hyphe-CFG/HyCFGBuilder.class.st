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

	(currentNode isTerminal = false and: [ currentNode ~= cfg exitNode ]) ifTrue: [ self connectNode: currentNode to: cfg exitNode ].
	self removeTemporalNodes.

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

{ #category : 'as yet unclassified' }
HyCFGBuilder >> connectSourcesToTargets: n [

	| targetNodes sourceNodes |
	sourceNodes := n incomingEdges collect: [ :e | {e source . e class} ].
	targetNodes := n outgoingEdges collect: [ :e | e target ].
	sourceNodes do: [ :sourceNode | targetNodes do: [ :targetNode | self connectNode: sourceNode first to: targetNode withEdge: sourceNode last ] ]
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
HyCFGBuilder >> handleBranch: cfgBranchClass ofConditional: aBlock from: cfgNode to: localExit [

	|  localEntry savedCurrent |
	aBlock isBlock ifFalse: [ 1 halt "to be implemented" ].

	aBlock statements isEmpty
		ifTrue: [ cfg addEdge: (cfgBranchClass from: cfgNode to: localExit) ]
		ifFalse: [ "add local entry"
				localEntry := HyCFGLocalEntryNode createWithNesting: currentNestingDepth.
				cfg addNode: localEntry.
				self connectNode: cfgNode to: localEntry withEdge: cfgBranchClass.
				currentNode := localEntry.

				savedCurrent := currentNode.
				self withIncrementedNesting: [ aBlock body ifNotNil: [ :body | self visitSequenceNode: body ] ].
				currentNode isTerminal ifFalse: [ cfg addEdge: (HyCFGSequentialEdge from: currentNode to: localExit) ] ]
]

{ #category : 'handlers' }
HyCFGBuilder >> handleFalseTrue: aMessageNode left: left right: right [

	| cfgNode localExit block |
	cfgNode := self createControlFlowNode: aMessageNode.
	self connectNode: currentNode to: cfgNode.
	localExit := HyCFGLocalExitNode createWithNesting: currentNestingDepth.
	cfg addNode: localExit.

	block := aMessageNode arguments first.

	self
		handleBranch: left
		ofConditional: block
		from: cfgNode
		to: localExit.

	block := aMessageNode arguments last.

	self
		handleBranch: right
		ofConditional: block
		from: cfgNode
		to: localExit.
		
	currentNode := localExit
	

]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfEmpty: aMessageNode [

	self handleIfTrue: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfEmptyIfNotEmpty: aMessageNode [

	self handleIfTrueIfFalse: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfFalse: aMessageNode [
	"ifTFalse single branch conditional"

	| cfgNode localExit block |
	cfgNode := self createControlFlowNode: aMessageNode.
	self connectNode: currentNode to: cfgNode.
	localExit := HyCFGLocalExitNode createWithNesting: currentNestingDepth.
	cfg addNode: localExit.

	block := aMessageNode arguments first.
	
	self
		handleBranch: HyCFGFalseEdge
		ofConditional: block
		from: cfgNode
		to: localExit.

	cfg addEdge: (HyCFGTrueEdge from: cfgNode to: localExit).
	currentNode := localExit
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfFalseIfTrue: aMessageNode [

	self handleFalseTrue: aMessageNode left: HyCFGFalseEdge right: HyCFGTrueEdge
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfNil: aMessageNode [
	"same as ifFalse"
	
	self handleIfFalse: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfNilIfNotNil: aMessageNode [
	"same as IfTrueIfFalse"

	self handleIfTrueIfFalse: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfNotEmpty: aMessageNode [

	self handleIfFalse: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfNotEmptyIfEmpty: aMessageNode [

	self handleIfTrueIfFalse: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfNotNil: aMessageNode [
	"same as ifTrue"
	
	self handleIfTrue: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfNotNilIfNil: aMessageNode [
	"same as ifTrueIfFalse"

	self handleIfTrueIfFalse: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfTrue: aMessageNode [
	"ifTrue single branch conditional"

	| block cfgNode localExit |
	cfgNode := self createControlFlowNode: aMessageNode.
	self connectNode: currentNode to: cfgNode.
	localExit := HyCFGLocalExitNode createWithNesting: currentNestingDepth.
	cfg addNode: localExit.

	block := aMessageNode arguments first.

	self
		handleBranch: HyCFGTrueEdge
		ofConditional: block
		from: cfgNode
		to: localExit.

	cfg addEdge: (HyCFGFalseEdge from: cfgNode to: localExit).
	currentNode := localExit
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfTrueIfFalse: aMessageNode [

	self handleFalseTrue: aMessageNode left: HyCFGTrueEdge right: HyCFGFalseEdge
]

{ #category : 'initialization' }
HyCFGBuilder >> initialize [ 

	super initialize.
	cfg := HyCFG new.
	currentNestingDepth := 0
]

{ #category : 'initialization' }
HyCFGBuilder >> removeTemporalNodes [
	"remove local entry and local exit nodes used to ease building of cfg"

	(cfg nodes select: [ :n | n isKindOf: HyCFGTemporalNode ]) do: [ :n |
			self connectSourcesToTargets: n.
			cfg removeNode: n ].
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
