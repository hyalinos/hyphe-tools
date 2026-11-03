"
Draws a CFG with Roassal: entry and exit as circles, control flow nodes as diamonds, other nodes as rectangles, colored edges (black sequential, green true, red false, blue loop, orange exception, purple return) laid out top to bottom. visualize answers the RSCanvas; exportToPNG: and exportToSVG: save the drawing; open shows it in a window.
"
Class {
	#name : 'HyCFGVisualizer',
	#superclass : 'Object',
	#instVars : [
		'cfg',
		'canvas',
		'nodeShapes',
		'layout',
		'edgeShapes'
	],
	#category : 'Hyphe-CFG-Visualization',
	#package : 'Hyphe-CFG',
	#tag : 'Visualization'
}

{ #category : 'instance creation' }
HyCFGVisualizer class >> on: aCFG [
	"Create a visualizer for the given CFG"
	
	^ self new cfg: aCFG
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

{ #category : 'shapes' }
HyCFGVisualizer >> addLabelToEdge: aLine text: aString [
	"Add a text label (T or F) in the middle of an edge"

	| text label |
	text := RSLabel new
		        text: aString;
		        fontSize: 10;
		        bold;
		        color: Color white;
		        yourself.

	label := RSComposite new
		         add: (RSBox new
				          size: 16;
				          color: (aLine color alpha: 0.8);
				          yourself);
		         add: text;
		         yourself.
	RSLocation new center stick: text on: label shapes first.
	label adjustToChildren.

	canvas add: label.
	RSLocation new
		middle;
		stick: label on: aLine.
	^ label
]

{ #category : 'layout' }
HyCFGVisualizer >> applyLayout [
	"Apply a top-to-bottom hierarchical layout, then draw the loops that start and end on the same node"

	RSTreeLayout new
		horizontalGap: 60;
		verticalGap: 60;
		on: nodeShapes values.

	edgeShapes keysAndValuesDo: [ :edge :line |
		edge source == edge target ifTrue: [ self shapeSelfLoop: line of: (nodeShapes at: edge source) ] ].
	canvas lines do: [ :line | line update ]
]

{ #category : 'colors' }
HyCFGVisualizer >> borderColorForNode: aNode [
	"Answer the border color of the shape of a node"

	(aNode isKindOf: HyCFGEntryNode) ifTrue: [ ^ Color green ].
	(aNode isKindOf: HyCFGExitNode) ifTrue: [ ^ Color red ].
	(aNode isKindOf: HyCFGControlFlowNode) ifTrue: [ ^ Color orange darker ].
	^ Color blue
]

{ #category : 'drawing' }
HyCFGVisualizer >> buildCanvas [
	"Create the canvas with the shapes and the layout, but without interactions: this is what gets exported to a file, interactions would add widgets to the picture"

	canvas := RSCanvas new.
	nodeShapes := Dictionary new.
	edgeShapes := Dictionary new.

	self createNodeShapes.
	self createEdges.
	self applyLayout.
	^ canvas
]

{ #category : 'accessing' }
HyCFGVisualizer >> canvas [
	"Answer the Roassal canvas built by the last #visualize, nil before"

	^ canvas
]

{ #category : 'accessin' }
HyCFGVisualizer >> cfg [
	"Answer the CFG that is drawn"

	^ cfg
]

{ #category : 'accessin' }
HyCFGVisualizer >> cfg: aCFG [
	"Set the CFG to draw"

	cfg := aCFG
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

{ #category : 'shapes' }
HyCFGVisualizer >> createCircleShape: labelText color: aColor [
	"Create a circle shape for ENTRY/EXIT nodes"

	| circle label composite |
	circle := RSEllipse new
		          size: 60;
		          color: aColor lighter;
		          border: (RSBorder new
				           color: aColor;
				           width: 2);
		          yourself.

	label := RSLabel new
		         text: labelText;
		         fontSize: 10;
		         bold;
		         yourself.

	composite := RSComposite new
		             add: circle;
		             add: label;
		             yourself.

	RSLocation new center stick: label on: circle.

	"a composite does not size itself on its own"
	composite adjustToChildren.
	^ composite
]

{ #category : 'shapes' }
HyCFGVisualizer >> createDiamondShape: aNode [
	"Create a diamond shape for control flow nodes"

	| diamond label composite |
	diamond := RSPolygon new
		           points: {
				           (0 @ -30).
				           (40 @ 0).
				           (0 @ 30).
				           (-40 @ 0) };
		           color: (self fillColorForNode: aNode);
		           border: (RSBorder new
				            color: (self borderColorForNode: aNode);
				            width: 2);
		           yourself.

	label := RSLabel new
		         text: (self getNodeTypeLabel: aNode);
		         fontSize: 9;
		         yourself.

	composite := RSComposite new
		             add: diamond;
		             add: label;
		             yourself.

	RSLocation new center stick: label on: diamond.
	composite adjustToChildren.
	^ composite
]

{ #category : 'shapes' }
HyCFGVisualizer >> createEdgeShape: anEdge [
	"Create the line of an edge. Its color, width and dash depend on the kind of edge. A loop that goes from a node to itself is drawn as a bezier curve once the layout is applied (see #applyLayout)."

	| line sourceShape targetShape |
	sourceShape := nodeShapes at: anEdge source.
	targetShape := nodeShapes at: anEdge target.

	line := anEdge source == anEdge target
		        ifTrue: [ RSBezier new ]
		        ifFalse: [ RSLine new ].
	line
		color: (self colorForEdge: anEdge);
		width: (self widthForEdge: anEdge).

	"back edges and exception edges are dashed"
	((anEdge isKindOf: HyCFGLoopEdge) and: [ anEdge isBackEdge ]) ifTrue: [ line dashArray: #( 5 5 ) ].
	(anEdge isKindOf: HyCFGExceptionEdge) ifTrue: [ line dashArray: #( 3 3 ) ].

	line markerEnd: (RSShapeFactory arrow
			 color: (self colorForEdge: anEdge);
			 size: 8;
			 yourself).

	line
		from: sourceShape;
		to: targetShape.
	line attachPoint: RSBorderAttachPoint new.
	canvas add: line.

	"label the branches of conditionals"
	(anEdge isKindOf: HyCFGConditionalEdge) ifTrue: [
			self addLabelToEdge: line text: (anEdge isTrueBranch
					 ifTrue: [ 'T' ]
					 ifFalse: [ 'F' ]) ].

	edgeShapes at: anEdge put: line.
	^ line
]

{ #category : 'building' }
HyCFGVisualizer >> createEdges [
	"Create visual edges for all CFG edges"
	
	cfg edges do: [ :edge |
		self createEdgeShape: edge ]
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

{ #category : 'shapes' }
HyCFGVisualizer >> createRectangleShape: aNode [
	"Create a rectangle shape for statement and block scope nodes"

	| rectangle label composite |
	rectangle := RSBox new
		             width: 100;
		             height: 40;
		             color: (self fillColorForNode: aNode);
		             border: (RSBorder new
				              color: (self borderColorForNode: aNode);
				              width: 1);
		             yourself.

	label := RSLabel new
		         text: (self getNodeTypeLabel: aNode);
		         fontSize: 9;
		         yourself.

	composite := RSComposite new
		             add: rectangle;
		             add: label;
		             yourself.

	RSLocation new center stick: label on: rectangle.
	composite adjustToChildren.
	^ composite
]

{ #category : 'shapes' }
HyCFGVisualizer >> createShapeForNode: aNode [
	"Create the shape for a node according to its kind and remember the node in the shape (shape model)"

	| shape |
	shape := (aNode isKindOf: HyCFGEntryNode)
		         ifTrue: [ self createCircleShape: 'ENTRY' color: Color green ]
		         ifFalse: [
				         (aNode isKindOf: HyCFGExitNode)
					         ifTrue: [ self createCircleShape: 'EXIT' color: Color red ]
					         ifFalse: [
							         (aNode isKindOf: HyCFGControlFlowNode)
								         ifTrue: [ self createDiamondShape: aNode ]
								         ifFalse: [ self createRectangleShape: aNode ] ] ].

	shape model: aNode.
	^ shape
]

{ #category : 'exporting' }
HyCFGVisualizer >> exportToPNG: aFilename [
	"Save the drawing as a PNG image. The argument is a file name or a FileReference; the file is replaced if it exists. Answer the file."

	| aCanvas morph form file |
	aCanvas := self buildCanvas.
	morph := aCanvas createMorph.
	morph extent: (aCanvas encompassingRectangle extent + 40) rounded.
	form := morph imageForm.

	file := aFilename asFileReference.
	file ensureDelete.
	file parent ensureCreateDirectory.
	file binaryWriteStreamDo: [ :stream | PNGReadWriter putForm: form onStream: stream ].
	^ file
]

{ #category : 'exporting' }
HyCFGVisualizer >> exportToSVG: aFilename [
	"Save the drawing as an SVG document. The argument is a file name or a FileReference; the file is replaced if it exists. Answer the file."

	self buildCanvas.
	^ (HyCFGSVGExporter on: self) exportTo: aFilename
]

{ #category : 'colors' }
HyCFGVisualizer >> fillColorForNode: aNode [
	"Answer the fill color of the shape of a node: entry green, exit red, control flow yellow, other nodes blue"

	(aNode isKindOf: HyCFGEntryNode) ifTrue: [ ^ Color green lighter ].
	(aNode isKindOf: HyCFGExitNode) ifTrue: [ ^ Color red lighter ].
	(aNode isKindOf: HyCFGControlFlowNode) ifTrue: [ ^ Color yellow lighter ].
	^ Color blue lighter lighter
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

{ #category : 'initialization' }
HyCFGVisualizer >> initialize [
	"A visualizer starts without shapes; visualize creates them"

	super initialize.
	nodeShapes := Dictionary new.
	edgeShapes := Dictionary new
]

{ #category : 'labels' }
HyCFGVisualizer >> labelForNode: aNode [
	"Answer the text written in the shape of a node"

	(aNode isKindOf: HyCFGEntryNode) ifTrue: [ ^ 'ENTRY' ].
	(aNode isKindOf: HyCFGExitNode) ifTrue: [ ^ 'EXIT' ].
	^ self getNodeTypeLabel: aNode
]

{ #category : 'accessing' }
HyCFGVisualizer >> nodeShapes [
	"Answer the dictionary CFG node -> Roassal shape, filled by #visualize"

	^ nodeShapes
]

{ #category : 'convenience' }
HyCFGVisualizer >> open [
	"Open the drawing in a window and answer the window"

	| window |
	window := self visualize open.
	window setLabel: 'CFG Visualization'.
	^ window
]

{ #category : 'layout' }
HyCFGVisualizer >> shapeSelfLoop: aBezier of: aNodeShape [
	"Draw a loop on the right side of the node: the curve leaves and comes back to the node"

	| center half |
	center := aNodeShape position.
	half := aNodeShape width / 2.
	aBezier controlPoints: {
			(center + (half @ -8)).
			(center + (half + 45 @ -30)).
			(center + (half + 45 @ 30)).
			(center + (half @ 8)) }
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

{ #category : 'drawing' }
HyCFGVisualizer >> visualize [
	"Create and answer a Roassal canvas with the drawing of the CFG: a shape per node, a line per edge, laid out top to bottom, with interactions (hover, tooltip, drag, zoom). Can be sent several times, each time starts over."

	self buildCanvas.
	self addInteractions.
	^ canvas
]

{ #category : 'building - edges' }
HyCFGVisualizer >> widthForEdge: anEdge [
	"Return appropriate width for edge type"
	
	(anEdge isKindOf: HyCFGReturnEdge) ifTrue: [ ^ 2 ].
	(anEdge isKindOf: HyCFGLoopEdge) ifTrue: [ 
		^ anEdge isBackEdge ifTrue: [ 2 ] ifFalse: [ 1 ] ].
	
	^ 1
]
