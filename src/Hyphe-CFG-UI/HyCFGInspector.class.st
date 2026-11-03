"
Spec2 application to inspect a CFG. On the left a control panel (filters, export) and a metrics panel; on the right a notebook with the Roassal drawing of the CFG and the source of the method. Open it with: aCFG openInspector, or HyCFGInspector openOn: aCFG. Changing a filter redraws the CFG without the hidden kinds of nodes (a hidden node is bridged, so the rest stays connected) and recomputes the metrics of what is shown.
"
Class {
	#name : 'HyCFGInspector',
	#superclass : 'SpPresenter',
	#instVars : [
		'cfg',
		'visualizationPresenter',
		'controlPanel',
		'metricsPanel',
		'sourceTextPanel',
		'notebook',
		'uiManager'
	],
	#category : 'Hyphe-CFG-UI',
	#package : 'Hyphe-CFG-UI'
}

{ #category : 'instance creation' }
HyCFGInspector class >> openOn: aCFG [
	"Open an inspector window on a CFG and answer the inspector"

	| inspector |
	inspector := self new.
	inspector cfg: aCFG.
	inspector open.
	^ inspector
]

{ #category : 'specs' }
HyCFGInspector class >> title [
	"Title of the inspector window"

	^ 'CFG Inspector'
]

{ #category : 'filtering' }
HyCFGInspector >> bridgesFrom: anEdge visible: visibleNodes [
	"The edge anEdge leads to a hidden node. Follow the edges through hidden nodes and answer, for each visible node reached, an association node -> edge, where the edge stands for the whole path: the first edge of the path, unless a later one is not sequential (a loop, an exception, a return...), which says more and is kept, like the builder does when it removes a temporal node."

	| found visited toVisit |
	found := OrderedCollection new.
	visited := Set new.
	toVisit := OrderedCollection with: anEdge target -> anEdge.
	[ toVisit isEmpty ] whileFalse: [
			| current |
			current := toVisit removeFirst.
			(visited includes: current key) ifFalse: [
					visited add: current key.
					(visibleNodes includes: current key)
						ifTrue: [ found add: current ]
						ifFalse: [
								current key outgoingEdges do: [ :next |
										toVisit add: next target -> ((next isMemberOf: HyCFGSequentialEdge)
												 ifTrue: [ current value ]
												 ifFalse: [ next ]) ] ] ] ].
	^ found
]

{ #category : 'accessing' }
HyCFGInspector >> cfg [
	"Answer the inspected CFG"

	^ cfg
]

{ #category : 'accessing' }
HyCFGInspector >> cfg: aCFG [
	"Inspect another CFG: redraw everything"

	cfg := aCFG.
	self refresh
]

{ #category : 'accessing' }
HyCFGInspector >> controlPanel [
	"Answer the panel with the filters and the export buttons"

	^ controlPanel
]

{ #category : 'filtering' }
HyCFGInspector >> createFilteredCFG [
	"Answer a new CFG with the nodes that pass the filters, nil if there is no CFG. The nodes and the edges between visible nodes are the ones of the inspected CFG, which is not modified. An edge towards a hidden node is replaced by edges to the visible nodes behind it (see #bridgesFrom:visible:), so the drawing stays connected."

	| filtered visibleNodes bridged |
	cfg ifNil: [ ^ nil ].

	filtered := HyCFG new.
	filtered methodNode: cfg methodNode.
	visibleNodes := cfg nodes select: [ :node | self shouldIncludeNode: node ].
	visibleNodes do: [ :node | filtered addNode: node ].
	(visibleNodes includes: cfg entryNode) ifTrue: [ filtered entryNode: cfg entryNode ].
	(visibleNodes includes: cfg exitNode) ifTrue: [ filtered exitNode: cfg exitNode ].

	"bridged remembers the bridges already drawn, as { from. to. kind of edge }, to not draw the same one twice"
	bridged := Set new.
	visibleNodes do: [ :node |
			node outgoingEdges do: [ :edge |
					(visibleNodes includes: edge target)
						ifTrue: [ filtered addEdge: edge ]
						ifFalse: [
								(self bridgesFrom: edge visible: visibleNodes) do: [ :bridge |
										| key |
										key := {
											       node.
											       bridge key.
											       bridge value class.
											       ((bridge value isKindOf: HyCFGLoopEdge) and: [ bridge value isBackEdge ]) }.
										(bridged includes: key) ifFalse: [
												bridged add: key.
												filtered addEdge: (bridge value detachedCopyFrom: node to: bridge key) ] ] ] ] ].
	^ filtered
]

{ #category : 'visualization' }
HyCFGInspector >> createFilteredVisualization [
	"Answer the Roassal canvas with the drawing of the CFG as filtered, an empty canvas if there is no CFG"

	^ cfg ifNil: [ RSCanvas new ] ifNotNil: [ (HyCFGVisualizer on: self createFilteredCFG) visualize ]
]

{ #category : 'layout' }
HyCFGInspector >> defaultLayout [
	"Controls above metrics on the left, the notebook on the right"

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 250;
		  add: (SpBoxLayout newTopToBottom
				   add: controlPanel height: 300;
				   add: metricsPanel;
				   yourself);
		  add: notebook;
		  yourself
]

{ #category : 'exporting' }
HyCFGInspector >> exportAskingFor: aPrompt default: aFilename with: anExportBlock [
	"Ask for a file name, do nothing if the user cancels, otherwise evaluate the export block with the name and tell the user"

	| name |
	name := self requestFilename: aPrompt default: aFilename.
	(name isNil or: [ name asString isEmpty ]) ifTrue: [ ^ self ].
	anExportBlock value: name.
	self inform: 'Exported to ' , name asString
]

{ #category : 'exporting' }
HyCFGInspector >> exportToPNG [
	"Ask the user for a file name and export to PNG (the action of the Export PNG button)"

	self exportAskingFor: 'PNG filename:' default: 'cfg.png' with: [ :name | self exportToPNG: name ]
]

{ #category : 'exporting' }
HyCFGInspector >> exportToPNG: aFilename [
	"Save the drawing, as filtered, to a PNG file. A relative name is relative to the working directory. Answer the file."

	^ (HyCFGVisualizer on: self createFilteredCFG) exportToPNG: aFilename
]

{ #category : 'exporting' }
HyCFGInspector >> exportToSVG [
	"Ask the user for a file name and export to SVG (the action of the Export SVG button)"

	self exportAskingFor: 'SVG filename:' default: 'cfg.svg' with: [ :name | self exportToSVG: name ]
]

{ #category : 'exporting' }
HyCFGInspector >> exportToSVG: aFilename [
	"Save the drawing, as filtered, to an SVG file. A relative name is relative to the working directory. Answer the file."

	^ (HyCFGVisualizer on: self createFilteredCFG) exportToSVG: aFilename
]

{ #category : 'initialization' }
HyCFGInspector >> initializePresenters [
	"Create the panels and the notebook, and connect the control panel to the inspector"

	controlPanel := self instantiate: HyCFGControlPanel.
	metricsPanel := self instantiate: HyCFGMetricsPanel.
	sourceTextPanel := self newText
		                   editable: false;
		                   yourself.
	visualizationPresenter := self newMorph.

	controlPanel whenFiltersChangedDo: [ self refresh ].
	controlPanel whenExportPNGDo: [ self exportToPNG ].
	controlPanel whenExportSVGDo: [ self exportToSVG ].

	notebook := self newNotebook.
	notebook
		addPage: (SpNotebookPage title: 'Visualization' icon: (self iconNamed: #smallObjects) provider: [ visualizationPresenter ]);
		addPage: (SpNotebookPage title: 'Source' icon: (self iconNamed: #smallObjects) provider: [ sourceTextPanel ])
]

{ #category : 'initialization' }
HyCFGInspector >> initializeWindow: aWindowPresenter [
	"Title and size of the window"

	aWindowPresenter
		title: self class title;
		initialExtent: 1200 @ 800
]

{ #category : 'actions' }
HyCFGInspector >> methodNode [
	"Answer the AST of the method of the CFG: the one remembered by the CFG, or else the one of any of its AST nodes. Nil if unknown (a CFG made by hand)."

	cfg ifNil: [ ^ nil ].
	cfg methodNode ifNotNil: [ :method | ^ method ].
	cfg nodes do: [ :node |
		(node isKindOf: HyCFGCodeNode) ifTrue: [ node astNode ifNotNil: [ :ast | ast methodNode ifNotNil: [ :method | ^ method ] ] ] ].
	^ nil
]

{ #category : 'accessing' }
HyCFGInspector >> metricsPanel [
	"Answer the panel with the metrics"

	^ metricsPanel
]

{ #category : 'accessing' }
HyCFGInspector >> notebook [
	"Answer the notebook with the pages Visualization and Source"

	^ notebook
]

{ #category : 'actions' }
HyCFGInspector >> refresh [
	"Redraw the CFG, recompute the metrics and show the source again"

	metricsPanel cfg: self createFilteredCFG.
	self updateSourcePanel.
	self refreshVisualization
]

{ #category : 'actions' }
HyCFGInspector >> refreshVisualization [
	"Replace the drawing shown on the Visualization page"

	visualizationPresenter morph: (cfg ifNil: [ Morph new ] ifNotNil: [ self createFilteredVisualization createMorph ])
]

{ #category : 'exporting' }
HyCFGInspector >> requestFilename: aPrompt default: aFilename [
	"Ask the user for a file name, answer nil if cancelled. Separate method so tests can avoid the dialog."

	^ self uiManager request: aPrompt initialAnswer: aFilename
]

{ #category : 'filtering' }
HyCFGInspector >> shouldIncludeNode: aNode [
	"Answer true if the filters of the control panel let a node be shown"

	controlPanel ifNil: [ ^ true ].

	(aNode isKindOf: HyCFGEntryNode) ifTrue: [ ^ controlPanel showEntry ].
	(aNode isKindOf: HyCFGExitNode) ifTrue: [ ^ controlPanel showExit ].
	(aNode isKindOf: HyCFGControlFlowNode) ifTrue: [ ^ controlPanel showControlFlow ].
	(aNode isKindOf: HyCFGStatementNode) ifTrue: [ ^ controlPanel showStatements ].
	(aNode isKindOf: HyCFGBlockScopeNode) ifTrue: [ ^ controlPanel showBlocks ].
	^ true
]

{ #category : 'accessing' }
HyCFGInspector >> sourceTextPanel [
	"Answer the text presenter showing the source of the method"

	^ sourceTextPanel
]

{ #category : 'accessing' }
HyCFGInspector >> uiManager [
	"Answer the UI manager used to ask the user for a file name: the default one unless another was set"

	^ uiManager ifNil: [ UIManager default ]
]

{ #category : 'accessing' }
HyCFGInspector >> uiManager: aUIManager [
	"Set the UI manager that asks for file names. Tests give one that answers without a dialog; the global UI manager must not be replaced, doing so switches off the display of the image while it is replaced."

	uiManager := aUIManager
]

{ #category : 'actions' }
HyCFGInspector >> updateSourcePanel [
	"Show the source of the method on the Source page"

	sourceTextPanel text: (self methodNode ifNil: [ 'No source available' ] ifNotNil: [ :method | method formattedCode ])
]

{ #category : 'accessing' }
HyCFGInspector >> visualizationPresenter [
	"Answer the presenter that holds the Roassal drawing"

	^ visualizationPresenter
]
