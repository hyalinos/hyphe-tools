"
Tests of the CFG inspector: panels, filtering of the CFG, metrics and source, drawing, export, opening windows.
"
Class {
	#name : 'HyCFGInspectorTest',
	#superclass : 'HyCFGAbstractTest',
	#instVars : [
		'cfg',
		'inspector'
	],
	#category : 'Hyphe-CFG-Tests-UI',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'UI'
}

{ #category : 'helpers' }
HyCFGInspectorTest >> inspect: aCFG [
	"Set a CFG in the inspector"

	cfg := aCFG.
	inspector cfg: aCFG
]

{ #category : 'running' }
HyCFGInspectorTest >> setUp [
	"An inspector on a hand-made CFG, not opened"

	super setUp.
	cfg := self simpleCFG.
	inspector := HyCFGInspectorStub new.
	inspector cfg: cfg
]

{ #category : 'running' }
HyCFGInspectorTest >> tearDown [
	"Close the window of the inspector if a test opened it"

	inspector ifNotNil: [ inspector window ifNotNil: [ :window | window close ] ].
	super tearDown
]

{ #category : 'tests' }
HyCFGInspectorTest >> testBridgingDoesNotDuplicateEdges [
	"Two hidden nodes in a row give one edge, not two"

	| filtered |
	self inspect: (self cfgForBody: 'self a. self b. self c').
	inspector controlPanel showStatementsCheckbox state: false.

	filtered := inspector createFilteredCFG.

	self assert: filtered nodes size equals: 2.
	self assert: filtered edges size equals: 1
]

{ #category : 'tests' }
HyCFGInspectorTest >> testBridgingKeepsTheKindOfEdge [
	"Hiding the body of a loop: the path through the body ends with the back edge, so the header gets a self loop that is a back edge; and the path to the code after the loop is still a false edge"

	| filtered loops |
	self inspect: (self cfgForBody: 'items do: [ :e | self use ]. self after').
	inspector controlPanel showBlocksCheckbox state: false.
	inspector controlPanel showStatementsCheckbox state: false.

	filtered := inspector createFilteredCFG.
	loops := filtered edgesOfKind: HyCFGLoopEdge.

	self assert: loops size equals: 1.
	self assert: loops first isBackEdge.
	self assert: loops first source == loops first target.
	self assert: (filtered edgesOfKind: HyCFGFalseEdge) size equals: 1.
	self assert: (filtered edgesOfKind: HyCFGFalseEdge) first target equals: filtered exitNode.
	self assert: filtered edges size equals: 3
]

{ #category : 'tests' }
HyCFGInspectorTest >> testCancellingTheExportDoesNothing [
	"No file name (cancelled dialog, or empty name): nothing is exported, nobody is told"

	inspector answerFilename: nil.
	inspector exportToPNG.
	inspector answerFilename: ''.
	inspector exportToSVG.

	self assert: inspector informed isEmpty
]

{ #category : 'tests' }
HyCFGInspectorTest >> testChangingTheCFGUpdatesThePanels [
	"cfg: refreshes the metrics, the source and the drawing"

	self inspect: (self cfgForBody: 'self foo. self bar').

	self assert: (inspector metricsPanel metricsText text includesSubstring: 'Statements: 2').
	self assert: (inspector sourceTextPanel text includesSubstring: 'self bar').
	self assert: (inspector visualizationPresenter morph isKindOf: RSAthensMorph)
]

{ #category : 'tests' }
HyCFGInspectorTest >> testCreation [
	"The inspector remembers its CFG"

	self assert: inspector cfg equals: cfg.
	self assert: HyCFGInspector title equals: 'CFG Inspector'
]

{ #category : 'tests' }
HyCFGInspectorTest >> testDefaultUIManager [
	"Without another one the inspector uses the global UI manager"

	self assert: HyCFGInspector new uiManager equals: UIManager default
]

{ #category : 'tests' }
HyCFGInspectorTest >> testExportButtonAsksForAFilename [
	"The Export PNG button asks for a file name (cfg.png by default), exports and tells the user"

	| file |
	file := FileSystem memory root / 'asked.png'.
	inspector answerFilename: file.

	inspector controlPanel exportPNG.

	self assert: inspector requests asArray equals: { { 'PNG filename:'. 'cfg.png' } }.
	self assert: file exists.
	self assert: inspector informed size equals: 1
]

{ #category : 'tests' }
HyCFGInspectorTest >> testExportSVGButtonAsksForAFilename [
	"The Export SVG button does the same for SVG"

	| file |
	file := FileSystem memory root / 'asked.svg'.
	inspector answerFilename: file.

	inspector controlPanel exportSVG.

	self assert: inspector requests asArray equals: { { 'SVG filename:'. 'cfg.svg' } }.
	self assert: file exists
]

{ #category : 'tests' }
HyCFGInspectorTest >> testExportToPNG [
	"exportToPNG: saves the drawing as a PNG file"

	| file |
	file := FileSystem memory root / 'cfg.png'.

	self assert: (inspector exportToPNG: file) equals: file.

	self assert: (file binaryReadStreamDo: [ :stream | stream next: 4 ]) equals: #( 137 80 78 71 ) asByteArray
]

{ #category : 'tests' }
HyCFGInspectorTest >> testExportToSVGHasTheFilteredNodes [
	"exportToSVG: saves what is shown: with the statements hidden there is no statement rectangle"

	| file all filtered |
	file := FileSystem memory root / 'cfg.svg'.
	inspector exportToSVG: file.
	all := file readStreamDo: [ :stream | stream upToEnd ].

	inspector controlPanel showStatementsCheckbox state: false.
	inspector exportToSVG: file.
	filtered := file readStreamDo: [ :stream | stream upToEnd ].

	self assert: (self countOf: '<rect' in: all) equals: 1.
	self assert: (self countOf: '<rect' in: filtered) equals: 0.
	self assert: (self countOf: '<ellipse' in: filtered) equals: 2
]

{ #category : 'tests' }
HyCFGInspectorTest >> testFilterChangeRedrawsTheVisualization [
	"Changing a filter puts a new drawing on the Visualization page"

	| before |
	before := inspector visualizationPresenter morph.

	inspector controlPanel showStatementsCheckbox state: false.

	self deny: inspector visualizationPresenter morph == before
]

{ #category : 'tests' }
HyCFGInspectorTest >> testFilteredCFGWithAllFiltersOnHasEverything [
	"Nothing hidden: same nodes, same edges"

	| filtered |
	filtered := inspector createFilteredCFG.

	self assert: filtered nodes asArray equals: cfg nodes asArray.
	self assert: filtered edges asArray equals: cfg edges asArray.
	self assert: filtered entryNode equals: cfg entryNode.
	self assert: filtered exitNode equals: cfg exitNode
]

{ #category : 'tests' }
HyCFGInspectorTest >> testFilteredCFGWithoutACFG [
	"No CFG, no filtered CFG"

	inspector cfg: nil.

	self assert: inspector createFilteredCFG isNil
]

{ #category : 'tests' }
HyCFGInspectorTest >> testFilteredVisualization [
	"The drawing has the shapes of the nodes that are shown"

	| canvas |
	canvas := inspector createFilteredVisualization.
	self assert: (canvas isKindOf: RSCanvas).
	self assert: canvas numberOfShapes >= 3.

	inspector controlPanel showStatementsCheckbox state: false.
	self assert: inspector createFilteredVisualization nodes size < canvas nodes size
]

{ #category : 'tests' }
HyCFGInspectorTest >> testFilteringADifferentKindDoesNotHideOthers [
	"Hiding the statements keeps entry, exit, control flow and blocks"

	inspector controlPanel showStatementsCheckbox state: false.

	self assert: (inspector shouldIncludeNode: HyCFGEntryNode new).
	self assert: (inspector shouldIncludeNode: HyCFGControlFlowNode new).
	self assert: (inspector shouldIncludeNode: HyCFGBlockScopeNode new).
	self deny: (inspector shouldIncludeNode: HyCFGStatementNode new)
]

{ #category : 'tests' }
HyCFGInspectorTest >> testFilteringDoesNotModifyTheCFG [
	"The filtered view shares nodes with the inspected CFG, but must leave them untouched"

	| entryEdges statement |
	statement := cfg nodes detect: [ :node | node isKindOf: HyCFGStatementNode ].
	entryEdges := cfg entryNode outgoingEdges copy.
	inspector controlPanel showStatementsCheckbox state: false.

	inspector createFilteredCFG.

	self assert: cfg nodes size equals: 3.
	self assert: cfg edges size equals: 2.
	self assert: cfg entryNode outgoingEdges asArray equals: entryEdges asArray.
	self assert: cfg exitNode incomingEdges size equals: 1.
	self assert: statement outgoingEdges size equals: 1
]

{ #category : 'tests' }
HyCFGInspectorTest >> testHiddenNodeIsBridged [
	"entry -> statement -> exit with the statement hidden: entry -> exit, so the drawing stays connected"

	| filtered |
	inspector controlPanel showStatementsCheckbox state: false.

	filtered := inspector createFilteredCFG.

	self assert: filtered nodes size equals: 2.
	self assert: filtered edges size equals: 1.
	self assert: filtered edges first source equals: cfg entryNode.
	self assert: filtered edges first target equals: cfg exitNode
]

{ #category : 'tests' }
HyCFGInspectorTest >> testHidingEverythingGivesAnEmptyCFG [
	"No filter checked, nothing to draw, and no error"

	inspector controlPanel showEntryCheckbox state: false.
	inspector controlPanel showExitCheckbox state: false.
	inspector controlPanel showStatementsCheckbox state: false.

	self assert: inspector createFilteredCFG nodes isEmpty.
	self assert: inspector createFilteredCFG edges isEmpty.
	self assert: inspector createFilteredVisualization numberOfShapes equals: 0
]

{ #category : 'tests' }
HyCFGInspectorTest >> testInspectOpensTheCFGInspector [
	"inspect on a CFG opens this inspector instead of the default one"

	| opened |
	opened := cfg inspect.
	[ self assert: (opened isKindOf: HyCFGInspector) ] ensure: [ opened window close ]
]

{ #category : 'tests' }
HyCFGInspectorTest >> testInspectorExtensionsAreInTheUIPackage [
	"HyCFG does not depend on the UI package unless it is loaded: the two methods are extensions"

	self assert: (HyCFG >> #openInspector) package name equals: #'Hyphe-CFG-UI'.
	self assert: (HyCFG >> #inspect) package name equals: #'Hyphe-CFG-UI'
]

{ #category : 'tests' }
HyCFGInspectorTest >> testMetricsAreThoseOfTheShownCFG [
	"The metrics follow the filters"

	self assert: (inspector metricsPanel metricsText text includesSubstring: 'Statements: 1').

	inspector controlPanel showStatementsCheckbox state: false.

	self assert: (inspector metricsPanel metricsText text includesSubstring: 'Statements: 0').
	self assert: (inspector metricsPanel metricsText text includesSubstring: 'Total: 2')
]

{ #category : 'tests' }
HyCFGInspectorTest >> testNoCFG [
	"An inspector without CFG shows a message and an empty drawing"

	inspector cfg: nil.

	self assert: (inspector metricsPanel metricsText text includesSubstring: 'No CFG').
	self assert: inspector sourceTextPanel text asString equals: 'No source available'.
	self assert: inspector createFilteredVisualization numberOfShapes equals: 0
]

{ #category : 'tests' }
HyCFGInspectorTest >> testNodesOfAnotherKindAreAlwaysShown [
	"A node that is none of the known kinds is not filtered"

	self assert: (inspector shouldIncludeNode: HyCFGNode new)
]

{ #category : 'tests' }
HyCFGInspectorTest >> testNotebookHasVisualizationAndSourcePages [
	"The notebook has the two tabs of the specification"

	self assert: (inspector notebook pages collect: [ :page | page title ]) asArray equals: #( 'Visualization' 'Source' )
]

{ #category : 'tests' }
HyCFGInspectorTest >> testOpenInspectorOnTheCFG [
	"aCFG openInspector opens the inspector and answers it, with the title of the window"

	| opened |
	opened := cfg openInspector.
	[
		self assert: (opened isKindOf: HyCFGInspector).
		self assert: opened window isOpen.
		self assert: opened window title equals: 'CFG Inspector' ] ensure: [ opened window close ]
]

{ #category : 'tests' }
HyCFGInspectorTest >> testOpenOn [
	"openOn: opens a window and answers the inspector"

	| opened |
	opened := HyCFGInspector openOn: cfg.
	[
		self assert: (opened isKindOf: HyCFGInspector).
		self assert: opened window isOpen.
		self assert: opened cfg equals: cfg ] ensure: [ opened window close ]
]

{ #category : 'tests' }
HyCFGInspectorTest >> testOpenWindowShowsTheOtherFilterStates [
	"Filters changed in an open window act like in a closed one"

	| opened |
	opened := HyCFGInspector openOn: (self cfgForBody: 'x ifTrue: [ self a ]').
	[
		opened controlPanel showControlFlowCheckbox state: false.
		self assert: (opened metricsPanel metricsText text includesSubstring: 'Control Flow: 0').

		opened controlPanel resetFilters.
		self assert: (opened metricsPanel metricsText text includesSubstring: 'Control Flow: 1') ] ensure: [ opened window close ]
]

{ #category : 'tests' }
HyCFGInspectorTest >> testPagesOfTheNotebookProvideTheirPresenters [
	"The Visualization page shows the drawing, the Source page the text"

	| presenters |
	presenters := inspector notebook pages collect: [ :page | page retrievePresenter ].

	self assert: presenters first equals: inspector visualizationPresenter.
	self assert: presenters last equals: inspector sourceTextPanel
]

{ #category : 'tests' }
HyCFGInspectorTest >> testPanels [
	"The inspector has a control panel, a metrics panel and a notebook"

	self assert: (inspector controlPanel isKindOf: HyCFGControlPanel).
	self assert: (inspector metricsPanel isKindOf: HyCFGMetricsPanel).
	self assert: (inspector notebook isKindOf: SpNotebookPresenter)
]

{ #category : 'tests' }
HyCFGInspectorTest >> testRefreshAfterModifyingTheCFG [
	"refresh takes into account nodes added to the CFG"

	cfg addNode: HyCFGStatementNode new.

	inspector refresh.

	self assert: (inspector metricsPanel metricsText text includesSubstring: 'Statements: 2')
]

{ #category : 'tests' }
HyCFGInspectorTest >> testRequestFilenameAsksTheUser [
	"The dialog asks with the prompt and the default name, and answers what the user typed. The inspector is given a UI manager that answers without a dialog (the stub inspector skips the dialog, so a real one is used here)."

	| manager real |
	manager := HyCFGUIManagerStub new.
	manager answer: 'typed.png'.
	real := HyCFGInspector new.
	real uiManager: manager.

	self assert: (real requestFilename: 'PNG filename:' default: 'cfg.png') equals: 'typed.png'.
	self assert: manager prompts asArray equals: { { 'PNG filename:'. 'cfg.png' } }
]

{ #category : 'tests' }
HyCFGInspectorTest >> testShouldIncludeEachKindOfNode [
	"Each kind of node is shown or hidden by its own filter"

	| panel |
	panel := inspector controlPanel.
	{
		(HyCFGEntryNode new -> panel showEntryCheckbox).
		(HyCFGExitNode new -> panel showExitCheckbox).
		(HyCFGStatementNode new -> panel showStatementsCheckbox).
		(HyCFGControlFlowNode new -> panel showControlFlowCheckbox).
		(HyCFGBlockScopeNode new -> panel showBlocksCheckbox) } do: [ :association |
			association value state: true.
			self assert: (inspector shouldIncludeNode: association key) description: association key class name , ' on'.
			association value state: false.
			self deny: (inspector shouldIncludeNode: association key) description: association key class name , ' off'.
			association value state: true ]
]

{ #category : 'tests' }
HyCFGInspectorTest >> testSourceFallsBackOnTheASTNodes [
	"A CFG that does not remember its method still finds it through the AST nodes of its nodes"

	| built |
	built := self cfgForBody: 'self foo'.
	built methodNode: nil.

	self inspect: built.

	self assert: (inspector sourceTextPanel text includesSubstring: 'self foo')
]

{ #category : 'tests' }
HyCFGInspectorTest >> testSourceIsNotEditable [
	"The source and the metrics are read-only"

	self deny: inspector sourceTextPanel isEditable
]

{ #category : 'tests' }
HyCFGInspectorTest >> testSourceOfABuiltCFG [
	"The Source page shows the method the CFG was built from"

	self inspect: (HyCFGBuilder buildFrom: (OCParser parseMethod: 'foo: x
	^ x + 1')).

	self assert: (inspector sourceTextPanel text includesSubstring: 'foo: x').
	self assert: (inspector sourceTextPanel text includesSubstring: '^ x + 1')
]

{ #category : 'tests' }
HyCFGInspectorTest >> testSourceOfAHandMadeCFG [
	"A CFG made by hand has no source"

	self assert: inspector sourceTextPanel text asString equals: 'No source available'
]

{ #category : 'tests' }
HyCFGInspectorTest >> testWithoutControlPanelEverythingIsShown [
	"shouldIncludeNode: works before the panels exist (during initialization)"

	| saved |
	saved := inspector controlPanel.
	inspector instVarNamed: 'controlPanel' put: nil.
	[ self assert: (inspector shouldIncludeNode: HyCFGEntryNode new) ] ensure: [ inspector instVarNamed: 'controlPanel' put: saved ]
]
