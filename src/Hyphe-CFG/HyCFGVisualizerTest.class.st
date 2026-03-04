Class {
	#name : 'HyCFGVisualizerTest',
	#superclass : 'TestCase',
	#instVars : [
		'cfg',
		'visualizer'
	],
	#category : 'Hyphe-CFG-Tests-Visualization'
}

{ #category : 'running' }
HyCFGVisualizerTest >> setUp [
	super setUp.
	cfg := HyCFG new.
	visualizer := HyCFGVisualizer on: cfg
]

{ #category : 'tests - creation' }
HyCFGVisualizerTest >> testCreation [
	"Test basic visualizer creation"
	
	self assert: visualizer notNil.
	self assert: visualizer cfg equals: cfg
]

{ #category : 'tests - creation' }
HyCFGVisualizerTest >> testClassSideCreation [
	"Test class-side creation method"
	
	| vis |
	vis := HyCFGVisualizer on: cfg.
	
	self assert: vis notNil.
	self assert: vis cfg equals: cfg
]

{ #category : 'tests - simple cfg' }
HyCFGVisualizerTest >> testVisualizeEmptyCFG [
	"Test visualizing CFG with only entry and exit"
	
	| canvas |
	cfg entryNode: HyCFGEntryNode new.
	cfg exitNode: HyCFGExitNode new.
	cfg addNode: cfg entryNode.
	cfg addNode: cfg exitNode.
	
	canvas := visualizer visualize.
	
	self assert: canvas notNil.
	self assert: canvas numberOfShapes >= 2 "At least entry and exit"
]

{ #category : 'tests - simple cfg' }
HyCFGVisualizerTest >> testVisualizeSingleStatement [
	"Test visualizing CFG with one statement"
	
	| canvas entry exit stmt edge1 edge2 |
	
	entry := HyCFGEntryNode new.
	exit := HyCFGExitNode new.
	stmt := HyCFGStatementNode new.
	stmt astNode: (RBVariableNode named: 'x').
	
	cfg entryNode: entry.
	cfg exitNode: exit.
	cfg addNode: entry.
	cfg addNode: exit.
	cfg addNode: stmt.
	
	edge1 := HyCFGSequentialEdge from: entry to: stmt.
	edge2 := HyCFGSequentialEdge from: stmt to: exit.
	cfg addEdge: edge1.
	cfg addEdge: edge2.
	
	canvas := visualizer visualize.
	
	self assert: canvas notNil.
	self assert: canvas numberOfShapes >= 3. "entry, exit, statement"
	self assert: canvas numberOfEdges >= 2
]

{ #category : 'tests - shapes' }
HyCFGVisualizerTest >> testCreateCircleShapeForEntry [
	"Test that entry nodes get circle shapes"
	
	| node shape |
	node := HyCFGEntryNode new.
	shape := visualizer createShapeForNode: node.
	
	self assert: shape notNil.
	self assert: shape model equals: node
]

{ #category : 'tests - shapes' }
HyCFGVisualizerTest >> testCreateCircleShapeForExit [
	"Test that exit nodes get circle shapes"
	
	| node shape |
	node := HyCFGExitNode new.
	shape := visualizer createShapeForNode: node.
	
	self assert: shape notNil.
	self assert: shape model equals: node
]

{ #category : 'tests - shapes' }
HyCFGVisualizerTest >> testCreateRectangleShapeForStatement [
	"Test that statement nodes get rectangle shapes"
	
	| node shape |
	node := HyCFGStatementNode new.
	node astNode: (RBVariableNode named: 'x').
	shape := visualizer createShapeForNode: node.
	
	self assert: shape notNil.
	self assert: shape model equals: node
]

{ #category : 'tests - shapes' }
HyCFGVisualizerTest >> testCreateDiamondShapeForControlFlow [
	"Test that control flow nodes get diamond shapes"
	
	| node shape |
	node := HyCFGControlFlowNode new.
	node astNode: (RBMessageNode receiver: (RBVariableNode named: 'x') selector: #ifTrue:).
	shape := visualizer createShapeForNode: node.
	
	self assert: shape notNil.
	self assert: shape model equals: node
]

{ #category : 'tests - labels' }
HyCFGVisualizerTest >> testGetNodeTypeLabelForAssignment [
	"Test label generation for assignment nodes"
	
	| node label |
	node := HyCFGStatementNode new.
	node astNode: (RBAssignmentNode variable: (RBVariableNode named: 'x') value: (RBLiteralValueNode value: 42)).
	
	label := visualizer getNodeTypeLabel: node.
	
	self assert: label equals: 'Assignment'
]

{ #category : 'tests - labels' }
HyCFGVisualizerTest >> testGetNodeTypeLabelForReturn [
	"Test label generation for return nodes"
	
	| node label |
	node := HyCFGStatementNode new.
	node astNode: (RBReturnNode value: (RBLiteralValueNode value: 42)).
	
	label := visualizer getNodeTypeLabel: node.
	
	self assert: label equals: 'Return'
]

{ #category : 'tests - labels' }
HyCFGVisualizerTest >> testGetNodeTypeLabelForMessage [
	"Test label generation for message nodes"
	
	| node label |
	node := HyCFGStatementNode new.
	node astNode: (RBMessageNode receiver: (RBSelfNode new) selector: #doSomething).
	
	label := visualizer getNodeTypeLabel: node.
	
	self assert: label equals: 'doSomething'
]

{ #category : 'tests - labels' }
HyCFGVisualizerTest >> testGetNodeTypeLabelTruncatesLongSelectors [
	"Test that long selector names are truncated"
	
	| node label |
	node := HyCFGStatementNode new.
	node astNode: (RBMessageNode receiver: (RBSelfNode new) selector: #thisIsAVeryLongSelectorNameThatShouldBeTruncated).
	
	label := visualizer getNodeTypeLabel: node.
	
	self assert: label size <= 15
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testColorForSequentialEdge [
	"Test color selection for sequential edges"
	
	| edge color |
	edge := HyCFGSequentialEdge new.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color black
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testColorForConditionalEdgeTrueBranch [
	"Test color for true branch of conditional"
	
	| edge color |
	edge := HyCFGConditionalEdge new.
	edge isTrueBranch: true.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color green darker
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testColorForConditionalEdgeFalseBranch [
	"Test color for false branch of conditional"
	
	| edge color |
	edge := HyCFGConditionalEdge new.
	edge isTrueBranch: false.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color red darker
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testColorForLoopEdge [
	"Test color for loop edges"
	
	| edge color |
	edge := HyCFGLoopEdge new.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color blue
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testColorForExceptionEdge [
	"Test color for exception edges"
	
	| edge color |
	edge := HyCFGExceptionEdge new.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color orange
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testColorForReturnEdge [
	"Test color for return edges"
	
	| edge color |
	edge := HyCFGReturnEdge new.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color purple
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testWidthForReturnEdge [
	"Test that return edges are wider"
	
	| edge width |
	edge := HyCFGReturnEdge new.
	width := visualizer widthForEdge: edge.
	
	self assert: width equals: 2
]

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testWidthForBackEdge [
	"Test that back edges are wider"
	
	| edge width |
	edge := HyCFGLoopEdge new.
	edge isBackEdge: true.
	width := visualizer widthForEdge: edge.
	
	self assert: width equals: 2
]

{ #category : 'tests - tooltip' }
HyCFGVisualizerTest >> testTooltipForEntryNode [
	"Test tooltip generation for entry node"
	
	| node tooltip |
	node := HyCFGEntryNode new.
	tooltip := visualizer tooltipForNode: node.
	
	self assert: tooltip notNil.
	self assert: (tooltip includesSubstring: 'HyCFGEntryNode')
]

{ #category : 'tests - tooltip' }
HyCFGVisualizerTest >> testTooltipForControlFlowNode [
	"Test tooltip includes completeness info for control flow nodes"
	
	| node tooltip |
	node := HyCFGControlFlowNode new.
	node isComplete: false.
	tooltip := visualizer tooltipForNode: node.
	
	self assert: (tooltip includesSubstring: 'Complete:').
	self assert: (tooltip includesSubstring: 'false')
]

{ #category : 'tests - tooltip' }
HyCFGVisualizerTest >> testTooltipForBlockScopeNode [
	"Test tooltip includes block context info"
	
	| node tooltip |
	node := HyCFGBlockScopeNode new.
	node blockContext: RBBlockNode new.
	tooltip := visualizer tooltipForNode: node.
	
	self assert: (tooltip includesSubstring: 'Block context:')
]

{ #category : 'tests - complex cfg' }
HyCFGVisualizerTest >> testVisualizeConditionalCFG [
	"Test visualizing CFG with conditional branch"
	
	| method cfg canvas |
	method := RBParser parseMethod: 'test
		x > 0 ifTrue: [ y := 1 ]'.
	cfg := HyCFGBuilder buildFrom: method.
	
	visualizer := HyCFGVisualizer on: cfg.
	canvas := visualizer visualize.
	
	self assert: canvas notNil.
	self assert: canvas numberOfShapes >= 3. "entry, exit, control flow"
	self assert: canvas numberOfEdges >= 2
]

{ #category : 'tests - complex cfg' }
HyCFGVisualizerTest >> testVisualizeLoopCFG [
	"Test visualizing CFG with loop"
	
	| method cfg canvas |
	method := RBParser parseMethod: 'test
		[ x > 0 ] whileTrue: [ x := x - 1 ]'.
	cfg := HyCFGBuilder buildFrom: method.
	
	visualizer := HyCFGVisualizer on: cfg.
	canvas := visualizer visualize.
	
	self assert: canvas notNil.
	self assert: canvas numberOfShapes >= 2
]

{ #category : 'tests - api' }
HyCFGVisualizerTest >> testCFGVisualizeDelegation [
	"Test that HyCFG>>visualize delegates to visualizer"
	
	| method cfg canvas |
	method := RBParser parseMethod: 'test
		^ 42'.
	cfg := HyCFGBuilder buildFrom: method.
	
	canvas := cfg visualize.
	
	self assert: canvas notNil
]
