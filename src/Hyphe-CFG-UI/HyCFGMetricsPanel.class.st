"
Panel of the CFG inspector that shows statistics of a CFG as read-only text: number of nodes and edges by kind, maximal nesting depth, and whether the CFG is complete (see HyCFG>>isComplete).
"
Class {
	#name : 'HyCFGMetricsPanel',
	#superclass : 'SpPresenter',
	#instVars : [
		'cfg',
		'metricsText'
	],
	#category : 'Hyphe-CFG-UI',
	#package : 'Hyphe-CFG-UI'
}

{ #category : 'accessing' }
HyCFGMetricsPanel >> cfg [
	"Answer the CFG whose metrics are shown"

	^ cfg
]

{ #category : 'accessing' }
HyCFGMetricsPanel >> cfg: aCFG [
	"Show the metrics of a CFG (nil clears the panel)"

	cfg := aCFG.
	self updateMetrics
]

{ #category : 'layout' }
HyCFGMetricsPanel >> defaultLayout [
	"A title and the text"

	^ SpBoxLayout newTopToBottom
		  add: (self newLabel label: 'Metrics:') expand: false;
		  add: metricsText;
		  yourself
]

{ #category : 'initialization' }
HyCFGMetricsPanel >> initializePresenters [
	"Create the read-only text that shows the metrics"

	metricsText := self newText
		               editable: false;
		               yourself
]

{ #category : 'updating' }
HyCFGMetricsPanel >> metricsString [
	"Answer the metrics as text: nodes and edges by kind, structure"

	^ String streamContents: [ :stream | self writeMetricsOn: stream ]
]

{ #category : 'accessing' }
HyCFGMetricsPanel >> metricsText [
	"Answer the text presenter that shows the metrics"

	^ metricsText
]

{ #category : 'api' }
HyCFGMetricsPanel >> refresh [
	"Recompute the metrics, for when the CFG was modified"

	self updateMetrics
]

{ #category : 'updating' }
HyCFGMetricsPanel >> updateMetrics [
	"Write the metrics of the CFG in the text, or a message if there is no CFG"

	metricsText text: (cfg ifNil: [ 'No CFG loaded' ] ifNotNil: [ self metricsString ])
]

{ #category : 'accessing' }
HyCFGMetricsPanel >> writeMetricsOn: aStream [
	"Write the metrics of the CFG to a stream. Subclasses can add sections after calling super."

	aStream
		nextPutAll: 'NODES';
		cr;
		nextPutAll: '-----';
		cr;
		nextPutAll: 'Total: ';
		print: cfg nodes size;
		cr;
		nextPutAll: 'Entry: ';
		print: (cfg nodesOfKind: HyCFGEntryNode) size;
		cr;
		nextPutAll: 'Exit: ';
		print: (cfg nodesOfKind: HyCFGExitNode) size;
		cr;
		nextPutAll: 'Statements: ';
		print: (cfg nodesOfKind: HyCFGStatementNode) size;
		cr;
		nextPutAll: 'Control Flow: ';
		print: (cfg nodesOfKind: HyCFGControlFlowNode) size;
		cr;
		nextPutAll: 'Block Scope: ';
		print: (cfg nodesOfKind: HyCFGBlockScopeNode) size;
		cr;
		cr;
		nextPutAll: 'EDGES';
		cr;
		nextPutAll: '-----';
		cr;
		nextPutAll: 'Total: ';
		print: cfg edges size;
		cr;
		nextPutAll: 'Sequential: ';
		print: (cfg edgesOfKind: HyCFGSequentialEdge) size;
		cr;
		nextPutAll: 'Conditional: ';
		print: (cfg edgesOfKind: HyCFGConditionalEdge) size;
		cr;
		nextPutAll: 'Loop: ';
		print: (cfg edgesOfKind: HyCFGLoopEdge) size;
		cr;
		nextPutAll: 'Exception: ';
		print: (cfg edgesOfKind: HyCFGExceptionEdge) size;
		cr;
		nextPutAll: 'Return: ';
		print: (cfg edgesOfKind: HyCFGReturnEdge) size;
		cr;
		cr;
		nextPutAll: 'STRUCTURE';
		cr;
		nextPutAll: '---------';
		cr;
		nextPutAll: 'Max Depth: ';
		print: cfg maxNestingDepth;
		cr;
		nextPutAll: 'Cyclomatic: ';
		print: cfg cyclomaticComplexity;
		cr;
		nextPutAll: 'Complete: ';
		print: cfg isComplete;
		cr.

	cfg isComplete ifFalse: [
			aStream
				nextPutAll: 'Incomplete: ';
				print: cfg incompleteNodes size;
				nextPutAll: ' nodes';
				cr ]
]
