"
Left panel of the CFG inspector: check boxes to show or hide the kinds of nodes (entry, exit, statements, control flow, blocks) and buttons to export the drawing as PNG or SVG. It knows nothing of the CFG: it only tells, through whenFiltersChangedDo:, whenExportPNGDo: and whenExportSVGDo:, that the user asked for something.
"
Class {
	#name : 'HyCFGControlPanel',
	#superclass : 'SpPresenter',
	#instVars : [
		'showEntryCheckbox',
		'showExitCheckbox',
		'showStatementsCheckbox',
		'showControlFlowCheckbox',
		'showBlocksCheckbox',
		'exportPNGButton',
		'exportSVGButton',
		'filtersChangedBlocks',
		'exportPNGBlocks',
		'exportSVGBlocks',
		'isResetting'
	],
	#category : 'Hyphe-CFG-UI',
	#package : 'Hyphe-CFG-UI'
}

{ #category : 'initialization' }
HyCFGControlPanel >> connectActions [
	"Make the check boxes and the buttons tell the registered callbacks"

	{
		showEntryCheckbox.
		showExitCheckbox.
		showStatementsCheckbox.
		showControlFlowCheckbox.
		showBlocksCheckbox } do: [ :checkbox | checkbox whenChangedDo: [ self filtersChanged ] ].

	exportPNGButton action: [ self exportPNG ].
	exportSVGButton action: [ self exportSVG ]
]

{ #category : 'layout' }
HyCFGControlPanel >> defaultLayout [
	"Filters on top, a spacer, then the export buttons"

	^ SpBoxLayout newTopToBottom
		  add: (self newLabel label: 'Filters:') expand: false;
		  add: showEntryCheckbox expand: false;
		  add: showExitCheckbox expand: false;
		  add: showStatementsCheckbox expand: false;
		  add: showControlFlowCheckbox expand: false;
		  add: showBlocksCheckbox expand: false;
		  add: self newLabel expand: true;
		  add: (self newLabel label: 'Export:') expand: false;
		  add: exportPNGButton expand: false;
		  add: exportSVGButton expand: false;
		  spacing: 5;
		  yourself
]

{ #category : 'actions' }
HyCFGControlPanel >> exportPNG [
	"Tell the registered blocks that a PNG export was asked"

	exportPNGBlocks do: [ :block | block value ]
]

{ #category : 'accessing' }
HyCFGControlPanel >> exportPNGButton [
	"Answer the button that asks for a PNG export"

	^ exportPNGButton
]

{ #category : 'actions' }
HyCFGControlPanel >> exportSVG [
	"Tell the registered blocks that an SVG export was asked"

	exportSVGBlocks do: [ :block | block value ]
]

{ #category : 'accessing' }
HyCFGControlPanel >> exportSVGButton [
	"Answer the button that asks for an SVG export"

	^ exportSVGButton
]

{ #category : 'actions' }
HyCFGControlPanel >> filtersChanged [
	"Tell the registered blocks that a filter changed, unless several filters are being changed at once (see #resetFilters)"

	isResetting ifTrue: [ ^ self ].
	filtersChangedBlocks do: [ :block | block value ]
]

{ #category : 'initialization' }
HyCFGControlPanel >> initializePresenters [
	"Create the filter check boxes (all checked) and the export buttons"

	filtersChangedBlocks := OrderedCollection new.
	exportPNGBlocks := OrderedCollection new.
	exportSVGBlocks := OrderedCollection new.
	isResetting := false.

	showEntryCheckbox := self newCheckBox
		                     label: 'Entry node';
		                     state: true;
		                     yourself.
	showExitCheckbox := self newCheckBox
		                    label: 'Exit node';
		                    state: true;
		                    yourself.
	showStatementsCheckbox := self newCheckBox
		                          label: 'Statement nodes';
		                          state: true;
		                          yourself.
	showControlFlowCheckbox := self newCheckBox
		                           label: 'Control flow nodes';
		                           state: true;
		                           yourself.
	showBlocksCheckbox := self newCheckBox
		                      label: 'Block nodes';
		                      state: true;
		                      yourself.

	exportPNGButton := self newButton
		                   label: 'Export PNG';
		                   icon: (self iconNamed: #smallSaveAs);
		                   yourself.
	exportSVGButton := self newButton
		                   label: 'Export SVG';
		                   icon: (self iconNamed: #smallSaveAs);
		                   yourself.

	self connectActions
]

{ #category : 'actions' }
HyCFGControlPanel >> resetFilters [
	"Check all the filters again. The registered blocks are told once, not once per check box."

	isResetting := true.
	[
		{
			showEntryCheckbox.
			showExitCheckbox.
			showStatementsCheckbox.
			showControlFlowCheckbox.
			showBlocksCheckbox } do: [ :checkbox | checkbox state: true ] ] ensure: [ isResetting := false ].
	self filtersChanged
]

{ #category : 'filters' }
HyCFGControlPanel >> showBlocks [
	"Answer true if block scope nodes must be shown"

	^ showBlocksCheckbox state
]

{ #category : 'accessing' }
HyCFGControlPanel >> showBlocksCheckbox [
	"Answer the check box that shows or hides the block scope nodes"

	^ showBlocksCheckbox
]

{ #category : 'filters' }
HyCFGControlPanel >> showControlFlow [
	"Answer true if control flow nodes must be shown"

	^ showControlFlowCheckbox state
]

{ #category : 'accessing' }
HyCFGControlPanel >> showControlFlowCheckbox [
	"Answer the check box that shows or hides the control flow nodes"

	^ showControlFlowCheckbox
]

{ #category : 'filters' }
HyCFGControlPanel >> showEntry [
	"Answer true if entry nodes must be shown"

	^ showEntryCheckbox state
]

{ #category : 'accessing' }
HyCFGControlPanel >> showEntryCheckbox [
	"Answer the check box that shows or hides the entry node"

	^ showEntryCheckbox
]

{ #category : 'filters' }
HyCFGControlPanel >> showExit [
	"Answer true if exit nodes must be shown"

	^ showExitCheckbox state
]

{ #category : 'accessing' }
HyCFGControlPanel >> showExitCheckbox [
	"Answer the check box that shows or hides the exit node"

	^ showExitCheckbox
]

{ #category : 'filters' }
HyCFGControlPanel >> showStatements [
	"Answer true if statement nodes must be shown"

	^ showStatementsCheckbox state
]

{ #category : 'accessing' }
HyCFGControlPanel >> showStatementsCheckbox [
	"Answer the check box that shows or hides the statement nodes"

	^ showStatementsCheckbox
]

{ #category : 'callbacks' }
HyCFGControlPanel >> whenExportPNGDo: aBlock [
	"Register a block to evaluate when the user asks for a PNG export"

	exportPNGBlocks add: aBlock
]

{ #category : 'callbacks' }
HyCFGControlPanel >> whenExportSVGDo: aBlock [
	"Register a block to evaluate when the user asks for an SVG export"

	exportSVGBlocks add: aBlock
]

{ #category : 'callbacks' }
HyCFGControlPanel >> whenFiltersChangedDo: aBlock [
	"Register a block to evaluate each time a filter changes"

	filtersChangedBlocks add: aBlock
]
