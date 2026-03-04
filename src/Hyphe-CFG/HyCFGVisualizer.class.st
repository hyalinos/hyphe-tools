Class {
	#name : 'HyCFGVisualizer',
	#superclass : 'Object',
	#instVars : [
		'cfg',
		'canvas',
		'nodeShapes',
		'layout'
	],
	#category : 'Hyphe-CFG-Visualization'
}

{ #category : 'instance creation' }
HyCFGVisualizer class >> on: aCFG [
	"Create a visualizer for the given CFG"
	
	^ self new cfg: aCFG
]

{ #category : 'accessing' }
HyCFGVisualizer >> cfg [
	^ cfg
]

{ #category : 'accessing' }
HyCFGVisualizer >> cfg: aCFG [
	cfg := aCFG
]

{ #category : 'initialization' }
HyCFGVisualizer >> initialize [
	super initialize.
	nodeShapes := Dictionary new
]

{ #category : 'visualization' }
HyCFGVisualizer >> visualize [
	"Create and return a Roassal canvas with the CFG visualization"
	
	canvas := RSCanvas new.
	
	"Create shapes for all nodes"
	self createNodeShapes.
	
	"Create edges between nodes"
	self createEdges.
	
	"Apply layout"
	self applyLayout.
	
	"Add interactions"
	self addInteractions.
	
	^ canvas
]

{ #category : 'building' }
HyCFGVisualizer >> createNodeShapes [
	"Create visual shapes for all CFG nodes"
	
	cfg nodes do: [ :node |
		| shape |
		shape := self createShapeForNode: node.
		nodeShapes at: node put: shape.
		canvas add: shape ]
]

{ #category : 'building' }
HyCFGVisualizer >> createShapeForNode: aNode [
	"Create appropriate shape for the node type"
	
	| shape label composite |
	
	"Determine base shape based on node type"
	shape := (aNode isKindOf: HyCFGEntryNode)
		ifTrue: [ self createCircleShape: 'ENTRY' color: Color green ]
		ifFalse: [
			(aNode isKindOf: HyCFGExitNode)
				ifTrue: [ self createCircleShape: 'EXIT' color: Color red ]
				ifFalse: [
					(aNode isKindOf: HyCFGControlFlowNode)
						ifTrue: [ self createDiamondShape: aNode ]
						ifFalse: [ self createRectangleShape: aNode ] ] ].
	
	"Store reference to CFG node in shape"
	shape model: aNode.
	
	^ shape
]

{ #category : 'building - shapes' }
HyCFGVisualizer >> createCircleShape: labelText color: aColor [
	"Create a circle shape for ENTRY/EXIT nodes"
	
	| circle label composite |
	
	circle := RSEllipse new
		size: 60;
		color: aColor lighter;
		border: (RSBorder new color: aColor; width: 2).
	
	label := RSLabel new
		text: labelText;
		fontSize: 10;
		bold.
	
	composite := RSComposite new
		add: circle;
		add: label;
		yourself.
	
	RSLocation new center stick: label on: circle.
	
	^ composite
]

{ #category : 'building - shapes' }
HyCFGVisualizer >> createDiamondShape: aNode [
	"Create a diamond shape for control flow nodes"
	
	| diamond label composite nodeType |
	
	nodeType := self getNodeTypeLabel: aNode.
	
	diamond := RSPolygon new
		points: { 0@(-30). 40@0. 0@30. -40@0 };
		color: Color yellow lighter;
		border: (RSBorder new color: Color orange darker; width: 2).
	
	label := RSLabel new
		text: nodeType;
		fontSize: 9.
	
	composite := RSComposite new
		add: diamond;
		add: label;
		yourself.
	
	RSLocation new center stick: label on: diamond.
	
	^ composite
]

{ #category : 'building - shapes' }
HyCFGVisualizer >> createRectangleShape: aNode [
	"Create a rectangle shape for statement nodes"
	
	| rectangle label composite nodeType |
	
	nodeType := self getNodeTypeLabel: aNode.
	
	rectangle := RSBox new
		width: 100;
		height: 40;
		color: Color blue lighter lighter;
		border: (RSBorder new color: Color blue; width: 1).
	
	label := RSLabel new
		text: nodeType;
		fontSize: 9.
	
	composite := RSComposite new
		add: rectangle;
		add: label;
		yourself.
	
	RSLocation new center stick: label on: rectangle.
	
	^ composite
]

{ #category : 'building - shapes' }
HyCFGVisualizer >> getNodeTypeLabel: aNode [
	"Get a descriptive label for the node type"
	
	| astNode selector |
	
	astNode := aNode astNode.
	astNode ifNil: [ ^ 'Node' ].
	
	astNode isAssignment ifTrue: [ ^ 'Assignment' ].
	astNode isReturn ifTrue: [ ^ 'Return' ].
	astNode isMessage ifTrue: [
		selector := astNode selector.
		^ selector size > 15
			ifTrue: [ (selector first: 12), '...' ]
			ifFalse: [ selector asString ] ].
	astNode isVariable ifTrue: [ ^ 'Variable' ].
	astNode isLiteralNode ifTrue: [ ^ 'Literal' ].
	
	^ 'Statement'
]

{ #category : 'building' }
HyCFGVisualizer >> createEdges [
	"Create visual edges for all CFG edges"
	
	cfg edges do: [ :edge |
		self createEdgeShape: edge ]
]

{ #category : 'building' }
HyCFGVisualizer >> createEdgeShape: anEdge [
	"Create appropriate visual edge based on edge type"
	
	| line sourceShape targetShape |
	
	sourceShape := nodeShapes at: anEdge source.
	targetShape := nodeShapes at: anEdge target.
	
	line := RSLine new
		color: (self colorForEdge: anEdge);
		width: (self widthForEdge: anEdge);
		yourself.
	
	"Apply line style based on edge type"
	(anEdge isKindOf: HyCFGLoopEdge) ifTrue: [
		anEdge isBackEdge ifTrue: [
			line dashArray: #(5 5) ] ].
	
	(anEdge isKindOf: HyCFGExceptionEdge) ifTrue: [
		line dashArray: #(3 3) ].
	
	"Add arrow marker"
	line markerEnd: (RSShapeFactory arrow
		color: (self colorForEdge: anEdge);
		size: 8).
	
	"Add edge label for conditional branches"
	(anEdge isKindOf: HyCFGConditionalEdge) ifTrue: [
		self addLabelToEdge: line text: (anEdge isTrueBranch ifTrue: [ 'T' ] ifFalse: [ 'F' ]) ].
	
	line
		from: sourceShape;
		to: targetShape.
	
	canvas add: line.
	
	^ line
]

{ #category : 'building - edges' }
HyCFGVisualizer >> colorForEdge: anEdge [
	"Return appropriate color for edge type"
	
	(anEdge isKindOf: HyCFGSequentialEdge) ifTrue: [ ^ Color black ].
	(anEdge isKindOf: HyCFGConditionalEdge) ifTrue: [ 
		^ anEdge isTrueBranch 
			ifTrue: [ Color green darker ]
			ifFalse: [ Color red darker ] ].
	(anEdge isKindOf: HyCFGLoopEdge) ifTrue: [ ^ Color blue ].
	(anEdge isKindOf: HyCFGExceptionEdge) ifTrue: [ ^ Color orange ].
	(anEdge isKindOf: HyCFGReturnEdge) ifTrue: [ ^ Color purple ].
	
	^ Color gray
]

{ #category : 'building - edges' }
HyCFGVisualizer >> widthForEdge: anEdge [
	"Return appropriate width for edge type"
	
	(anEdge isKindOf: HyCFGReturnEdge) ifTrue: [ ^ 2 ].
	(anEdge isKindOf: HyCFGLoopEdge) ifTrue: [ 
		^ anEdge isBackEdge ifTrue: [ 2 ] ifFalse: [ 1 ] ].
	
	^ 1
]

{ #category : 'building - edges' }
HyCFGVisualizer >> addLabelToEdge: aLine text: aString [
	"Add a text label to an edge"
	
	| label |
	label := RSLabel new
		text: aString;
		fontSize: 10;
		bold;
		color: Color white;
		yourself.
	
	"Add background for better readability"
	label := RSComposite new
		add: (RSBox new
			size: 16;
			color: (aLine color alpha: 0.8);
			yourself);
		add: label;
		yourself.
	
	RSLocation new center stick: label shapes second on: label shapes first.
	
	canvas add: label.
	
	"Position label at midpoint of edge"
	RSLocation new
		middle;
		stick: label on: aLine.
	
	^ label
]

{ #category : 'layout' }
HyCFGVisualizer >> applyLayout [
	"Apply top-to-bottom hierarchical layout"
	
	| rsLayout |
	
	rsLayout := RSTreeLayout new
		horizontalGap: 60;
		verticalGap: 60;
		yourself.
	
	"Apply layout to all shapes"
	rsLayout on: nodeShapes values.
	
	"Update edge positions"
	canvas lines do: [ :line | line update ].
	
	"Fit canvas to content"
	canvas @ RSCanvasController
]

{ #category : 'interactions' }
HyCFGVisualizer >> addInteractions [
	"Add interactive behaviors to the visualization"
	
	nodeShapes valuesDo: [ :shape |
		"Highlight on hover"
		shape @ RSHighlightable new.
		
		"Show tooltip with details"
		shape @ (RSPopup new text: [ :s | self tooltipForNode: s model ]).
		
		"Allow dragging"
		shape @ RSDraggable new ].
	
	"Add zoom capability"
	canvas @ RSCanvasController
]

{ #category : 'interactions' }
HyCFGVisualizer >> tooltipForNode: aNode [
	"Generate tooltip text for a node"
	
	| stream |
	stream := String streamContents: [ :s |
		s nextPutAll: aNode class name; cr.
		s nextPutAll: 'Nesting depth: '; print: aNode nestingDepth; cr.
		s nextPutAll: 'Predecessors: '; print: aNode predecessors size; cr.
		s nextPutAll: 'Successors: '; print: aNode successors size; cr.
		
		(aNode isKindOf: HyCFGControlFlowNode) ifTrue: [
			s nextPutAll: 'Complete: '; print: aNode isComplete; cr.
			aNode isComplete ifFalse: [
				s nextPutAll: 'Unknown blocks: '; print: aNode unknownBlockReferences size ] ].
		
		(aNode isKindOf: HyCFGBlockScopeNode) ifTrue: [
			s nextPutAll: 'Block context: '; print: aNode blockContext notNil ] ].
	
	^ stream
]

{ #category : 'convenience' }
HyCFGVisualizer >> open [
	"Open the visualization in a new window"
	
	| canvas |
	canvas := self visualize.
	canvas open setLabel: 'CFG Visualization'
]

{ #category : 'exporting' }
HyCFGVisualizer >> exportToPNG: aFilename [
	"Export the visualization to a PNG file"
	
	| canvas |
	canvas := self visualize.
	canvas exportToPng: aFilename
]

{ #category : 'exporting' }
HyCFGVisualizer >> exportToSVG: aFilename [
	"Export the visualization to an SVG file"
	
	| canvas |
	canvas := self visualize.
	canvas exportToSVG: aFilename
]
