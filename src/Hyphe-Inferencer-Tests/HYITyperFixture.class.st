"
Fixtures matching unconfident_type_system_full.md's own worked examples (the fact: recursion, the ifTrue:[^true]ifFalse:[^false] example, the cond ifTrue:[^5]. self error:'bad'. example) for Task 7/8 end-to-end tests.
"
Class {
	#name : 'HYITyperFixture',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixture' }
HYITyperFixture >> addOne: x [
	"An ordinary parameter, returned as-is -- the plain var-local/argument case."

	^ x
]

{ #category : 'fixture' }
HYITyperFixture >> alwaysErrors [
	"A bare, unconditional Bottom-producing statement -- the simplest possible Bottom case, matching the canonical family (Sec 3.3.9)."

	self error: 'nope'
]

{ #category : 'fixture' }
HYITyperFixture >> boolBranch [
	"Sec 3.3.9's own worked example: ifTrue:[^true] ifFalse:[^false] -- must type as a branch union, Fixed-NS(True) (+) Fixed-NS(False), not a Conflict."

	true
		ifTrue: [ ^ true ]
		ifFalse: [ ^ false ]
]

{ #category : 'fixture' }
HYITyperFixture >> cascadeTest [
	"self simpleLiteral; returnsSelf -- both applied to self, but only the LAST message's result (returnsSelf's Fixed-S(Self)) matters, not simpleLiteral's."

	^ self
		  simpleLiteral;
		  returnsSelf
]

{ #category : 'fixture' }
HYITyperFixture >> dynArray [
	"A dynamic array literal -- exercises the message-send typing rule on a literal-array-shaped expression."

	^ { 1. 2. 3 }
]

{ #category : 'fixture' }
HYITyperFixture >> errorBranch: cond [
	"One branch reachable and Fixed, the other Bottom -- Sec 3.3.9's own worked example, must type as Fixed-NS(SmallInteger) (+) Bottom, the Bottom-path preserved as a union member rather than dropped."

	cond ifTrue: [ ^ 5 ].
	self error: 'bad'
]

{ #category : 'fixture' }
HYITyperFixture >> factTest: n [
	"Mutually (here, self-) recursive: must not hang Sigma's fixpoint -- the canonical termination test for Task 4's run:."

	^ n = 0
		  ifTrue: [ 1 ]
		  ifFalse: [ n * (self factTest: n - 1) ]
]

{ #category : 'fixture' }
HYITyperFixture >> litArray2 [
	"A literal array (not dynamic) -- a second, distinct literal-shape case alongside simpleLiteral."

	^ #( 1 2 3 )
]

{ #category : 'fixture' }
HYITyperFixture >> noReturn [
	"Assigns a local but never returns it -- implicit end-of-method, should type as the implicit Fixed-S(Self) fallback, not as whatever x was assigned."

	| x |
	x := 1
]

{ #category : 'fixture' }
HYITyperFixture >> returnsSelf [
	"The plain var-self case: ^ self."

	^ self
]

{ #category : 'fixture' }
HYITyperFixture >> selfSendChain [
	"A single self-send to another method of this same class -- the simplest ordinary-message-send case."

	^ self simpleLiteral
]

{ #category : 'fixture' }
HYITyperFixture >> simpleLiteral [
	"The plain literal case: ^ 42."

	^ 42
]
