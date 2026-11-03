"
Builds the CFG of a method. It is a visitor of the AST of the method (OCProgramNodeVisitor): each statement becomes a node linked to the previous one, and the messages that control the flow (ifTrue:, whileTrue:, do:, on:do: ... see patternRegistry) become control flow nodes with their branches. Use HyCFGBuilder buildFrom: aMethodNode. New control flow messages are added with registerPattern:handler:.
"
Class {
	#name : 'HyCFGBuilder',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'cfg',
		'currentNode',
		'currentNestingDepth',
		'methodNode',
		'currentBlock'
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
	"Build and answer the CFG of a method (OCMethodNode or method)"

	^ self new buildFrom: aOCMethodNode
]

{ #category : 'class initialization' }
HyCFGBuilder class >> handlerFor: selector [
	"Answer the selector of the handler of a control flow selector, nil if it is not one"

	^ self patternRegistry at: selector ifAbsent: [ nil ]
]

{ #category : 'class initialization' }
HyCFGBuilder class >> initialize [
	"Class initialization: fill the registry of control flow selectors"

	self initializePatternRegistry
]

{ #category : 'pattern registry' }
HyCFGBuilder class >> initializePatternRegistry [
	"Set up the default pattern registry: for each recognized selector, the selector of the instance method that builds its part of the CFG. Handlers receive the message node."

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
	self registerPattern: #whileTrue handler: #handleWhileTrueNoArg:.
	self registerPattern: #whileFalse handler: #handleWhileFalseNoArg:.
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
	"Answer true if the selector controls the flow, i.e. has a handler"

	^ self patternRegistry includesKey: selector
]

{ #category : 'class initialization' }
HyCFGBuilder class >> patternRegistry [
	"Answer the registry control flow selector -> handler selector, filled on first use"

	^ PatternRegistry ifNil: [
			  self initializePatternRegistry.
			  PatternRegistry ]
]

{ #category : 'class initialization' }
HyCFGBuilder class >> registerPattern: selector handler: handlerSelector [
	"Register a control flow selector and the selector of the instance method that handles its message node"

	PatternRegistry at: selector put: handlerSelector
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> addLoopBody: bodyArgument to: header edge: continueEdgeClass [
	"Build the body of a loop. header -(continueEdgeClass)-> body statements -(back edge)-> header. A body that is empty or is not a literal block (then the header is flagged incomplete) is just a back edge from the header to itself."

	| localEntry |
	(bodyArgument isBlock and: [ bodyArgument statements notEmpty ]) ifFalse: [
			bodyArgument isBlock ifFalse: [ header addUnknownBlockReference: bodyArgument ].
			cfg addEdge: (HyCFGLoopEdge backEdgeFrom: header to: header).
			^ self ].

	localEntry := self createLocalEntry.
	self connectNode: header to: localEntry withEdge: continueEdgeClass.
	currentNode := localEntry.

	self visitBlockBody: bodyArgument.
	currentNode isTerminal ifFalse: [ cfg addEdge: (HyCFGLoopEdge backEdgeFrom: currentNode to: header) ]
]

{ #category : 'building' }
HyCFGBuilder >> buildFrom: aMethodNodeOrMethod [
	"Build the CFG of a method. The argument is an OCMethodNode (for example OCParser parseMethod: ...), or a method (CompiledMethod, or the ReflectiveMethod of a method that has MetaLinks installed, like when measuring coverage), whose AST is used."

	methodNode := (aMethodNodeOrMethod isKindOf: OCProgramNode)
		              ifTrue: [ aMethodNodeOrMethod ]
		              ifFalse: [ aMethodNodeOrMethod ast ].
	cfg methodNode: methodNode.
	cfg entryNode: HyCFGEntryNode new.
	cfg exitNode: HyCFGExitNode new.
	cfg addNode: cfg entryNode.
	cfg addNode: cfg exitNode.
	currentNode := cfg entryNode.
	methodNode body ifNotNil: [ :body | self visitSequenceNode: body ].

	"fall off the end of the method: whatever is reached last goes to the exit"
	(currentNode isTerminal = false and: [ currentNode ~= cfg exitNode ]) ifTrue: [ self connectNode: currentNode to: cfg exitNode ].
	self removeTemporalNodes.

	^ cfg
]

{ #category : 'private' }
HyCFGBuilder >> connectCurrentTo: aNode [
	"Link the node being built after the current one with a sequential edge, unless the current node ends the flow (after a return nothing follows)"

	currentNode isTerminal ifFalse: [ self connectNode: currentNode to: aNode ]
]

{ #category : 'initializatio' }
HyCFGBuilder >> connectNode: sourceNode to: targetNode [
	"Add a sequential edge between two nodes"

	| edge |
	edge := HyCFGSequentialEdge from: sourceNode to: targetNode.
	cfg addEdge: edge
]

{ #category : 'initializatio' }
HyCFGBuilder >> connectNode: sourceNode to: targetNode withEdge: edgeClass [
	"Add an edge of the given class between two nodes"

	| edge |
	edge := edgeClass from: sourceNode to: targetNode.
	cfg addEdge: edge
]

{ #category : 'private' }
HyCFGBuilder >> connectSourcesToTargets: aTemporalNode [
	"Short-circuit a temporal node: connect each of its predecessors to each of its successors"

	aTemporalNode incomingEdges copy do: [ :incoming |
		aTemporalNode outgoingEdges copy do: [ :outgoing | cfg addEdge: (self edgeBridging: incoming with: outgoing) ] ]
]

{ #category : 'visitin' }
HyCFGBuilder >> createControlFlowNode: aMessageNode [
	"Create the node of a control flow message (ifTrue:, whileTrue:, do: ...) at the current nesting depth"

	^ cfg addNode: (HyCFGControlFlowNode new
			   astNode: aMessageNode;
			   nestingDepth: currentNestingDepth;
			   yourself)
]

{ #category : 'private' }
HyCFGBuilder >> createLocalEntry [
	"Create the temporal node that opens the code of a branch or of a loop body"

	^ cfg addNode: (HyCFGLocalEntryNode createWithNesting: currentNestingDepth)
]

{ #category : 'private' }
HyCFGBuilder >> createLocalExit [
	"Create the temporal node where the branches of a control flow structure meet again"

	^ cfg addNode: (HyCFGLocalExitNode createWithNesting: currentNestingDepth)
]

{ #category : 'private' }
HyCFGBuilder >> createNode: aNode [
	"Create the node of a statement. Statements of the method body are statement nodes, the ones inside blocks are block scope nodes that remember their block."

	| node |
	currentNestingDepth = 0
		ifTrue: [ node := HyCFGStatementNode new ]
		ifFalse: [
				node := HyCFGBlockScopeNode new.
				node blockContext: currentBlock ].

	node astNode: aNode.
	node nestingDepth: currentNestingDepth.
	cfg addNode: node.

	^ node
]

{ #category : 'private' }
HyCFGBuilder >> createNode: aNode withEdge: anEdge [
	"Create the node of a statement and link it after the current node, which it becomes"

	| node |
	node := self createNode: aNode.
	currentNode isTerminal ifFalse: [ cfg addEdge: (anEdge from: currentNode to: node) ].
	currentNode := node.
	^ node
]

{ #category : 'private' }
HyCFGBuilder >> edgeBridging: incomingEdge with: outgoingEdge [
	"Answer the edge that replaces two consecutive edges around a removed temporal node. A loop, exception or return edge is kept because it says more than a sequential one, otherwise the incoming edge (e.g. a true or false branch) is kept."

	| kept |
	kept := (outgoingEdge isMemberOf: HyCFGSequentialEdge)
		        ifTrue: [ incomingEdge ]
		        ifFalse: [ outgoingEdge ].
	^ kept copyFrom: incomingEdge source to: outgoingEdge target
]

{ #category : 'handlers' }
HyCFGBuilder >> handleBranch: cfgBranchClass ofConditional: aBlock from: cfgNode to: localExit [
	"Build one branch of a control flow node: cfgNode -> (the statements of aBlock) -> localExit. The first edge is an instance of cfgBranchClass. An empty branch goes straight to localExit. If aBlock is not a literal block (a variable, a message...) its code is unknown, so the node is flagged as incomplete."

	| localEntry |
	aBlock isBlock ifFalse: [
			cfgNode addUnknownBlockReference: aBlock.
			cfg addEdge: (cfgBranchClass from: cfgNode to: localExit).
			^ self ].

	aBlock statements isEmpty ifTrue: [
			cfg addEdge: (cfgBranchClass from: cfgNode to: localExit).
			^ self ].

	localEntry := self createLocalEntry.
	self connectNode: cfgNode to: localEntry withEdge: cfgBranchClass.
	currentNode := localEntry.

	self visitBlockBody: aBlock.
	currentNode isTerminal ifFalse: [ cfg addEdge: (HyCFGSequentialEdge from: currentNode to: localExit) ]
]

{ #category : 'handlers - switch' }
HyCFGBuilder >> handleCaseOf: aMessageNode [
	"x caseOf: { ... }"

	self handleCases: aMessageNode otherwise: nil
]

{ #category : 'handlers - switch' }
HyCFGBuilder >> handleCaseOfOtherwise: aMessageNode [
	"x caseOf: { ... } otherwise: [ ... ]"

	self handleCases: aMessageNode otherwise: aMessageNode arguments last
]

{ #category : 'handlers - switch' }
HyCFGBuilder >> handleCases: aMessageNode otherwise: anOtherwiseBlock [
	"x caseOf: { [ a ] -> [ ... ]. [ b ] -> [ ... ] } (otherwise: [ ... ]). Each case is a true branch of the control flow node, the otherwise block (or nothing) is the false branch. A cases argument that is not a literal { } array of associations is flagged as unknown code."

	| header localExit cases |
	header := self startControlFlow: aMessageNode.
	localExit := self createLocalExit.

	cases := aMessageNode arguments first.
	cases isDynamicArray
		ifFalse: [ header addUnknownBlockReference: cases ]
		ifTrue: [
				cases statements do: [ :association |
						(association isMessage and: [ association selector = #'->' ])
							ifTrue: [
									self
										handleBranch: HyCFGTrueEdge
										ofConditional: association arguments first
										from: header
										to: localExit ]
							ifFalse: [ header addUnknownBlockReference: association ] ] ].

	anOtherwiseBlock ifNil: [ cfg addEdge: (HyCFGFalseEdge from: header to: localExit) ] ifNotNil: [
			self
				handleBranch: HyCFGFalseEdge
				ofConditional: anOtherwiseBlock
				from: header
				to: localExit ].
	currentNode := localExit
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleCollect: aMessageNode [
	"collection collect: [ :each | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleDetect: aMessageNode [
	"collection detect: [ :each | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleDetectIfNone: aMessageNode [
	"collection detect: [ :each | body ] ifNone: [ none ]. The loop body is the first block; when the iteration ends without a match (false edge) the ifNone block is run."

	| header localExit |
	header := self startControlFlow: aMessageNode.
	localExit := self createLocalExit.

	self addLoopBody: aMessageNode arguments first to: header edge: HyCFGTrueEdge.
	self
		handleBranch: HyCFGFalseEdge
		ofConditional: aMessageNode arguments last
		from: header
		to: localExit.
	currentNode := localExit
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleDo: aMessageNode [
	"collection do: [ :each | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - exceptions' }
HyCFGBuilder >> handleEnsure: aMessageNode [
	"[ protected ] ensure: [ always run ]. The protected code is followed, in sequence, by the ensure block."

	| header bodyExit ensureBlock |
	header := self startControlFlow: aMessageNode.
	bodyExit := self createLocalExit.

	self
		handleBranch: HyCFGSequentialEdge
		ofConditional: aMessageNode receiver
		from: header
		to: bodyExit.
	currentNode := bodyExit.

	ensureBlock := aMessageNode arguments first.
	ensureBlock isBlock
		ifTrue: [ self visitBlockBody: ensureBlock ]
		ifFalse: [ header addUnknownBlockReference: ensureBlock ]
]

{ #category : 'handlers' }
HyCFGBuilder >> handleFalseTrue: aMessageNode left: left right: right [
	"Two branch conditional: the first argument is the code of the left edge, the second one of the right edge"

	| cfgNode localExit |
	cfgNode := self startControlFlow: aMessageNode.
	localExit := self createLocalExit.

	self
		handleBranch: left
		ofConditional: aMessageNode arguments first
		from: cfgNode
		to: localExit.

	self
		handleBranch: right
		ofConditional: aMessageNode arguments last
		from: cfgNode
		to: localExit.

	currentNode := localExit
]

{ #category : 'handlers - exceptions' }
HyCFGBuilder >> handleIfCurtailed: aMessageNode [
	"[ protected ] ifCurtailed: [ run only if the protected block is left abnormally ]"

	self handleProtected: aMessageNode handler: aMessageNode arguments first
]

{ #category : 'handler' }
HyCFGBuilder >> handleIfEmpty: aMessageNode [
	"ifEmpty: is handled like ifTrue:, the block runs when the collection is empty"

	self handleIfTrue: aMessageNode
]

{ #category : 'handler' }
HyCFGBuilder >> handleIfEmptyIfNotEmpty: aMessageNode [
	"ifEmpty:ifNotEmpty: is handled like ifTrue:ifFalse:"

	self handleIfTrueIfFalse: aMessageNode
]

{ #category : 'handlers' }
HyCFGBuilder >> handleIfFalse: aMessageNode [
	"ifFalse: single branch conditional"

	| cfgNode localExit |
	cfgNode := self startControlFlow: aMessageNode.
	localExit := self createLocalExit.

	self
		handleBranch: HyCFGFalseEdge
		ofConditional: aMessageNode arguments first
		from: cfgNode
		to: localExit.

	cfg addEdge: (HyCFGTrueEdge from: cfgNode to: localExit).
	currentNode := localExit
]

{ #category : 'handler' }
HyCFGBuilder >> handleIfFalseIfTrue: aMessageNode [
	"ifFalse:ifTrue: two branch conditional, the first block is the false branch"

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

{ #category : 'handler' }
HyCFGBuilder >> handleIfNotEmpty: aMessageNode [
	"ifNotEmpty: is handled like ifFalse:"

	self handleIfFalse: aMessageNode
]

{ #category : 'handler' }
HyCFGBuilder >> handleIfNotEmptyIfEmpty: aMessageNode [
	"ifNotEmpty:ifEmpty: is handled like ifTrue:ifFalse:"

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
	"ifTrue: single branch conditional"

	| cfgNode localExit |
	cfgNode := self startControlFlow: aMessageNode.
	localExit := self createLocalExit.

	self
		handleBranch: HyCFGTrueEdge
		ofConditional: aMessageNode arguments first
		from: cfgNode
		to: localExit.

	cfg addEdge: (HyCFGFalseEdge from: cfgNode to: localExit).
	currentNode := localExit
]

{ #category : 'handler' }
HyCFGBuilder >> handleIfTrueIfFalse: aMessageNode [
	"ifTrue:ifFalse: two branch conditional"

	self handleFalseTrue: aMessageNode left: HyCFGTrueEdge right: HyCFGFalseEdge
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleInjectInto: aMessageNode [
	"collection inject: start into: [ :acc :each | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleIteration: aMessageNode [
	"A loop over a collection or a number: the block is the last argument. The true edge enters the body (there is something left to iterate), the false edge leaves the loop."

	self
		handleLoop: aMessageNode
		body: aMessageNode arguments last
		continueEdge: HyCFGTrueEdge
		exitEdge: HyCFGFalseEdge
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleLoop: aMessageNode body: bodyArgument continueEdge: continueEdgeClass exitEdge: exitEdgeClass [
	"Build a loop: the header (a control flow node) goes through the body with continueEdgeClass, the body goes back to the header, and the loop is left with exitEdgeClass."

	| header localExit |
	header := self startControlFlow: aMessageNode.
	localExit := self createLocalExit.

	self addLoopBody: bodyArgument to: header edge: continueEdgeClass.
	cfg addEdge: (exitEdgeClass from: header to: localExit).
	currentNode := localExit
]

{ #category : 'handlers - exceptions' }
HyCFGBuilder >> handleOnDo: aMessageNode [
	"[ protected ] on: ExceptionClass do: [ :ex | handler ]"

	self handleProtected: aMessageNode handler: aMessageNode arguments last
]

{ #category : 'handlers - exceptions' }
HyCFGBuilder >> handleProtected: aMessageNode handler: aHandlerBlock [
	"A protected block and its handler. The receiver is the protected code, run in sequence from the node; the handler is reached through an exception edge. Both continue after the message."

	| header localExit |
	header := self startControlFlow: aMessageNode.
	localExit := self createLocalExit.

	self
		handleBranch: HyCFGSequentialEdge
		ofConditional: aMessageNode receiver
		from: header
		to: localExit.
	self
		handleBranch: HyCFGExceptionEdge
		ofConditional: aHandlerBlock
		from: header
		to: localExit.
	currentNode := localExit
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleReject: aMessageNode [
	"collection reject: [ :each | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleSelect: aMessageNode [
	"collection select: [ :each | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleTimesRepeat: aMessageNode [
	"n timesRepeat: [ body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleToByDo: aMessageNode [
	"start to: stop by: step do: [ :i | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleToDo: aMessageNode [
	"start to: stop do: [ :i | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleWhileFalse: aMessageNode [
	"[ condition ] whileFalse: [ body ]"

	self
		handleLoop: aMessageNode
		body: aMessageNode arguments first
		continueEdge: HyCFGFalseEdge
		exitEdge: HyCFGTrueEdge
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleWhileFalseNoArg: aMessageNode [
	"[ body and condition ] whileFalse: the receiver block is the body"

	self
		handleLoop: aMessageNode
		body: aMessageNode receiver
		continueEdge: HyCFGFalseEdge
		exitEdge: HyCFGTrueEdge
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleWhileTrue: aMessageNode [
	"[ condition ] whileTrue: [ body ]"

	self
		handleLoop: aMessageNode
		body: aMessageNode arguments first
		continueEdge: HyCFGTrueEdge
		exitEdge: HyCFGFalseEdge
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleWhileTrueNoArg: aMessageNode [
	"[ body and condition ] whileTrue: the receiver block is the body"

	self
		handleLoop: aMessageNode
		body: aMessageNode receiver
		continueEdge: HyCFGTrueEdge
		exitEdge: HyCFGFalseEdge
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleWithDo: aMessageNode [
	"collection with: other do: [ :a :b | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'handlers - loops' }
HyCFGBuilder >> handleWithIndexDo: aMessageNode [
	"collection withIndexDo: [ :each :index | body ]"

	self handleIteration: aMessageNode
]

{ #category : 'initializatio' }
HyCFGBuilder >> initialize [
	"Start with an empty CFG, at nesting depth 0"

	super initialize.
	cfg := HyCFG new.
	currentNestingDepth := 0
]

{ #category : 'private' }
HyCFGBuilder >> removeTemporalNodes [
	"Remove the local entry and local exit nodes used to ease the building of the CFG, they are not part of the final graph"

	(cfg nodes select: [ :n | n isKindOf: HyCFGTemporalNode ]) do: [ :n |
			self connectSourcesToTargets: n.
			cfg removeNode: n ]
]

{ #category : 'private' }
HyCFGBuilder >> startControlFlow: aMessageNode [
	"Create the node standing for a control flow message (ifTrue:, do:, on:do: ...) and link it after the current node"

	| controlFlowNode |
	controlFlowNode := self createControlFlowNode: aMessageNode.
	self connectCurrentTo: controlFlowNode.
	^ controlFlowNode
]

{ #category : 'visitin' }
HyCFGBuilder >> visitAssignmentNode: aNode [
	"An assignment is a node, then its value is analysed (its sends are nodes too)"

	self createNode: aNode withEdge: HyCFGSequentialEdge.
	super visitAssignmentNode: aNode
]

{ #category : 'visiting' }
HyCFGBuilder >> visitBlockBody: aBlockNode [
	"Analyse the statements of a block, one nesting level deeper than the code around it"

	| outerBlock |
	outerBlock := currentBlock.
	currentBlock := aBlockNode.
	[ self withIncrementedNesting: [ aBlockNode body ifNotNil: [ :body | self visitSequenceNode: body ] ] ] ensure: [
		currentBlock := outerBlock ]
]

{ #category : 'visiting' }
HyCFGBuilder >> visitBlockNode: aBlockNode [
	"A block in any other position (argument of an unknown message, for instance) is analysed in place"

	self visitBlockBody: aBlockNode
]

{ #category : 'visitin' }
HyCFGBuilder >> visitMessageNode: aNode [
	"A message that controls the flow (see the pattern registry) is handled by its handler, any other message is a statement node and its receiver and arguments are analysed"

	| selector handler |
	selector := aNode selector.
	(self class isRecognizedPattern: selector)
		ifTrue: [
				handler := self class handlerFor: selector.
				self perform: handler with: aNode ]
		ifFalse: [
				self createNode: aNode withEdge: HyCFGSequentialEdge.
				super visitMessageNode: aNode ]
]

{ #category : 'visiting' }
HyCFGBuilder >> visitReturnNode: aNode [
	"The returned expression is evaluated first (its sends become nodes), then the return itself, which leaves for the exit node. Nothing follows a return."

	| node |
	super visitReturnNode: aNode.
	node := self createNode: aNode withEdge: HyCFGSequentialEdge.
	cfg addEdge: (HyCFGReturnEdge from: node to: cfg exitNode).
	currentNode := cfg exitNode
]

{ #category : 'util' }
HyCFGBuilder >> withIncrementedNesting: aBlock [ 
	"Execute a block with incremented nesting depth"
	
	currentNestingDepth := currentNestingDepth + 1.
	aBlock ensure: [ currentNestingDepth := currentNestingDepth - 1 ]
]
