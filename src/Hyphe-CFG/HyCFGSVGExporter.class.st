"
Writes the drawing of a CFG as an SVG document. Roassal in this image has no SVG exporter, so the document is built from the model: node positions come from the layout of a HyCFGVisualizer (visualize must have been sent), shapes, colors and labels are the ones of the visualizer.
"
Class {
	#name : 'HyCFGSVGExporter',
	#superclass : 'Object',
	#instVars : [
		'visualizer',
		'margin'
	],
	#category : 'Hyphe-CFG-Visualization',
	#package : 'Hyphe-CFG',
	#tag : 'Visualization'
}

{ #category : 'instance creation' }
HyCFGSVGExporter class >> on: aVisualizer [
	"Create an exporter for a visualizer that has drawn its CFG (see HyCFGVisualizer>>visualize)"

	^ self new
		  visualizer: aVisualizer;
		  yourself
]

{ #category : 'private' }
HyCFGSVGExporter >> borderPointOf: aRectangle toward: aPoint [
	"Answer where the segment from the center of aRectangle to aPoint leaves the rectangle"

	| center delta scale |
	center := aRectangle center.
	delta := aPoint - center.
	(delta x = 0 and: [ delta y = 0 ]) ifTrue: [ ^ center ].
	scale := aRectangle width / 2 / (delta x abs max: 0.001) min: aRectangle height / 2 / (delta y abs max: 0.001).
	^ center + (delta * scale)
]

{ #category : 'private' }
HyCFGSVGExporter >> bounds [
	"Answer the rectangle that contains all the nodes, plus the margin (and the room of a self loop)"

	| rectangle |
	rectangle := nil.
	visualizer nodeShapes valuesDo: [ :shape |
		rectangle := rectangle ifNil: [ shape encompassingRectangle ] ifNotNil: [ rectangle merge: shape encompassingRectangle ] ].
	rectangle ifNil: [ rectangle := 0 @ 0 corner: 10 @ 10 ].
	^ (rectangle expandBy: margin) merge: (rectangle right + margin + 50 @ rectangle bottom corner: rectangle right @ rectangle top)
]

{ #category : 'private' }
HyCFGSVGExporter >> escape: aString [
	"Escape the characters that are special in XML text and attribute values"

	^ ((aString copyReplaceAll: '&' with: '&amp;') copyReplaceAll: '<' with: '&lt;') copyReplaceAll: '>' with: '&gt;'
]

{ #category : 'exporting' }
HyCFGSVGExporter >> exportTo: aFilename [
	"Write the SVG document to a file (a name or a FileReference, replaced if it exists) and answer the file"

	| file |
	file := aFilename asFileReference.
	file ensureDelete.
	file parent ensureCreateDirectory.
	file binaryWriteStreamDo: [ :stream | stream nextPutAll: self svgString utf8Encoded ].
	^ file
]

{ #category : 'private' }
HyCFGSVGExporter >> hexOf: aColor [
	"Answer the color as #rrggbb"

	^ '#' , aColor asHexString
]

{ #category : 'initialization' }
HyCFGSVGExporter >> initialize [
	"Space kept around the drawing, in pixels"

	super initialize.
	margin := 30
]

{ #category : 'private' }
HyCFGSVGExporter >> markerIdFor: aColor [
	"Answer the id of the arrow head marker of a color"

	^ 'arrow-' , aColor asHexString
]

{ #category : 'exporting' }
HyCFGSVGExporter >> svgString [
	"Answer the SVG document: arrow marker definitions, the edges, then the nodes on top of them"

	| bounds |
	bounds := self bounds.
	^ String streamContents: [ :s |
			  s
				  nextPutAll: '<?xml version="1.0" encoding="UTF-8"?>';
				  lf;
				  nextPutAll: '<svg xmlns="http://www.w3.org/2000/svg" width="';
				  print: bounds width rounded;
				  nextPutAll: '" height="';
				  print: bounds height rounded;
				  nextPutAll: '" viewBox="';
				  print: bounds left rounded;
				  space;
				  print: bounds top rounded;
				  space;
				  print: bounds width rounded;
				  space;
				  print: bounds height rounded;
				  nextPutAll: '" font-family="sans-serif">';
				  lf.
			  self writeDefinitionsOn: s.
			  visualizer cfg edges do: [ :edge | self writeEdge: edge on: s ].
			  visualizer cfg nodes do: [ :node | self writeNode: node on: s ].
			  s
				  nextPutAll: '</svg>';
				  lf ]
]

{ #category : 'accessing' }
HyCFGSVGExporter >> visualizer [
	"Answer the visualizer whose drawing is exported"

	^ visualizer
]

{ #category : 'accessing' }
HyCFGSVGExporter >> visualizer: aVisualizer [
	"Set the visualizer whose drawing is exported"

	visualizer := aVisualizer
]

{ #category : 'private' }
HyCFGSVGExporter >> writeDefinitionsOn: aStream [
	"Define one arrow head per edge color in use. The marker size is in pixels whatever the width of the line it ends."

	| colors |
	colors := (visualizer cfg edges collect: [ :e | visualizer colorForEdge: e ]) asSet.
	aStream
		nextPutAll: '<defs>';
		lf.
	colors do: [ :color |
			aStream
				nextPutAll: '<marker id="';
				nextPutAll: (self markerIdFor: color);
				nextPutAll:
					'" viewBox="0 0 10 10" refX="9" refY="5" markerUnits="userSpaceOnUse" markerWidth="9" markerHeight="9" orient="auto">';
				nextPutAll: '<path d="M0,0 L10,5 L0,10 z" fill="';
				nextPutAll: (self hexOf: color);
				nextPutAll: '"/></marker>';
				lf ].
	aStream
		nextPutAll: '</defs>';
		lf
]

{ #category : 'private' }
HyCFGSVGExporter >> writeEdge: anEdge on: aStream [
	"Write an edge: a straight line from border to border with an arrow head, a curve for a loop on one node, and a T / F label on conditional edges"

	| color source target start end middle |
	color := visualizer colorForEdge: anEdge.
	source := (visualizer nodeShapes at: anEdge source) encompassingRectangle.
	target := (visualizer nodeShapes at: anEdge target) encompassingRectangle.

	anEdge source == anEdge target
		ifTrue: [
				start := source right @ (source center y - 8).
				end := source right @ (source center y + 8).
				middle := source right + 45 @ source center y.
				aStream
					nextPutAll: '<path d="M';
					print: start x rounded;
					nextPut: $,;
					print: start y rounded;
					nextPutAll: ' C';
					print: (start x + 45) rounded;
					nextPut: $,;
					print: (start y - 22) rounded;
					nextPutAll: ' ';
					print: (end x + 45) rounded;
					nextPut: $,;
					print: (end y + 22) rounded;
					nextPutAll: ' ';
					print: end x rounded;
					nextPut: $,;
					print: end y rounded;
					nextPutAll: '" fill="none"' ]
		ifFalse: [
				start := self borderPointOf: source toward: target center.
				end := self borderPointOf: target toward: source center.
				middle := start + end / 2.
				aStream
					nextPutAll: '<line x1="';
					print: start x rounded;
					nextPutAll: '" y1="';
					print: start y rounded;
					nextPutAll: '" x2="';
					print: end x rounded;
					nextPutAll: '" y2="';
					print: end y rounded;
					nextPut: $" ].

	aStream
		nextPutAll: ' stroke="';
		nextPutAll: (self hexOf: color);
		nextPutAll: '" stroke-width="';
		print: (visualizer widthForEdge: anEdge);
		nextPutAll: '" marker-end="url(#';
		nextPutAll: (self markerIdFor: color);
		nextPutAll: ')"'.
	((anEdge isKindOf: HyCFGLoopEdge) and: [ anEdge isBackEdge ]) ifTrue: [ aStream nextPutAll: ' stroke-dasharray="5,5"' ].
	(anEdge isKindOf: HyCFGExceptionEdge) ifTrue: [ aStream nextPutAll: ' stroke-dasharray="3,3"' ].
	aStream
		nextPutAll: '/>';
		lf.

	(anEdge isKindOf: HyCFGConditionalEdge) ifTrue: [
			aStream
				nextPutAll: '<rect x="';
				print: (middle x - 8) rounded;
				nextPutAll: '" y="';
				print: (middle y - 8) rounded;
				nextPutAll: '" width="16" height="16" fill="';
				nextPutAll: (self hexOf: color);
				nextPutAll: '"/>';
				nextPutAll: '<text x="';
				print: middle x rounded;
				nextPutAll: '" y="';
				print: (middle y + 4) rounded;
				nextPutAll: '" font-size="10" font-weight="bold" fill="white" text-anchor="middle">';
				nextPutAll: (anEdge isTrueBranch
						 ifTrue: [ 'T' ]
						 ifFalse: [ 'F' ]);
				nextPutAll: '</text>';
				lf ]
]

{ #category : 'private' }
HyCFGSVGExporter >> writeNode: aNode on: aStream [
	"Write a node: an ellipse for entry and exit, a diamond for control flow nodes, a rectangle for the others, with its label centered"

	| rectangle center fill border |
	rectangle := (visualizer nodeShapes at: aNode) encompassingRectangle.
	center := rectangle center.
	fill := self hexOf: (visualizer fillColorForNode: aNode).
	border := self hexOf: (visualizer borderColorForNode: aNode).

	((aNode isKindOf: HyCFGEntryNode) or: [ aNode isKindOf: HyCFGExitNode ])
		ifTrue: [
				aStream
					nextPutAll: '<ellipse cx="';
					print: center x rounded;
					nextPutAll: '" cy="';
					print: center y rounded;
					nextPutAll: '" rx="';
					print: (rectangle width / 2) rounded;
					nextPutAll: '" ry="';
					print: (rectangle height / 2) rounded;
					nextPutAll: '" fill="';
					nextPutAll: fill;
					nextPutAll: '" stroke="';
					nextPutAll: border;
					nextPutAll: '" stroke-width="2"/>' ]
		ifFalse: [
				(aNode isKindOf: HyCFGControlFlowNode)
					ifTrue: [
							aStream
								nextPutAll: '<polygon points="';
								print: center x rounded;
								nextPut: $,;
								print: rectangle top rounded;
								space;
								print: rectangle right rounded;
								nextPut: $,;
								print: center y rounded;
								space;
								print: center x rounded;
								nextPut: $,;
								print: rectangle bottom rounded;
								space;
								print: rectangle left rounded;
								nextPut: $,;
								print: center y rounded;
								nextPutAll: '" fill="';
								nextPutAll: fill;
								nextPutAll: '" stroke="';
								nextPutAll: border;
								nextPutAll: '" stroke-width="2"/>' ]
					ifFalse: [
							aStream
								nextPutAll: '<rect x="';
								print: rectangle left rounded;
								nextPutAll: '" y="';
								print: rectangle top rounded;
								nextPutAll: '" width="';
								print: rectangle width rounded;
								nextPutAll: '" height="';
								print: rectangle height rounded;
								nextPutAll: '" fill="';
								nextPutAll: fill;
								nextPutAll: '" stroke="';
								nextPutAll: border;
								nextPutAll: '"/>' ] ].

	aStream
		lf;
		nextPutAll: '<text x="';
		print: center x rounded;
		nextPutAll: '" y="';
		print: (center y + 3) rounded;
		nextPutAll: '" font-size="9" text-anchor="middle">';
		nextPutAll: (self escape: (visualizer labelForNode: aNode));
		nextPutAll: '</text>';
		lf
]
