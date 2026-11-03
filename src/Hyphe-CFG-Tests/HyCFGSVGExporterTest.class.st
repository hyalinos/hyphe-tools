"
Tests of the SVG export of a CFG drawing: one element per node and edge, escaping, arrow heads, loops.
"
Class {
	#name : 'HyCFGSVGExporterTest',
	#superclass : 'HyCFGAbstractTest',
	#category : 'Hyphe-CFG-Tests-Visualization',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'Visualization'
}

{ #category : 'helpers' }
HyCFGSVGExporterTest >> svgOfBody: aBodyString [
	"Answer the SVG document of the CFG of a method body"

	| visualizer |
	visualizer := HyCFGVisualizer on: (self cfgForBody: aBodyString).
	visualizer visualize.
	^ (HyCFGSVGExporter on: visualizer) svgString
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testBackEdgesAndExceptionEdgesAreDashed [
	"Back edges are dashed 5,5 and exception edges 3,3"

	| svg |
	svg := self svgOfBody: 'items do: [ :e | self use ]'.
	self assert: (svg includesSubstring: 'stroke-dasharray="5,5"').

	svg := self svgOfBody: '[ self risky ] on: Error do: [ :ex | self handle ]'.
	self assert: (svg includesSubstring: 'stroke-dasharray="3,3"')
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testBorderPoint [
	"The border point of a rectangle towards another point is on the segment between their centers; towards its own center it is the center"

	| exporter rectangle |
	exporter := HyCFGSVGExporter new.
	rectangle := 0 @ 0 corner: 100 @ 40.

	self assert: (exporter borderPointOf: rectangle toward: 50 @ 200) equals: 50 @ 40.
	self assert: (exporter borderPointOf: rectangle toward: 500 @ 20) equals: 100 @ 20.
	self assert: (exporter borderPointOf: rectangle toward: rectangle center) equals: rectangle center
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testBranchLabels [
	"Conditional edges are labelled T and F"

	| svg |
	svg := self svgOfBody: 'x ifTrue: [ self a ]'.

	self assert: (svg includesSubstring: '>T</text>').
	self assert: (svg includesSubstring: '>F</text>')
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testDocumentStructure [
	"The document is an svg element with the size of the drawing and its definitions"

	| svg |
	svg := self svgOfBody: 'self foo'.

	self assert: (svg beginsWith: '<?xml version="1.0" encoding="UTF-8"?>').
	self assert: (svg includesSubstring: 'xmlns="http://www.w3.org/2000/svg"').
	self assert: (svg includesSubstring: 'viewBox=').
	self assert: (svg includesSubstring: '<defs>').
	self assert: (svg trimRight endsWith: '</svg>')
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testEmptyCFG [
	"A CFG without node still gives a valid document"

	| visualizer svg |
	visualizer := HyCFGVisualizer on: HyCFG new.
	visualizer visualize.
	svg := (HyCFGSVGExporter on: visualizer) svgString.

	self assert: (svg includesSubstring: '<svg').
	self assert: (self countOf: '<ellipse' in: svg) equals: 0
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testExportToAFile [
	"exportTo: writes the document, replaces an existing file and answers the file"

	| visualizer file text |
	visualizer := HyCFGVisualizer on: (self cfgForBody: 'self foo').
	visualizer visualize.
	file := FileSystem memory root / 'out' / 'cfg.svg'.

	self assert: ((HyCFGSVGExporter on: visualizer) exportTo: file) equals: file.
	self assert: ((HyCFGSVGExporter on: visualizer) exportTo: file) equals: file.

	text := file readStreamDo: [ :stream | stream upToEnd ].
	self assert: (text includesSubstring: '</svg>')
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testOneElementPerNode [
	"An ellipse for entry and exit, a polygon for a control flow node, a rectangle for the other nodes"

	| cfg visualizer svg |
	cfg := self cfgForBody: 'x ifTrue: [ self a ]. self b'.
	visualizer := HyCFGVisualizer on: cfg.
	visualizer visualize.
	svg := (HyCFGSVGExporter on: visualizer) svgString.

	self assert: (self countOf: '<ellipse' in: svg) equals: 2.
	self assert: (self countOf: '<polygon' in: svg) equals: (cfg nodesOfKind: HyCFGControlFlowNode) size.
	"the rectangles of the nodes, and the small rectangles behind the T and F labels"
	self
		assert: (self countOf: '<rect' in: svg)
		equals: (cfg nodesOfKind: HyCFGCodeNode) size - 1 + (cfg edgesOfKind: HyCFGConditionalEdge) size
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testOneLinePerEdge [
	"An edge between two nodes is a line, a loop on one node is a path"

	| cfg visualizer svg |
	cfg := self cfgForBody: 'items do: [ :e | self use ]'.
	visualizer := HyCFGVisualizer on: cfg.
	visualizer visualize.
	svg := (HyCFGSVGExporter on: visualizer) svgString.

	self assert: (self countOf: '<line ' in: svg) equals: cfg edges size.
	self assert: (self countOf: 'marker-end="url(#arrow-' in: svg) equals: cfg edges size
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testSelfLoopIsAPath [
	"A loop from the header to itself is a curve"

	| svg |
	svg := self svgOfBody: '[ self more ] whileTrue: [ ]'.

	self assert: (self countOf: 'fill="none"' in: svg) equals: 1
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testTextIsEscaped [
	"A selector like < is written &lt;, so the document stays valid XML"

	| svg |
	svg := self svgOfBody: 'self x < 3'.

	self assert: (svg includesSubstring: '>&lt;</text>').
	self deny: (svg includesSubstring: '><</text>')
]

{ #category : 'tests' }
HyCFGSVGExporterTest >> testVisualizerAccessor [
	"The exporter knows the visualizer it exports"

	| visualizer |
	visualizer := HyCFGVisualizer on: HyCFG new.

	self assert: (HyCFGSVGExporter on: visualizer) visualizer equals: visualizer
]
