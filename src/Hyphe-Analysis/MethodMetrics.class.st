"
All the metrics of the Hyphe analysis tools for one compiled method, computed on demand: size (statements, lines of code), structure (blocks, maximal and average block depth, explicit returns, assignments, cascades), type inference related (captured variables, ratio of self sends, nil-check density, receiver kinds), coupling (classes referred to, distinct selectors, fan-out) and implementors (average and maximal number of implementors of the selectors sent). Use: (MethodMetrics on: aCompiledMethod) asDictionary, or csvRow with MethodMetrics csvHeader to export many methods. Needs a compiled method (not a parsed one) so that the variables are bound.
"
Class {
	#name : 'MethodMetrics',
	#superclass : 'Object',
	#instVars : [
		'method'
	],
	#category : 'Hyphe-Analysis-Metrics',
	#package : 'Hyphe-Analysis',
	#tag : 'Metrics'
}

{ #category : 'accessing' }
MethodMetrics class >> csvHeader [
	"Answer the header of the CSV lines: package, class, selector and the metric names"

	^ #( #package #class #selector ) , self metricNames
]

{ #category : 'accessing' }
MethodMetrics class >> metricNames [
	"Answer the names of the metrics, in the order of csvHeader and csvRow"

	^ #( #statements #linesOfCode #blocks #maxBlockDepth #averageBlockDepth #explicitReturns #assignments #cascades #capturedVariables
	     #selfSendRatio #nilDensity #classReferences #distinctSelectors #fanOut #averageImplementors #maxImplementors )
]

{ #category : 'instance creation' }
MethodMetrics class >> on: aCompiledMethod [
	"Create the metrics of a compiled method"

	^ self new
		  setMethod: aCompiledMethod;
		  yourself
]

{ #category : 'converting' }
MethodMetrics >> asDictionary [
	"Answer all the metrics as a dictionary name -> value"

	| dictionary |
	dictionary := Dictionary new.
	self class metricNames do: [ :name | dictionary at: name put: (self perform: name) ].
	^ dictionary
]

{ #category : 'metrics' }
MethodMetrics >> assignments [
	"Number of assignments"

	^ AssignmentCounter new countAssignment: method
]

{ #category : 'metrics' }
MethodMetrics >> averageBlockDepth [
	"Mean depth of the blocks (see BlockDepthCounter)"

	^ BlockDepthCounter new averageDepthIn: method
]

{ #category : 'metrics' }
MethodMetrics >> averageImplementors [
	"Mean number of implementors of the selectors the method sends (NI), 0 if it sends nothing"

	| counts |
	counts := self implementorCounts values.
	^ counts isEmpty
		  ifTrue: [ 0 ]
		  ifFalse: [ counts sum / counts size asFloat ]
]

{ #category : 'metrics' }
MethodMetrics >> blocks [
	"Number of blocks (see BlocsCounter)"

	^ BlocsCounter new numberOfBlocIn: method
]

{ #category : 'metrics' }
MethodMetrics >> capturedVariables [
	"Number of local variables captured by blocks"

	^ CapturedVariableCounter new numberOfCapturedVariables: method
]

{ #category : 'metrics' }
MethodMetrics >> cascades [
	"Number of cascades"

	^ CascadeCounter new counterCascade: method
]

{ #category : 'metrics' }
MethodMetrics >> classReferences [
	"Number of distinct classes the method refers to (CBO at method level)"

	^ ClassReferencesCounter new countIn: method
]

{ #category : 'converting' }
MethodMetrics >> csvRow [
	"Answer the values for the CSV line: package, class, selector and the metrics in the order of csvHeader"

	^ {
		  method package name.
		  method methodClass name.
		  method selector } , (self class metricNames collect: [ :name | self perform: name ])
]

{ #category : 'metrics' }
MethodMetrics >> distinctSelectors [
	"Number of distinct selectors sent (NDS)"

	^ DistinctSelectorsCounter new countIn: method
]

{ #category : 'metrics' }
MethodMetrics >> explicitReturns [
	"Number of explicit returns (^)"

	^ ReturnCounter new returnInMethod: method
]

{ #category : 'metrics' }
MethodMetrics >> fanOut [
	"Number of distinct receiver classes that can be resolved statically"

	^ FanOutCounter new fanOutIn: method
]

{ #category : 'metrics' }
MethodMetrics >> implementorCounts [
	"Answer the number of implementors in the image of each selector the method sends: a dictionary selector -> number"

	^ (ImplementorsCounter new analyzeMethod: method) at: method
]

{ #category : 'metrics' }
MethodMetrics >> linesOfCode [
	"Lines of code, without signature, comments and blank lines (see LOCCounter)"

	^ LOCCounter new linesOfCode: method
]

{ #category : 'metrics' }
MethodMetrics >> maxBlockDepth [
	"Depth of the deepest block (see BlockDepthCounter)"

	^ BlockDepthCounter new maxDepthIn: method
]

{ #category : 'metrics' }
MethodMetrics >> maxImplementors [
	"Largest number of implementors of a selector the method sends, 0 if it sends nothing"

	| counts |
	counts := self implementorCounts values.
	^ counts isEmpty
		  ifTrue: [ 0 ]
		  ifFalse: [ counts max ]
]

{ #category : 'accessing' }
MethodMetrics >> method [
	"Answer the compiled method measured"

	^ method
]

{ #category : 'metrics' }
MethodMetrics >> nilDensity [
	"Nil checks (isNil, ifNil:, == nil) per line of code, 0 for a method without line"

	^ self linesOfCode = 0
		  ifTrue: [ 0 ]
		  ifFalse: [ NilDensity new nilCountIn: method ]
]

{ #category : 'metrics' }
MethodMetrics >> receiverProfile [
	"Number of sends per kind of receiver (see ReceiverOriginCounter)"

	^ (ReceiverOriginCounter new
		   analyzeMethod: method;
		   yourself) profile
]

{ #category : 'metrics' }
MethodMetrics >> selfSendRatio [
	"Proportion of the sends whose receiver is self (see ReceiverOriginCounter)"

	^ ReceiverOriginCounter new selfSendRatio: method
]

{ #category : 'initialization' }
MethodMetrics >> setMethod: aCompiledMethod [
	"Set the method measured"

	method := aCompiledMethod
]

{ #category : 'metrics' }
MethodMetrics >> statements [
	"Number of statements (see StatementCounter)"

	^ StatementCounter countStatementsIn: method
]
