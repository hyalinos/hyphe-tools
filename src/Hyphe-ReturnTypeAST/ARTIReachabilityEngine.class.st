"
REQ-R1..R5. Walks a method's statement sequence (recursing into ifTrue:/ifFalse:/ifTrue:ifFalse:/ifFalse:ifTrue:
branches as independent sub-bodies) and reports the set of reachable terminal nodes plus nothing else.
Has no knowledge of the 10 classification checks (REQ-A2).
"
Class {
	#name : 'ARTIReachabilityEngine',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Reachability',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Reachability'
}

{ #category : 'accessing' }
ARTIReachabilityEngine class >> bottomSelectors [
	"Selectors that, when sent standalone to self/super, mean the method never returns normally (REQ-R1)."

	^ #( #error: #halt #subclassResponsibility #shouldNotImplement
	     #notYetImplemented ) asSet
]

{ #category : 'private' }
ARTIReachabilityEngine class >> branchStatementListsOf: aConditionalStatementNode [

	^ aConditionalStatementNode arguments collect: [ :blockNode |
		  blockNode body statements ]
]

{ #category : 'accessing' }
ARTIReachabilityEngine class >> conditionalSelectors [
	"The only branching selectors this version understands (REQ-R2/REQ-R5)."

	^ #( #ifTrue: #ifFalse: #ifTrue:ifFalse: #ifFalse:ifTrue: ) asSet
]

{ #category : 'testing' }
ARTIReachabilityEngine class >> isBottomSendStatement: aStatementNode [

	^ (aStatementNode isKindOf: OCMessageNode) and: [
			  (self bottomSelectors includes: aStatementNode selector) and: [
				  aStatementNode receiver isSelfOrSuperVariable ] ]
]

{ #category : 'testing' }
ARTIReachabilityEngine class >> isSupportedConditionalStatement: aStatementNode [
	"Only literal, zero-argument block arguments are understood; anything else (a boolean variable
	holding a block, caseOf:, to:do:, whileTrue:, ...) is out of scope and treated as an ordinary,
	non-branching statement (REQ-R5)."

	^ (aStatementNode isKindOf: OCMessageNode) and: [
			  (self conditionalSelectors includes: aStatementNode selector)
				  and: [
						  aStatementNode arguments allSatisfy: [ :each |
							  (each isKindOf: OCBlockNode) and: [ each arguments isEmpty ] ] ] ]
]

{ #category : 'testing' }
ARTIReachabilityEngine class >> isTwoArmedConditionalStatement: aStatementNode [

	^ self twoArmedConditionalSelectors includes: aStatementNode selector
]

{ #category : 'computing' }
ARTIReachabilityEngine class >> reachableTerminalsOf: aMethodNode [
	"REQ-R1. Top-level entry point: walks aMethodNode's body and adds an ImplicitEnd terminal iff the
	body does not already terminate on every path."

	| terminals terminates |
	terminals := OrderedCollection new.
	terminates := self
		              walkStatements: aMethodNode body statements
		              into: terminals.
	terminates ifFalse: [
		terminals add: (ARTIImplicitEndTerminal forMethod: aMethodNode) ].
	^ terminals
]

{ #category : 'accessing' }
ARTIReachabilityEngine class >> twoArmedConditionalSelectors [

	^ #( #ifTrue:ifFalse: #ifFalse:ifTrue: ) asSet
]

{ #category : 'computing' }
ARTIReachabilityEngine class >> walkStatements: aStatementCollection into: terminalsCollection [
	"Visits aStatementCollection in order, adding every genuine terminal it finds (explicit returns,
	standalone Bottom-selector sends, and terminals nested inside taken conditional branches) into
	terminalsCollection. Answers whether this statement sequence is guaranteed to terminate, i.e.
	never falls off its own end. Statements following a terminating statement are unreachable and are
	neither visited nor reported (REQ-R3). This method knows nothing about how any terminal will later
	be classified (REQ-A2) -- it only recognizes return / bottom-send / conditional shapes."

	aStatementCollection do: [ :statement |
			statement isReturn ifTrue: [
					terminalsCollection add:
						(ARTIExplicitReturnTerminal on: statement).
					^ true ].

			(self isBottomSendStatement: statement) ifTrue: [
					terminalsCollection add: (ARTIBottomTerminal on: statement).
					^ true ].

			(self isSupportedConditionalStatement: statement) ifTrue: [
					| branchesTerminate |
					branchesTerminate := (self branchStatementListsOf: statement)
						                     collect: [ :branchStatements |
							                     self
								                     walkStatements: branchStatements
								                     into: terminalsCollection ].
					((self isTwoArmedConditionalStatement: statement) and: [
						 branchesTerminate allSatisfy: [ :eachTerminates |
							 eachTerminates ] ]) ifTrue: [ ^ true ] ] ].

	^ false
]
