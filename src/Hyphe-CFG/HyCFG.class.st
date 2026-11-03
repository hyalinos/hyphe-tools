"
A control flow graph (CFG) of one method. It owns the nodes and edges built by HyCFGBuilder, knows its entry and exit nodes and the AST of the method it was built from. Use HyCFGBuilder buildFrom: to create one, #visualize to get a Roassal canvas and #openInspector to open the Spec2 inspector.
"
Class {
	#name : 'HyCFG',
	#superclass : 'Object',
	#instVars : [
		'entryNode',
		'exitNode',
		'nodes',
		'edges',
		'methodNode'
	],
	#category : 'Hyphe-CFG-Structure',
	#package : 'Hyphe-CFG',
	#tag : 'Structure'
}

{ #category : 'initializatio' }
HyCFG >> addEdge: anEdge [
	"Add an edge to the graph and answer it"

	edges add: anEdge.
	^ anEdge
]

{ #category : 'initializatio' }
HyCFG >> addNode: aNode [
	"Add a node to the graph and answer it"

	nodes add: aNode.
	^ aNode
]

{ #category : 'metrics' }
HyCFG >> cyclomaticComplexity [
	"Answer McCabe's cyclomatic complexity of the method: the number of edges minus the number of nodes plus 2, counted on the nodes reachable from the entry node. A straight line gives 1, and every conditional, loop or exception handler adds 1. Answer 0 if there is no entry node."

	| reached edgeCount |
	entryNode ifNil: [ ^ 0 ].
	reached := self reachableNodes.
	edgeCount := edges count: [ :e | (reached identityIncludes: e source) and: [ reached identityIncludes: e target ] ].
	^ edgeCount - reached size + 2
]

{ #category : 'accessin' }
HyCFG >> edges [
	"Answer the edges, in the order they were added"

	^ edges
]

{ #category : 'querying' }
HyCFG >> edgesOfKind: anEdgeClass [
	"Answer the edges that are instances of anEdgeClass or one of its subclasses"

	^ edges select: [ :e | e isKindOf: anEdgeClass ]
]

{ #category : 'accessin' }
HyCFG >> entryNode [
	"Answer the node where the method starts"

	^ entryNode
]

{ #category : 'accessin' }
HyCFG >> entryNode: anObject [
	"Set the node where the method starts"

	entryNode := anObject
]

{ #category : 'accessin' }
HyCFG >> exitNode [
	"Answer the node where the method ends"

	^ exitNode
]

{ #category : 'accessin' }
HyCFG >> exitNode: anObject [
	"Set the node where the method ends"

	exitNode := anObject
]

{ #category : 'querying' }
HyCFG >> incompleteNodes [
	"Answer the nodes whose branches or bodies could not be fully analysed"

	^ nodes reject: [ :n | n isComplete ]
]

{ #category : 'initializatio' }
HyCFG >> initialize [
	"Start with no node and no edge"

	super initialize.
	nodes := OrderedCollection new.
	edges := OrderedCollection new
]

{ #category : 'testing' }
HyCFG >> isComplete [
	"Answer true if the graph is fully known, i.e. no control flow node refers to a block that could not be analysed (a block held in a variable, for example)"

	^ self incompleteNodes isEmpty
]

{ #category : 'querying' }
HyCFG >> maxNestingDepth [
	"Answer the deepest block nesting of any node, 0 if there are no nodes"

	^ nodes inject: 0 into: [ :max :n | max max: n nestingDepth ]
]

{ #category : 'accessing' }
HyCFG >> methodNode [
	"Answer the AST (OCMethodNode) this CFG was built from, nil for a hand-made CFG"

	^ methodNode
]

{ #category : 'accessing' }
HyCFG >> methodNode: anOCMethodNode [
	"Remember the AST this CFG was built from"

	methodNode := anOCMethodNode
]

{ #category : 'metrics' }
HyCFG >> metrics [
	"Answer the metrics of the graph in a dictionary: counts of nodes and edges by kind, deepest nesting, cyclomatic complexity and completeness"

	^ Dictionary new
		  at: #nodes put: nodes size;
		  at: #statements put: (self nodesOfKind: HyCFGStatementNode) size;
		  at: #controlFlow put: (self nodesOfKind: HyCFGControlFlowNode) size;
		  at: #blockScopes put: (self nodesOfKind: HyCFGBlockScopeNode) size;
		  at: #edges put: edges size;
		  at: #sequential put: (self edgesOfKind: HyCFGSequentialEdge) size;
		  at: #conditional put: (self edgesOfKind: HyCFGConditionalEdge) size;
		  at: #loops put: (self edgesOfKind: HyCFGLoopEdge) size;
		  at: #exceptions put: (self edgesOfKind: HyCFGExceptionEdge) size;
		  at: #returns put: (self edgesOfKind: HyCFGReturnEdge) size;
		  at: #maxNestingDepth put: self maxNestingDepth;
		  at: #cyclomaticComplexity put: self cyclomaticComplexity;
		  at: #isComplete put: self isComplete;
		  yourself
]

{ #category : 'accessin' }
HyCFG >> nodes [
	"Answer the nodes, in the order they were added"

	^ nodes
]

{ #category : 'querying' }
HyCFG >> nodesOfKind: aNodeClass [
	"Answer the nodes that are instances of aNodeClass or one of its subclasses"

	^ nodes select: [ :n | n isKindOf: aNodeClass ]
]

{ #category : 'metrics' }
HyCFG >> reachableNodes [
	"Answer the nodes that can be reached from the entry node, entry included. Nodes left unconnected, like the code after a return, are not part of it."

	| reached todo |
	entryNode ifNil: [ ^ OrderedCollection new ].
	reached := OrderedCollection with: entryNode.
	todo := OrderedCollection with: entryNode.
	[ todo isEmpty ] whileFalse: [
			todo removeFirst successors do: [ :next |
					(reached identityIncludes: next) ifFalse: [
							reached add: next.
							todo add: next ] ] ].
	^ reached
]

{ #category : 'removing' }
HyCFG >> removeNode: aNode [
	"Remove a node together with all its edges. The edges are also forgotten by the nodes at their other end, so predecessors and successors of the remaining nodes stay correct."

	nodes remove: aNode.
	aNode incomingEdges copy do: [ :e |
			edges remove: e ifAbsent: [ nil ].
			e source removeOutgoingEdge: e.
			aNode removeIncomingEdge: e ].
	aNode outgoingEdges copy do: [ :e |
			edges remove: e ifAbsent: [ nil ].
			e target removeIncomingEdge: e.
			aNode removeOutgoingEdge: e ]
]

{ #category : 'visualization' }
HyCFG >> visualize [
	"Answer a Roassal canvas drawing this CFG, see HyCFGVisualizer"

	^ (HyCFGVisualizer on: self) visualize
]
