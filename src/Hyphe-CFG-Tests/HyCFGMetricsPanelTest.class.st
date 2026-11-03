"
Tests of the metrics panel of the CFG inspector: the text shown for a CFG, for no CFG, for an incomplete one.
"
Class {
	#name : 'HyCFGMetricsPanelTest',
	#superclass : 'HyCFGAbstractTest',
	#instVars : [
		'panel'
	],
	#category : 'Hyphe-CFG-Tests-UI',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'UI'
}

{ #category : 'running' }
HyCFGMetricsPanelTest >> setUp [
	"A fresh panel"

	super setUp.
	panel := HyCFGMetricsPanel new
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testCFGAccessor [
	"The panel knows the CFG it shows"

	| cfg |
	cfg := self simpleCFG.
	panel cfg: cfg.

	self assert: panel cfg equals: cfg
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testCompleteCFGHasNoIncompleteLine [
	"The Incomplete line is only for incomplete CFGs"

	panel cfg: self simpleCFG.

	self deny: (panel metricsText text includesSubstring: 'Incomplete:')
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testCountsOfARealMethod [
	"The counts of a loop with a conditional and an exception handler"

	| text |
	panel cfg: (self cfgForBody: 'items do: [ :e | e isNil ifTrue: [ ^ 1 ] ]. [ self a ] on: Error do: [ :ex | self b ]. ^ 2').
	text := panel metricsString.

	self assert: (text includesSubstring: 'Control Flow: 3').
	self assert: (text includesSubstring: 'Loop: 1').
	self assert: (text includesSubstring: 'Exception: 1').
	self assert: (text includesSubstring: 'Return: 2').
	self assert: (text includesSubstring: 'Max Depth: 2')
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testCountsOfASimpleCFG [
	"entry -> statement -> exit: 3 nodes, 2 sequential edges, depth 0, complete"

	| text |
	panel cfg: self simpleCFG.
	text := panel metricsText text asString.

	#( 'Total: 3' 'Entry: 1' 'Exit: 1' 'Statements: 1' 'Control Flow: 0' 'Block Scope: 0' 'Total: 2' 'Sequential: 2' 'Conditional: 0'
	   'Loop: 0' 'Exception: 0' 'Return: 0' 'Max Depth: 0' 'Complete: true' ) do: [ :line |
		self assert: (text includesSubstring: line) description: line , ' is missing in ' , text ]
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testCyclomaticLine [
	"The panel shows the cyclomatic complexity in the structure section"

	panel cfg: (self cfgForBody: 'self a ifTrue: [ ^ 1 ]. ^ 2').

	self assert: (panel metricsString includesSubstring: 'Cyclomatic: 2')
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testIncompleteCFG [
	"An incomplete CFG says how many nodes are incomplete"

	| text |
	panel cfg: (self cfgForBody: 'x ifTrue: aBlock. y ifTrue: otherBlock').
	text := panel metricsText text asString.

	self assert: (text includesSubstring: 'Complete: false').
	self assert: (text includesSubstring: 'Incomplete: 2 nodes')
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testInitialization [
	"The metrics are shown in a read-only text"

	self assert: panel metricsText notNil.
	self deny: panel metricsText isEditable
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testMaxDepth [
	"Max depth is the deepest node"

	| cfg |
	cfg := self simpleCFG.
	cfg addNode: (HyCFGBlockScopeNode createWithNesting: 2).
	panel cfg: cfg.

	self assert: (panel metricsText text includesSubstring: 'Max Depth: 2')
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testNoCFG [
	"Without CFG the panel says so"

	panel cfg: nil.

	self assert: (panel metricsText text includesSubstring: 'No CFG')
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testRefreshUpdatesTheText [
	"refresh recomputes the metrics after the CFG was modified"

	| cfg oldText |
	cfg := self simpleCFG.
	panel cfg: cfg.
	oldText := panel metricsText text asString.

	cfg addNode: HyCFGStatementNode new.
	panel refresh.

	self deny: panel metricsText text asString equals: oldText.
	self assert: (panel metricsText text includesSubstring: 'Total: 4')
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testSectionTitles [
	"The text has the three sections"

	| text |
	panel cfg: self simpleCFG.
	text := panel metricsText text asString.

	#( 'NODES' 'EDGES' 'STRUCTURE' ) do: [ :title | self assert: (text includesSubstring: title) description: title ]
]

{ #category : 'tests' }
HyCFGMetricsPanelTest >> testSettingTheCFGUpdatesTheText [
	"No need to refresh after cfg:"

	panel cfg: nil.
	self assert: (panel metricsText text includesSubstring: 'No CFG').

	panel cfg: self simpleCFG.
	self deny: (panel metricsText text includesSubstring: 'No CFG')
]
