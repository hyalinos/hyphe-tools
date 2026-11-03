"
Tests of the control panel of the CFG inspector: default state of the filters, callbacks, reset.
"
Class {
	#name : 'HyCFGControlPanelTest',
	#superclass : 'HyCFGAbstractTest',
	#instVars : [
		'panel'
	],
	#category : 'Hyphe-CFG-Tests-UI',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'UI'
}

{ #category : 'running' }
HyCFGControlPanelTest >> setUp [
	"A fresh panel"

	super setUp.
	panel := HyCFGControlPanel new
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testButtonsTriggerTheExportCallbacks [
	"The buttons are wired to the export requests"

	| png svg |
	png := svg := 0.
	panel whenExportPNGDo: [ png := png + 1 ].
	panel whenExportSVGDo: [ svg := svg + 1 ].

	panel exportPNGButton click.
	panel exportSVGButton click.

	self assert: png equals: 1.
	self assert: svg equals: 1
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testChangesAfterAResetAreNotLost [
	"The reset does not leave the panel muted"

	| calls |
	calls := 0.
	panel whenFiltersChangedDo: [ calls := calls + 1 ].
	panel resetFilters.
	calls := 0.

	panel showEntryCheckbox state: false.

	self assert: calls equals: 1
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testDefaultFiltersAllOn [
	"Everything is shown at the beginning"

	self assert: panel showEntry.
	self assert: panel showExit.
	self assert: panel showStatements.
	self assert: panel showControlFlow.
	self assert: panel showBlocks
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testEveryCheckboxTriggersTheCallback [
	"All five check boxes are connected"

	| calls |
	calls := 0.
	panel whenFiltersChangedDo: [ calls := calls + 1 ].

	{
		panel showEntryCheckbox.
		panel showExitCheckbox.
		panel showStatementsCheckbox.
		panel showControlFlowCheckbox.
		panel showBlocksCheckbox } do: [ :checkbox | checkbox state: false ].

	self assert: calls equals: 5
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testExportCallbacks [
	"The export requests call their own blocks"

	| png svg |
	png := svg := 0.
	panel whenExportPNGDo: [ png := png + 1 ].
	panel whenExportSVGDo: [ svg := svg + 1 ].

	panel exportPNG.
	self assert: png equals: 1.
	self assert: svg equals: 0.

	panel exportSVG.
	self assert: png equals: 1.
	self assert: svg equals: 1
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testFilterAccessorsFollowTheCheckboxes [
	"Each accessor answers the state of its own check box"

	panel showEntryCheckbox state: false.
	self deny: panel showEntry.
	self assert: panel showExit.

	panel showExitCheckbox state: false.
	self deny: panel showExit.

	panel showStatementsCheckbox state: false.
	self deny: panel showStatements.

	panel showControlFlowCheckbox state: false.
	self deny: panel showControlFlow.

	panel showBlocksCheckbox state: false.
	self deny: panel showBlocks
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testFiltersChangedCallback [
	"Changing a check box tells the registered block, once"

	| calls |
	calls := 0.
	panel whenFiltersChangedDo: [ calls := calls + 1 ].

	panel showEntryCheckbox state: false.
	self assert: calls equals: 1.

	panel showBlocksCheckbox state: false.
	self assert: calls equals: 2
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testInitialization [
	"The panel has a check box per kind of node and two export buttons"

	self assert: panel showEntryCheckbox notNil.
	self assert: panel showExitCheckbox notNil.
	self assert: panel showStatementsCheckbox notNil.
	self assert: panel showControlFlowCheckbox notNil.
	self assert: panel showBlocksCheckbox notNil.
	self assert: panel exportPNGButton notNil.
	self assert: panel exportSVGButton notNil
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testResetFiltersChecksEverythingAgain [
	"resetFilters puts all the check boxes back on"

	panel showEntryCheckbox state: false.
	panel showStatementsCheckbox state: false.
	panel showBlocksCheckbox state: false.

	panel resetFilters.

	self assert: panel showEntry.
	self assert: panel showExit.
	self assert: panel showStatements.
	self assert: panel showControlFlow.
	self assert: panel showBlocks
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testResetFiltersTellsOnce [
	"Resetting five check boxes is one change, not five redraws of the drawing"

	| calls |
	panel showEntryCheckbox state: false.
	panel showStatementsCheckbox state: false.
	panel showBlocksCheckbox state: false.
	calls := 0.
	panel whenFiltersChangedDo: [ calls := calls + 1 ].

	panel resetFilters.

	self assert: calls equals: 1
]

{ #category : 'tests' }
HyCFGControlPanelTest >> testSeveralCallbacksAreAllCalled [
	"Registering a block does not replace the others"

	| first second |
	first := second := 0.
	panel whenFiltersChangedDo: [ first := first + 1 ].
	panel whenFiltersChangedDo: [ second := second + 1 ].

	panel showExitCheckbox state: false.

	self assert: first equals: 1.
	self assert: second equals: 1
]
