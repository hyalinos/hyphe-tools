"
For each message send of a method I tell what the receiver is, and I count the sends per kind of receiver: argument, self, super, literal, local variable, instance variable, class variable, global (a class name...), result of another send, other. Give me a compiled method (the AST needs the bindings of the variables, so a parsed but not compiled method gives wrong answers): ReceiverOriginCounter new receiverSelves: aCompiledMethod, or analyzeMethod: and then receiverSelves, receiverArguments... or profile for all the counts. A cascade counts one send per message. Unlike ReceiverCounter I count receivers of sends, not every variable of the method.
"
Class {
	#name : 'ReceiverOriginCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'counts'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'accessing' }
ReceiverOriginCounter class >> kinds [
	"Answer the kinds of receiver, as the symbols used by #profile"

	^ #( #argument #self #super #literal #localVariable #instanceVariable #classVariable #global #messageResult #other )
]

{ #category : 'analysis' }
ReceiverOriginCounter >> analyzeMethod: aCompiledMethod [
	"Count the receivers of the sends of the method. Answer the receiver, to ask for the counts."

	self reset.
	aCompiledMethod ast acceptVisitor: self
]

{ #category : 'initialization' }
ReceiverOriginCounter >> initialize [
	"Start with all the counts at 0"

	super initialize.
	self reset
]

{ #category : 'analysis' }
ReceiverOriginCounter >> kindOfReceiver: aNode [
	"Answer the kind (see #kinds) of the receiver of a send, from its node"

	aNode isSelfVariable ifTrue: [ ^ #self ].
	aNode isSuperVariable ifTrue: [ ^ #super ].
	aNode isLiteralNode ifTrue: [ ^ #literal ].
	aNode isVariable ifTrue: [
			aNode isArgumentVariable ifTrue: [ ^ #argument ].
			aNode isTempVariable ifTrue: [ ^ #localVariable ].
			aNode isInstanceVariable ifTrue: [ ^ #instanceVariable ].
			aNode isClassVariable ifTrue: [ ^ #classVariable ].
			aNode isGlobalVariable ifTrue: [ ^ #global ].
			^ #other ].
	(aNode isMessage or: [ aNode isCascade ]) ifTrue: [ ^ #messageResult ].
	^ #other
]

{ #category : 'accessing' }
ReceiverOriginCounter >> profile [
	"Answer a copy of the counts: a dictionary kind -> number of sends"

	^ counts copy
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverArguments [
	"Answer the number of sends whose receiver is one of the arguments (of the method or of a block)"

	^ counts at: #argument
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverArguments: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the arguments (of the method or of a block)"

	self analyzeMethod: aCompiledMethod.
	^ self receiverArguments
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverClassVariables [
	"Answer the number of sends whose receiver is one of the class variables (shared variables of a class)"

	^ counts at: #classVariable
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverClassVariables: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the class variables (shared variables of a class)"

	self analyzeMethod: aCompiledMethod.
	^ self receiverClassVariables
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverGlobals [
	"Answer the number of sends whose receiver is one of the global variables, in particular class names"

	^ counts at: #global
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverGlobals: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the global variables, in particular class names"

	self analyzeMethod: aCompiledMethod.
	^ self receiverGlobals
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverInstanceOrClassVariables [
	"Answer the number of sends to an instance variable or to a class variable, which the specification counts together"

	^ self receiverInstanceVariables + self receiverClassVariables
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverInstanceOrClassVariables: aCompiledMethod [
	"Analyze the method and answer the number of sends to an instance or class variable"

	self analyzeMethod: aCompiledMethod.
	^ self receiverInstanceOrClassVariables
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverInstanceVariables [
	"Answer the number of sends whose receiver is one of the instance variables (also the ones of the class side)"

	^ counts at: #instanceVariable
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverInstanceVariables: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the instance variables (also the ones of the class side)"

	self analyzeMethod: aCompiledMethod.
	^ self receiverInstanceVariables
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverLiterals [
	"Answer the number of sends whose receiver is one of the literals (numbers, strings, symbols, literal arrays...)"

	^ counts at: #literal
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverLiterals: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the literals (numbers, strings, symbols, literal arrays...)"

	self analyzeMethod: aCompiledMethod.
	^ self receiverLiterals
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverLocalVariables [
	"Answer the number of sends whose receiver is one of the local variables (temporaries of the method or of a block)"

	^ counts at: #localVariable
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverLocalVariables: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the local variables (temporaries of the method or of a block)"

	self analyzeMethod: aCompiledMethod.
	^ self receiverLocalVariables
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverMessageResults [
	"Answer the number of sends whose receiver is one of the results of another message send or of a cascade"

	^ counts at: #messageResult
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverMessageResults: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the results of another message send or of a cascade"

	self analyzeMethod: aCompiledMethod.
	^ self receiverMessageResults
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverOthers [
	"Answer the number of sends whose receiver is one of the anything else (blocks, thisContext, brace arrays...)"

	^ counts at: #other
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverOthers: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the anything else (blocks, thisContext, brace arrays...)"

	self analyzeMethod: aCompiledMethod.
	^ self receiverOthers
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverSelves [
	"Answer the number of sends whose receiver is one of the self"

	^ counts at: #self
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverSelves: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the self"

	self analyzeMethod: aCompiledMethod.
	^ self receiverSelves
]

{ #category : 'accessing' }
ReceiverOriginCounter >> receiverSupers [
	"Answer the number of sends whose receiver is one of the super"

	^ counts at: #super
]

{ #category : 'analysis' }
ReceiverOriginCounter >> receiverSupers: aCompiledMethod [
	"Analyze the method and answer the number of sends whose receiver is one of the super"

	self analyzeMethod: aCompiledMethod.
	^ self receiverSupers
]

{ #category : 'initialization' }
ReceiverOriginCounter >> reset [
	"Forget the counts of the previous analysis"

	counts := Dictionary new.
	self class kinds do: [ :kind | counts at: kind put: 0 ]
]

{ #category : 'accessing' }
ReceiverOriginCounter >> selfSendRatio [
	"Answer the proportion of the sends whose receiver is self (0 if the method sends nothing). A high ratio means the method is well covered by an AST based inferencer."

	^ self totalSends = 0
		  ifTrue: [ 0 ]
		  ifFalse: [ self receiverSelves / self totalSends ]
]

{ #category : 'analysis' }
ReceiverOriginCounter >> selfSendRatio: aCompiledMethod [
	"Analyze the method and answer the proportion of its sends to self"

	self analyzeMethod: aCompiledMethod.
	^ self selfSendRatio
]

{ #category : 'accessing' }
ReceiverOriginCounter >> totalSends [
	"Answer the number of message sends of the analyzed method"

	^ counts values sum
]

{ #category : 'analysis' }
ReceiverOriginCounter >> totalSends: aCompiledMethod [
	"Analyze the method and answer its number of sends"

	self analyzeMethod: aCompiledMethod.
	^ self totalSends
]

{ #category : 'visiting' }
ReceiverOriginCounter >> visitMessageNode: aMessageNode [
	"Count the receiver of this send, then look inside the receiver and the arguments"

	| kind |
	kind := self kindOfReceiver: aMessageNode receiver.
	counts at: kind put: (counts at: kind) + 1.
	super visitMessageNode: aMessageNode
]
