"
Empirically observes return types by running a test suite with instrumented domain methods, using MethodProxies (github.com/pharo-contributions/MethodProxies) rather than Metalinks. Built after a live investigation found the Metalink-based predecessor (HypheReturnsCollectorMethodNodes) could hang indefinitely just installing instrumentation on AST-Core -- Metalinks require recompiling the target method through the AST pipeline, which is self-referential when the target class IS that pipeline. MethodProxies instead patches the method dictionary and a literal directly (confirmed live: no #ast call anywhere in its install path), so it should not hit that failure mode.

Safety design, each one a direct answer to a real failure found empirically this session:
- Exclusion policy (isEligibleForInstrumentation:) skips primitives, methods with 6+ arguments (MethodProxies' own hard limit -- MpHandler class>>canHandle: is `arity < 6`), and a configurable set of compiler/reflection-infrastructure packages by default (excludedPackagePrefixes) -- the AST-Core class of problem in general, not just that one package.
- instrumentForRecording runs in its own forked process with a wall-clock budget (maxSecondsForInstrumentation) -- the previous tool had no timeout at all around instrumentation, only around test execution, which is exactly what let AST-Core hang forever.
- proxies (the list of installed MpMethodProxy instances) lives on this persistent collector object, not as a temp local to the forked instrumentation block -- so even if that fork is terminated mid-loop, whatever was already installed is still reachable afterward for cleanup, unlike this session's own diagnostic mishap where a terminated fork's local proxy list was unrecoverable.
- class-side uninstallAllProxiesOn:/uninstallAllProxiesOnPackages: give a completely collector-independent recovery path: they scan a class's methodDict directly for MpHiddenSelector keys (the marker MethodProxies itself uses) and restore the original method, with no dependency on any live MpMethodProxy or collector object -- confirmed live this recovers a class exactly as well as the original proxy's own #uninstall would have.
- observations is capped (maxObservations) so a very hot method cannot grow collection data without bound.
- MpMethodProxy enableInstrumentation/disableInstrumentation (a single global switch shared by every installed proxy) is only turned on for the test-execution window, minimizing how long instrumentation is actually live.
"
Class {
	#name : 'HyMpReturnsCollector',
	#superclass : 'Object',
	#instVars : [
		'methodsToRecord',
		'testCaseClasses',
		'proxies',
		'observations',
		'status',
		'errorMessage',
		'executionTime',
		'logEntries'
	],
	#category : 'HyMpReturnTypeProfiler',
	#package : 'HyMpReturnTypeProfiler'
}

{ #category : 'configuration' }
HyMpReturnsCollector class >> excludedPackagePrefixes [
	"Packages skipped by default when collecting methods to instrument. Two different
	 reasons bundled into one list, both defended against the same way:

	 1) Compiler/reflection infrastructure MethodProxies' own installation machinery (and
	 Pharo's method-dictionary/literal patching generally) may itself depend on -- the
	 AST-Core class of problem the Metalink-based predecessor actually hung on, even
	 though MethodProxies itself doesn't call #ast and was confirmed live not to hang on
	 AST-Core specifically.

	 2) IDE/tooling infrastructure (refactoring engine, lint, reflectivity, debugger/
	 inspector extensions, doc tooling, syntax highlighting) that isn't 'domain code' by
	 the methodology's own Phase 1 rationale (observe business logic, not infrastructure)
	 -- confirmed live these got swept in as extension methods on AST-Core's own classes
	 (Reflectivity, Renraku, Sindarin, Refactoring-*, NewTools-*, etc. all showed up when
	 this list only had the five narrowly hang-motivated entries).

	 Prefix-matched, not exact-matched -- see isExcludedPackageName:."

	^ #( 'AST-Core' 'OpalCompiler' 'Kernel' 'MethodProxies' 'HyMpReturnTypeProfiler' 'Reflectivity' 'Renraku' 'Sindarin' 'Refactoring'
	     'NewTools' 'Calypso' 'ParseTreeRewriter' 'ClassParser' 'Formatter' 'PharoDocComment' 'Shout' 'Debugging' 'DebugPoints'
	     'SystemCommands' 'Deprecated13' 'Deprecated14' 'PharoCompatibility' 'MCP' )
]

{ #category : 'configuration' }
HyMpReturnsCollector class >> maxObservations [
	"Hard cap on how many observations a single run collects, so a very hot method (called
	 many thousands of times) cannot grow collection data without bound."

	^ 200000
]

{ #category : 'configuration' }
HyMpReturnsCollector class >> maxSecondsForInstrumentation [
	"Wall-clock budget for instrumentForRecording. If installing proxies on every eligible
	 method in scope doesn't finish in time, whatever got installed so far is kept and used
	 -- see instrumentForRecording's own comment."

	^ 30
]

{ #category : 'class configuration' }
HyMpReturnsCollector class >> maxSecondsPerPackage [
	"Outer wall-clock budget for one whole package (instrumentation + every test run
	 together), on top of the per-instrumentation-phase and per-test timeouts. Those inner
	 caps bound a single hang, but a package with many slow tests could still add up well
	 past any sane per-package budget -- this is the backstop that guarantees a caller
	 sweeping many packages always gets a result back for each one."

	^ 300
]

{ #category : 'configuration' }
HyMpReturnsCollector class >> maxSecondsPerTest [
	"Wall-clock budget for one test method, same defense-in-depth this project already
	 uses elsewhere for exactly this reason: a hung/looping test must not block the whole
	 package sweep."

	^ 30
]

{ #category : 'running' }
HyMpReturnsCollector class >> runOnPackage: aPackageName [
	"Runs processPackages: for a single package inside an outer maxSecondsPerPackage
	 budget. Returns the collector (whatever it gathered, whether it finished cleanly or
	 was cut off)."

	| collector semaphore worker timedOut |
	collector := self new.
	semaphore := Semaphore new.
	worker := [
		          collector processPackages: (Array with: aPackageName).
		          semaphore signal ] fork.
	timedOut := semaphore waitTimeoutSeconds: self maxSecondsPerPackage.
	timedOut ifTrue: [
			worker terminate.
			collector log: '[PACKAGE] Outer budget of ' , self maxSecondsPerPackage asString , 's exceeded -- terminated with '
				, collector observations size asString , ' observations collected so far' ].
	^ collector
]

{ #category : 'running' }
HyMpReturnsCollector class >> runOnPackages: aCollectionOfPackageNames [
	"Like runOnPackage: but processes the whole collection together in one
	 processPackages: call. Domain code and the tests that exercise it are often split
	 across companion packages (e.g. 'Geometry' / 'Geometry-Tests') -- calling
	 runOnPackage: separately for each finds zero observations for either half, since
	 setMethodsFromPackages: only instruments non-test code and runAllTests only runs
	 test classes, and a single-package call to either sees just one side. The outer
	 budget scales with the number of packages so a multi-package sweep still gets a
	 bounded worst case."

	| collector semaphore worker timedOut budget |
	collector := self new.
	budget := self maxSecondsPerPackage * (aCollectionOfPackageNames size max: 1).
	semaphore := Semaphore new.
	worker := [
		          collector processPackages: aCollectionOfPackageNames asArray.
		          semaphore signal ] fork.
	timedOut := semaphore waitTimeoutSeconds: budget.
	timedOut ifTrue: [
			worker terminate.
			collector log:
				'[PACKAGES] Outer budget of ' , budget asString , 's exceeded -- terminated with ' , collector observations size asString
				, ' observations collected so far' ].
	^ collector
]

{ #category : 'running' }
HyMpReturnsCollector class >> runPackageAndAppendCsv: aPackageName csvPath: aCsvPathString logPath: aLogPathString [
	"Full per-package pipeline for a whole-image sweep: run the package with its outer
	 budget, build a report, append its CSV rows to aCsvPathString (writing the header
	 only the first time the file is created), append one progress line to
	 aLogPathString, and return a small stats Dictionary -- never the CSV text itself,
	 so the RPC response stays tiny even though the file on disk can grow large."

	| collector report csvFile logFile isNewCsv csvStream logStream rows startTime elapsed stats |
	startTime := DateAndTime now.
	collector := self runOnPackage: aPackageName.
	report := HyMpReturnTypeReport fromObservations: collector observations.
	elapsed := DateAndTime now - startTime.

	csvFile := aCsvPathString asFileReference.
	isNewCsv := csvFile exists not.
	rows := report asCsvString lines.
	csvStream := csvFile writeStream.
	csvStream setToEnd.
	isNewCsv ifTrue: [
			csvStream
				nextPutAll: rows first;
				nextPut: Character lf ].
	rows allButFirst do: [ :line |
			csvStream
				nextPutAll: line;
				nextPut: Character lf ].
	csvStream close.

	logFile := aLogPathString asFileReference.
	logStream := logFile writeStream.
	logStream setToEnd.
	logStream
		nextPutAll: DateAndTime now printString , ' | ' , aPackageName , ' | status=' , collector status asString , ' | methods='
			, collector methodsToRecord size asString , ' | observations=' , collector observations size asString , ' | profiles='
			, report size asString , ' | elapsedSeconds=' , elapsed asSeconds asString;
		nextPut: Character lf;
		close.

	stats := Dictionary new.
	stats at: #package put: aPackageName.
	stats at: #status put: collector status.
	stats at: #methods put: collector methodsToRecord size.
	stats at: #observations put: collector observations size.
	stats at: #profiles put: report size.
	stats at: #elapsedSeconds put: elapsed asSeconds.
	^ stats
]

{ #category : 'recovery' }
HyMpReturnsCollector class >> uninstallAllProxiesOn: aClass [
	"Collector-independent recovery: scans aClass's own method dictionary (both instance
	 and class side) directly for MpHiddenSelector keys -- the marker MethodProxies itself
	 installs -- and restores the original method under its real selector, with no
	 dependency on any live MpMethodProxy or HyMpReturnsCollector instance. Confirmed live
	 this recovers a class exactly as well as the original proxy's own #uninstall would
	 have. Use this after an interrupted run (a killed process, a terminated fork) whose
	 own proxies collection is unreachable -- this session hit exactly that with the
	 Metalink-based predecessor and had no way back; this is the fix. Answers how many
	 proxies were found and removed."

	| removed |
	removed := 0.
	{
		aClass.
		aClass class } do: [ :behavior |
			(behavior methodDict keys select: [ :k | k isKindOf: MpHiddenSelector ]) do: [ :hiddenSel |
					| original realSelector |
					original := behavior methodDict at: hiddenSel.
					realSelector := hiddenSel proxifiedSelector.
					behavior methodDict at: realSelector put: original.
					behavior methodDict removeKey: hiddenSel.
					removed := removed + 1 ] ].
	^ removed
]

{ #category : 'recovery' }
HyMpReturnsCollector class >> uninstallAllProxiesOnPackages: aCollectionOfPackageNames [
	"Same recovery as uninstallAllProxiesOn:, applied to every class in every named
	 package. Also turns the global instrumentation switch off, since a recovery like this
	 is by definition being run because something is in an unknown/unsafe state."

	| removed |
	removed := 0.
	aCollectionOfPackageNames do: [ :packageName |
			(PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ]) ifNotNil: [ :package |
				package definedClasses do: [ :class | removed := removed + (self uninstallAllProxiesOn: class) ] ] ].
	[ MpMethodProxy disableInstrumentation ]
		on: Error
		do: [ :e |  ].
	^ removed
]

{ #category : 'cleanup' }
HyMpReturnsCollector >> cleanup [
	"Uninstall every proxy this collector itself installed. Always safe to call more than
	 once (MpMethodProxy>>uninstall is itself a no-op once isInstalled is false)."

	[ MpMethodProxy disableInstrumentation ]
		on: Error
		do: [ :e |  ].
	proxies do: [ :p |
			[ p uninstall ]
				on: Error
				do: [ :e | self log: '[CLEANUP] Error uninstalling a proxy: ' , e messageText ] ].
	self log: '[CLEANUP] Uninstalled ' , proxies size asString , ' proxies'
]

{ #category : 'accessing' }
HyMpReturnsCollector >> errorMessage [

	^ errorMessage
]

{ #category : 'accessing' }
HyMpReturnsCollector >> executionTime [

	^ executionTime
]

{ #category : 'initialization' }
HyMpReturnsCollector >> initialize [

	super initialize.
	methodsToRecord := OrderedCollection new.
	testCaseClasses := OrderedCollection new.
	proxies := OrderedCollection new.
	observations := OrderedCollection new.
	status := #notStarted.
	logEntries := OrderedCollection new
]

{ #category : 'instrumentation' }
HyMpReturnsCollector >> instrumentForRecording [
	"Runs instrumentForRecordingUnbounded in its own forked process with a wall-clock
	 budget (maxSecondsForInstrumentation). This is the single biggest safety difference
	 from the Metalink-based predecessor, whose instrumentForRecording had no timeout at
	 all -- confirmed live this session that installing instrumentation (not even running a
	 single test yet) can itself hang indefinitely on a self-referential package like
	 AST-Core. If the timeout fires, whatever got installed before it is kept (see
	 instrumentMethod:'s own comment) and the run continues with that partial scope rather
	 than hanging forever or losing everything. Returns true if it timed out."

	| semaphore worker timedOut |
	semaphore := Semaphore new.
	worker := [
		          [ self instrumentForRecordingUnbounded ]
			          on: Error
			          do: [ :e | self log: '[INSTRUMENT] Unexpected error: ' , e messageText ].
		          semaphore signal ] fork.

	timedOut := semaphore waitTimeoutSeconds: self class maxSecondsForInstrumentation.
	timedOut
		ifTrue: [
				worker terminate.
				self log: '[INSTRUMENT] TIMED OUT after ' , self class maxSecondsForInstrumentation asString , 's -- continuing with '
					, proxies size asString , ' of ' , methodsToRecord size asString , ' methods instrumented' ]
		ifFalse: [ self log: '[INSTRUMENT] Instrumented ' , proxies size asString , ' methods' ].
	^ timedOut
]

{ #category : 'instrumentation' }
HyMpReturnsCollector >> instrumentForRecordingUnbounded [
	"The real, unwrapped instrumentation loop -- see instrumentForRecording for the
	 timeout wrapper around this."

	methodsToRecord do: [ :aCompiledMethod |
			[ self instrumentMethod: aCompiledMethod ]
				on: Error
				do: [ :e |
						self log:
							'[INSTRUMENT] ERROR instrumenting ' , aCompiledMethod methodClass name , '>>' , aCompiledMethod selector , ': '
							, e messageText ] ]
]

{ #category : 'instrumentation' }
HyMpReturnsCollector >> instrumentMethod: aCompiledMethod [
	"Install one proxy. proxies is this collector's own instance variable, not a temp
	 local to whatever process calls this -- so even if the caller (instrumentForRecording,
	 running this in a forked process with a timeout) gets terminated partway through a
	 loop of these, everything already installed is still reachable via self proxies
	 afterward for cleanup. That mattered in practice: an earlier diagnostic mishap this
	 session left stray instrumentation live with no way back to it, precisely because its
	 tracking collection was a local inside the terminated fork instead of here."

	| handler proxy |
	handler := HyMpReturnsHandler new collector: self definingClass: aCompiledMethod methodClass selector: aCompiledMethod selector.
	proxy := MpMethodProxy onMethod: aCompiledMethod handler: handler.
	proxy install.
	proxies add: proxy
]

{ #category : 'scope' }
HyMpReturnsCollector >> isEligibleForInstrumentation: aCompiledMethod [
	"The actual exclusion policy: skip primitives (cannot be instrumented at this level
	 anyway -- MethodProxies still patches them, per-primitive behavior is not something
	 this tool wants to depend on), methods with 6+ arguments (MpHandler class>>canHandle:'s
	 own hard limit -- confirmed live: arity < 6), anything carrying a #noInstrumentation
	 pragma (an explicit opt-out this tool must honor), and anything in a package this
	 tool's own default (or caller-overridden) exclusion list flags as compiler/reflection
	 infrastructure. Fails CLOSED (excludes) if the package check itself errors for any
	 reason -- a real bug once did exactly that (a typo'd selector) and silently included
	 everything it should have excluded instead, which is backwards for a safety filter."

	aCompiledMethod isPrimitive ifTrue: [ ^ false ].
	aCompiledMethod numArgs > 5 ifTrue: [ ^ false ].
	(aCompiledMethod hasPragmaNamed: #noInstrumentation) ifTrue: [ ^ false ].
	^ [ (self isExcludedPackageName: aCompiledMethod package name) not ]
		  on: Error
		  do: [ :e | false ]
]

{ #category : 'scope' }
HyMpReturnsCollector >> isExcludedPackageName: aPackageName [
	"Prefix match, not exact -- see excludedPackagePrefixes' own comment."

	^ self class excludedPackagePrefixes anySatisfy: [ :prefix |
		  aPackageName asString = prefix or: [ aPackageName asString beginsWith: prefix , '-' ] ]
]

{ #category : 'logging' }
HyMpReturnsCollector >> log: aString [
	"A minimal, in-memory log -- kept as plain strings rather than Transcript output so it
	 survives being read back over MCP/headless, where Transcript is not visible."

	logEntries add: aString
]

{ #category : 'logging' }
HyMpReturnsCollector >> logEntries [

	^ logEntries
]

{ #category : 'accessing' }
HyMpReturnsCollector >> methodsToRecord [

	^ methodsToRecord
]

{ #category : 'accessing' }
HyMpReturnsCollector >> observations [

	^ observations
]

{ #category : 'execution' }
HyMpReturnsCollector >> processPackages: aCollectionOfPackageNames [
	"Main entry point -- the whole methodology in one call: scope, instrument, run tests,
	 always clean up (ensure:) regardless of how far execution got."

	| startTime |
	status := #running.
	startTime := DateAndTime now.
	self log: '[PROCESS] Starting on ' , aCollectionOfPackageNames size asString , ' package(s)'.

	[
		[
			self setMethodsFromPackages: aCollectionOfPackageNames.
			self instrumentForRecording.
			MpMethodProxy enableInstrumentation.
			self runAllTests.
			status := #completed.
			self log: '[PROCESS] Completed' ]
			on: Error
			do: [ :e |
					status := #error.
					errorMessage := e messageText.
					self log: '[PROCESS] Error: ' , e messageText ] ] ensure: [
			self cleanup.
			executionTime := DateAndTime now - startTime.
			self log: '[PROCESS] Cleanup done, ' , observations size asString , ' observations collected' ].

	^ self
]

{ #category : 'accessing' }
HyMpReturnsCollector >> proxies [

	^ proxies
]

{ #category : 'recording' }
HyMpReturnsCollector >> recordReceiver: receiverClass definingClass: dClass selector: aSelector returnClass: rClass [
	"Called by a HyMpReturnsHandler after every instrumented method's normal return.
	 Capped at maxObservations so a very hot method can't grow this without bound."

	observations size >= self class maxObservations ifTrue: [ ^ self ].
	observations add: (HyMpObservation new
			 receiverClass: receiverClass
			 definingClass: dClass
			 selector: aSelector
			 returnClass: rClass)
]

{ #category : 'execution' }
HyMpReturnsCollector >> runAllTests [
	"Step 3 of the methodology: run every test method of every collected test-case class,
	 each under its own wall-clock budget (runTestCase:selector:) so one hung test can't
	 block the rest. Tests don't 'know' they're being observed -- this is just
	 TestCase>>runCase, same as any normal test run."

	| testPairs |
	testPairs := OrderedCollection new.
	testCaseClasses do: [ :testClass | testClass allTestSelectors do: [ :selector | testPairs add: testClass -> selector ] ].
	self log: '[TEST] ' , testPairs size asString , ' test cases to run'.

	testPairs do: [ :pair |
			| testCase |
			testCase := pair key new.
			testCase setTestSelector: pair value.
			self log: '[TEST] Running: ' , pair key name , '>>' , pair value.
			self runTestCase: testCase selector: pair value ]
]

{ #category : 'execution' }
HyMpReturnsCollector >> runTestCase: testCase selector: selector [
	"Same per-test wall-clock budget this project already established for the Metalink-
	 based predecessor (HypheReturnsCollectorMethodNodes>>runTestCase:selector:), for the
	 same reason: a hung/looping test must not block the whole package sweep. runCase
	 itself already handles setUp/performTest/tearDown/resources correctly -- no need to
	 hand-orchestrate those. Returns true if the test timed out."

	| semaphore worker timedOut |
	semaphore := Semaphore new.
	worker := [
		          [ testCase runCase ]
			          on: Error , TestFailure , TestSkipped , AssertionFailure
			          do: [ :e | self log: '[TEST] Failed/error: ' , testCase class name , '>>' , selector , ' - ' , e messageText ].
		          semaphore signal ] fork.

	timedOut := semaphore waitTimeoutSeconds: self class maxSecondsPerTest.
	timedOut ifTrue: [
			worker terminate.
			self log: '[TEST] TIMED OUT after ' , self class maxSecondsPerTest asString , 's: ' , testCase class name , '>>' , selector ].
	^ timedOut
]

{ #category : 'scope' }
HyMpReturnsCollector >> setMethodsFromPackages: aCollectionOfPackageNames [
	"Step 1 of the methodology: separate test-driver classes (execution drivers) from
	 domain methods (the instrumentation target set), matching the original methodology's
	 own Phase 1 rationale. Domain methods are further filtered by
	 isEligibleForInstrumentation: before being added."

	aCollectionOfPackageNames do: [ :packageName |
			| package |
			package := PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ].
			package ifNil: [ self log: '[SCOPE] WARNING: package not found: ' , packageName ] ifNotNil: [
					self log: '[SCOPE] Processing package: ' , packageName.
					package definedClasses do: [ :class |
							class isTestCase
								ifTrue: [ testCaseClasses add: class ]
								ifFalse: [
								class methods , class class methods do: [ :m | (self isEligibleForInstrumentation: m) ifTrue: [ methodsToRecord add: m ] ] ] ] ] ].
	self log: '[SCOPE] ' , testCaseClasses size asString , ' test case classes, ' , methodsToRecord size asString
		, ' eligible methods to instrument'
]

{ #category : 'accessing' }
HyMpReturnsCollector >> status [

	^ status
]

{ #category : 'accessing' }
HyMpReturnsCollector >> testCaseClasses [

	^ testCaseClasses
]
