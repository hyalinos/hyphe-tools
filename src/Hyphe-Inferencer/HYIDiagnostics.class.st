"
Task 11, scoped down: a trace carried ALONGSIDE the type (not inside it), per the spec's own framing. A full per-cell/per-merge trace object threaded through every operation's signature would touch (and require re-testing) essentially all of Tasks 2/3/6's already-green code; time-boxed, this is instead a single shared append-only log that pruning, weakening, widening and Conflict-dissolution each write one line to, tagged with a location (HYISigmaKey or similar) when known. Good enough to answer 'why this type and not a stronger one' by grepping the log for a given key; not a structural per-result trace object.
"
Class {
	#name : 'HYIDiagnostics',
	#superclass : 'Object',
	#classInstVars : [
		'Log'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'logging' }
HYIDiagnostics class >> log: aString [
	"Appends one free-text trace line -- lazily initializes the log on first use so nothing needs to call reset explicitly before the first log:."

	Log ifNil: [ self reset ].
	Log add: aString
]

{ #category : 'logging' }
HYIDiagnostics class >> log: aString for: aKey [
	"Convenience: logs aString prefixed with the (C,sel) key it's about, so traceFor: can later filter by key."

	self log: aKey printString , ': ' , aString
]

{ #category : 'logging' }
HYIDiagnostics class >> reset [
	"Clears the whole trace log -- call before a fresh run whose diagnostics you want isolated from a previous one."

	Log := OrderedCollection new
]

{ #category : 'logging' }
HYIDiagnostics class >> trace [
	"Answers the whole append-only trace log, oldest first."

	Log ifNil: [ self reset ].
	^ Log
]

{ #category : 'logging' }
HYIDiagnostics class >> traceFor: aKey [
	"Answers only the trace lines logged via log:for: aKey (matched by the 'ClassName>>#selector:' prefix log:for: writes)."

	| prefix |
	prefix := aKey printString , ':'.
	^ self trace select: [ :line | line beginsWith: prefix ]
]
