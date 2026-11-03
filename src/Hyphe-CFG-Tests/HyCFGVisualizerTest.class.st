"
Tests of HyCFGVisualizer: colors, shapes, labels, tooltips, drawing of real CFGs, PNG and SVG export.
"
Class {
	#name : 'HyCFGVisualizerTest',
	#superclass : 'TestCase',
	#instVars : [
		'cfg',
		'visualizer'
	],
	#category : 'Hyphe-CFG-Tests-Visualization',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Visualization'
}

{ #category : 'runnin' }
HyCFGVisualizerTest >> setUp [
	"A visualizer on an empty CFG"

	super setUp.
	cfg := HyCFG new.
	visualizer := HyCFGVisualizer on: cfg
]

{ #category : 'helpers' }
HyCFGVisualizerTest >> simpleCFG [
	"A hand-made CFG: entry -> statement -> exit"

	| entry exit statement |
	cfg := HyCFG new.
	entry := HyCFGEntryNode new.
	exit := HyCFGExitNode new.
	statement := HyCFGStatementNode new.
	statement astNode: (OCParser parseExpression: 'x').

	cfg entryNode: entry.
	cfg exitNode: exit.
	cfg addNode: entry.
	cfg addNode: exit.
	cfg addNode: statement.
	cfg addEdge: (HyCFGSequentialEdge from: entry to: statement).
	cfg addEdge: (HyCFGSequentialEdge from: statement to: exit).
	^ cfg
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

{ #category : 'tests' }
HyCFGVisualizerTest >> testCanvasIsKnownAfterVisualize [
	"The visualizer keeps the canvas it built, nil before"

	cfg := self simpleCFG.
	visualizer := HyCFGVisualizer on: cfg.

	self assert: visualizer canvas isNil.
	self assert: visualizer visualize == visualizer canvas
]

{ #category : 'tests - creation' }
HyCFGVisualizerTest >> testClassSideCreation [
	"Test class-side creation method"
	
	| vis |
	vis := HyCFGVisualizer on: cfg.
	
	self assert: vis notNil.
	self assert: vis cfg equals: cfg
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
HyCFGVisualizerTest >> testColorForConditionalEdgeTrueBranch [
	"Test color for true branch of conditional"
	
	| edge color |
	edge := HyCFGConditionalEdge new.
	edge isTrueBranch: true.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color green darker
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
HyCFGVisualizerTest >> testColorForLoopEdge [
	"Test color for loop edges"
	
	| edge color |
	edge := HyCFGLoopEdge new.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color blue
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
HyCFGVisualizerTest >> testColorForSequentialEdge [
	"Test color selection for sequential edges"
	
	| edge color |
	edge := HyCFGSequentialEdge new.
	color := visualizer colorForEdge: edge.
	
	self assert: color equals: Color black
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testColorOfAnUnknownKindOfEdge [
	"A plain edge is gray"

	self assert: (visualizer colorForEdge: HyCFGEdge new) equals: Color gray
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testColorsOfNodes [
	"Each kind of node has its own colors, shared by the Roassal drawing and the SVG export"

	self assert: (visualizer borderColorForNode: HyCFGEntryNode new) equals: Color green.
	self assert: (visualizer borderColorForNode: HyCFGExitNode new) equals: Color red.
	self assert: (visualizer borderColorForNode: HyCFGControlFlowNode new) equals: Color orange darker.
	self assert: (visualizer borderColorForNode: HyCFGStatementNode new) equals: Color blue.
	self assert: (visualizer fillColorForNode: HyCFGEntryNode new) equals: Color green lighter.
	self assert: (visualizer fillColorForNode: HyCFGBlockScopeNode new) equals: Color blue lighter lighter
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

{ #category : 'tests' }
HyCFGVisualizerTest >> testCreateDiamondShapeForControlFlow [
	"Test that control flow nodes get diamond shapes"

	| node shape |
	node := HyCFGControlFlowNode new.
	node astNode: (OCParser parseExpression: 'x ifTrue: [ 1 ]').
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

{ #category : 'tests - creation' }
HyCFGVisualizerTest >> testCreation [
	"Test basic visualizer creation"
	
	self assert: visualizer notNil.
	self assert: visualizer cfg equals: cfg
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testExportToPNG [
	"The drawing is saved as a PNG file, replacing an existing file"

	| file bytes |
	file := FileSystem memory root / 'cfg.png'.
	file ensureCreateFile.
	cfg := self simpleCFG.
	visualizer := HyCFGVisualizer on: cfg.

	visualizer exportToPNG: file.

	bytes := file binaryReadStreamDo: [ :stream | stream next: 8 ].
	self assert: bytes equals: #( 137 80 78 71 13 10 26 10 ) asByteArray
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testExportToSVG [
	"The drawing is saved as an SVG document"

	| file text |
	file := FileSystem memory root / 'cfg.svg'.
	cfg := self simpleCFG.
	visualizer := HyCFGVisualizer on: cfg.

	visualizer exportToSVG: file.

	text := file readStreamDo: [ :stream | stream upToEnd ].
	self assert: (text beginsWith: '<?xml').
	self assert: (text includesSubstring: '<svg').
	self assert: (text includesSubstring: '</svg>')
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

{ #category : 'tests' }
HyCFGVisualizerTest >> testGetNodeTypeLabelForMessage [
	"Test label generation for message nodes"

	| node label |
	node := HyCFGStatementNode new.
	node astNode: (OCParser parseExpression: 'self doSomething').

	label := visualizer getNodeTypeLabel: node.

	self assert: label equals: 'doSomething'
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testGetNodeTypeLabelForOtherNodes [
	"Variables, literals and any other expression have a generic label"

	{
		('x' -> 'Variable').
		('42' -> 'Literal').
		('x foo; bar' -> 'Statement').
		('[ 1 ]' -> 'Statement') } do: [ :association |
			| node |
			node := HyCFGStatementNode new.
			node astNode: (OCParser parseExpression: association key).
			self assert: (visualizer getNodeTypeLabel: node) = association value description: association key ]
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

{ #category : 'tests' }
HyCFGVisualizerTest >> testGetNodeTypeLabelTruncatesLongSelectors [
	"Test that long selector names are truncated"

	| node label |
	node := HyCFGStatementNode new.
	node astNode: (OCParser parseExpression: 'self thisIsAVeryLongSelectorNameThatShouldBeTruncated').

	label := visualizer getNodeTypeLabel: node.

	self assert: label size <= 15
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testGetNodeTypeLabelWithoutAST [
	"A node that has no AST node is labelled Node"

	self assert: (visualizer getNodeTypeLabel: HyCFGStatementNode new) equals: 'Node'
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testLabelForEntryAndExit [
	"Entry and exit nodes are labelled ENTRY and EXIT"

	self assert: (visualizer labelForNode: HyCFGEntryNode new) equals: 'ENTRY'.
	self assert: (visualizer labelForNode: HyCFGExitNode new) equals: 'EXIT'
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testNodesAreLaidOutTopToBottom [
	"The layout puts a node under its predecessor"

	| builtCFG statement |
	builtCFG := HyCFGBuilder buildFrom: (OCParser parseMethod: 'test self foo. self bar').
	visualizer := HyCFGVisualizer on: builtCFG.
	visualizer visualize.

	statement := builtCFG nodes detect: [ :n | (n isKindOf: HyCFGCodeNode) and: [ n astNode selector = #foo ] ].

	self assert: (visualizer nodeShapes at: statement) position y > (visualizer nodeShapes at: builtCFG entryNode) position y.
	self assert: (visualizer nodeShapes at: builtCFG exitNode) position y > (visualizer nodeShapes at: statement) position y
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testOpenShowsAWindow [
	"open shows the drawing in a window"

	| window |
	cfg := self simpleCFG.
	visualizer := HyCFGVisualizer on: cfg.

	window := visualizer open.

	[ self assert: window notNil ] ensure: [ window delete ]
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testShapesHaveTheSizeOfTheirContent [
	"A composite shape is not sized automatically: the shapes must be adjusted, or every node is a 10x10 dot"

	| node |
	node := HyCFGStatementNode new.
	node astNode: (OCParser parseExpression: 'x foo').

	self assert: (visualizer createShapeForNode: node) width >= 100.
	self assert: (visualizer createShapeForNode: HyCFGEntryNode new) width >= 60.
	self assert: (visualizer createShapeForNode: HyCFGControlFlowNode new) width >= 80
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
HyCFGVisualizerTest >> testTooltipForEntryNode [
	"Test tooltip generation for entry node"
	
	| node tooltip |
	node := HyCFGEntryNode new.
	tooltip := visualizer tooltipForNode: node.
	
	self assert: tooltip notNil.
	self assert: (tooltip includesSubstring: 'HyCFGEntryNode')
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testTooltipOfAnUnfinishedControlFlowNode [
	"The tooltip counts the blocks that could not be analysed"

	| node |
	node := HyCFGControlFlowNode new.
	node addUnknownBlockReference: (OCParser parseExpression: 'aBlock').

	self assert: ((visualizer tooltipForNode: node) includesSubstring: 'Unknown blocks: 1')
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

{ #category : 'tests' }
HyCFGVisualizerTest >> testVisualizeCreatesOneShapePerNodeAndEdge [
	"Every node has a shape, and every edge a line"

	| method builtCFG canvas |
	method := OCParser parseMethod: 'test items do: [ :e | e ifTrue: [ self use ] ]. ^ 1'.
	builtCFG := HyCFGBuilder buildFrom: method.
	visualizer := HyCFGVisualizer on: builtCFG.

	canvas := visualizer visualize.

	self assert: visualizer nodeShapes size equals: builtCFG nodes size.
	self assert: canvas lines size >= builtCFG edges size.
	self assert: (visualizer nodeShapes keys allSatisfy: [ :node | builtCFG nodes includes: node ])
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

{ #category : 'tests' }
HyCFGVisualizerTest >> testVisualizeSelfLoop [
	"A loop with an empty body goes from the header to itself, drawn as a curve"

	| builtCFG canvas |
	builtCFG := HyCFGBuilder buildFrom: (OCParser parseMethod: 'test [ self more ] whileTrue: [ ]').
	visualizer := HyCFGVisualizer on: builtCFG.

	canvas := visualizer visualize.

	self assert: canvas notNil.
	self assert: (canvas lines anySatisfy: [ :line | line isKindOf: RSBezier ])
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

{ #category : 'tests' }
HyCFGVisualizerTest >> testVisualizeTwiceStartsOver [
	"visualize can be sent again, it builds a new canvas with as many shapes"

	| first second |
	cfg := self simpleCFG.
	visualizer := HyCFGVisualizer on: cfg.

	first := visualizer visualize.
	second := visualizer visualize.

	self deny: first == second.
	self assert: second numberOfShapes equals: first numberOfShapes.
	self assert: visualizer nodeShapes size equals: cfg nodes size
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

{ #category : 'tests - edges' }
HyCFGVisualizerTest >> testWidthForReturnEdge [
	"Test that return edges are wider"
	
	| edge width |
	edge := HyCFGReturnEdge new.
	width := visualizer widthForEdge: edge.
	
	self assert: width equals: 2
]

{ #category : 'tests' }
HyCFGVisualizerTest >> testWidthOfEdges [
	"Return edges and back edges are wider than the others"

	self assert: (visualizer widthForEdge: HyCFGReturnEdge new) equals: 2.
	self
		assert: (visualizer widthForEdge: (HyCFGLoopEdge new
					  isBackEdge: true;
					  yourself))
		equals: 2.
	self assert: (visualizer widthForEdge: HyCFGLoopEdge new) equals: 1.
	self assert: (visualizer widthForEdge: HyCFGTrueEdge new) equals: 1.
	self assert: (visualizer widthForEdge: HyCFGSequentialEdge new) equals: 1
]
