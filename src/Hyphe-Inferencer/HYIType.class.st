"
I am the abstract root of the tau (structural/nominal type) grammar, Sec 2.2 of unconfident_type_system_full.md: tau ::= (S,N) | tau<tau_i> | tau or tau | MethodType | BlockType | Top | Bottom. Concrete subclasses: HYIStructNominal, HYIUnion, HYIGeneric, HYIMethodType, HYIBlockType, HYITypeVar, HYISelfRef, HYISelfClassRef, HYITop, HYIBottom. TypeVar/self/self class are ArgType/ReturnType productions in the spec; here they are folded into the tau hierarchy itself so a MethodType's argTypes/returnType can uniformly hold any HYIType.
"
Class {
	#name : 'HYIType',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'operations' }
HYIType >> branchUnion: other [
	"The (+) operator (Task 3), invoked with the receiver as the left tau -- dispatches to the class-side implementation, which is where the real branch-union logic lives."

	^ HYITypeResult branchUnion: self with: other
]

{ #category : 'testing' }
HYIType >> isBlockType [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isBottom [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isCand [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isConflict [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isGeneric [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isMethodType [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isSelfClassRef [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isSelfRef [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isStructNominal [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'typing' }
HYIType >> isSubtypeOf: other [
	"Sec 3.1's axioms: ref/top/bot, plus or-left/or-right (X <: (A or B) if X <: A or X <: B) generically for every tau. Also a targeted addition found necessary by Task 9's real tool integration: any concrete tau is treated as consistent with (a subtype of) an unresolved Self -- see the class comment note below. Concrete subclasses (HYIStructNominal, HYIUnion) refine this further; the real expand()-based structural subtyping of Sec 3.1 is Task 5/6 territory, still provisional here."

	other isTop ifTrue: [ ^ true ].
	other isSelfRef ifTrue: [ ^ true ].
	self isBottom ifTrue: [ ^ true ].
	self = other ifTrue: [ ^ true ].
	other isUnion ifTrue: [ ^ other members anySatisfy: [ :m | self isSubtypeOf: m ] ].
	^ false
]

{ #category : 'testing' }
HYIType >> isTop [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isTypeVar [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isTypeVariant [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'testing' }
HYIType >> isUnion [
	"Type-check predicate, Sec 2.2's tau grammar -- false by default here on the abstract root; the one production this actually names overrides it to true."

	^ false
]

{ #category : 'operations' }
HYIType >> ~ other [
	"The ~ operator (Task 2), invoked with the receiver as one operand -- dispatches to the class-side implementation, which is where the real evidence-merge logic lives."

	^ HYITypeResult merge: self with: other
]
