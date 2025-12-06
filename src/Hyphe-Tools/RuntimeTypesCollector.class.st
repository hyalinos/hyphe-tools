"
I represent a dynamic collector and analyzer of test classes available in the currently installed packages of the system.

- Discover and aggregate all test classes present in the image.
- Install a method proxy, using the MethodProxies library, on every test method I find.
- Trap the execution of these methods in order to capture and record their return values.
"
Class {
	#name : 'RuntimeTypesCollector',
	#superclass : 'Object',
	#instVars : [
		'collectedTypes',
		'noInstrumentationMethods'
	],
	#category : 'Hyphe-Tools-TestProfiler',
	#package : 'Hyphe-Tools',
	#tag : 'TestProfiler'
}

{ #category : 'examples' }
RuntimeTypesCollector class >> example [

	^ self new collect collectedTypes
]

{ #category : 'initialization' }
RuntimeTypesCollector >> addCollectedType: data [

	collectedTypes add: data
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectInAllTestPackages [
		
	(Smalltalk globals organization packages select: [ :p | p name endsWith: '-Tests' ]) do: [ :p | self collectInPackage: p name ]
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectInPackage: packageName [
	
	(Smalltalk globals organization packageNamed: packageName) classes do: [ :cl |
		cl methods do: [ :m | self collectInTest: m inClass: cl ] ]
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectInTest: compiledTest inClass: classObj [

	| testCase proxies methods |
	methods := self collectMethodsToInstrument: classObj >> compiledTest selector.
	testCase := BagTest selector: compiledTest selector.

	proxies := (methods collect: [ :m |
			            ((m pragmas anySatisfy: [ :p | p selector beginsWith: 'primitive' ]) or: (m hasPragmaNamed: #noInstrumentation))
				            ifFalse: [
						            MpMethodProxy onMethod: m handler: (MpTypeFeedbackHandler new
								             collector: self;
								             method: m;
								             yourself) ] ]) reject: #isNil.

	proxies do: [ :p | p install ].
	MpMethodProxy enableInstrumentation.

	testCase run.

	proxies do: [ :p | p uninstall ].
	MpMethodProxy disableInstrumentation
]

{ #category : 'as yet unclassified' }
RuntimeTypesCollector >> collectMethodsToInstrument: method [
	
	^ ((MessageNodesCollector new visit: method ast)
		                messageNodes)
	 flatCollect: [ :mn |
		           SystemNavigation default allImplementorsOf: mn selector ].

	
]

{ #category : 'accessing' }
RuntimeTypesCollector >> collectedTypes [

	^ collectedTypes
]

{ #category : 'initialization' }
RuntimeTypesCollector >> initialize [

	super initialize.
	collectedTypes := OrderedCollection new.
]
