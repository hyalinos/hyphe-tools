"
I count the distinct classes of the receivers of the sends of a method (fan-out), as far as static analysis can tell: self is the class of the method, super its superclass, a class name receives as its metaclass (OrderedCollection new: OrderedCollection class), a literal is an instance of its class, and the result of ClassName new is an instance of ClassName. The other receivers (variables, results of other sends) cannot be resolved without type inference, they are counted in unresolvedReceivers. Use: FanOutCounter new fanOutIn: aCompiledMethod.
"
Class {
	#name : 'FanOutCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'method',
		'receiverClasses',
		'unresolvedReceivers'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'analysis' }
FanOutCounter >> analyzeMethod: aCompiledMethod [
	"Resolve the receivers of the sends of the method. Answer the receiver."

	method := aCompiledMethod.
	receiverClasses := Set new.
	unresolvedReceivers := 0.
	aCompiledMethod ast acceptVisitor: self
]

{ #category : 'private' }
FanOutCounter >> classNameOfReceiver: aNode [
	"Answer the name of the class of the receiver, nil if it cannot be told statically"

	aNode isSelfVariable ifTrue: [ ^ method methodClass name ].
	aNode isSuperVariable ifTrue: [ ^ method methodClass superclass ifNotNil: [ :superclass | superclass name ] ].
	aNode isLiteralNode ifTrue: [ ^ aNode value class name ].
	(aNode isVariable and: [ aNode isGlobalVariable and: [ aNode binding value isBehavior ] ]) ifTrue: [
		^ aNode binding value class name ].
	(aNode isMessage and: [ #( #new #basicNew #new: #basicNew: ) includes: aNode selector ]) ifTrue: [
			(aNode receiver isVariable and: [ aNode receiver isGlobalVariable and: [ aNode receiver binding value isBehavior ] ]) ifTrue: [
				^ aNode receiver binding value name ] ].
	^ nil
]

{ #category : 'accessing' }
FanOutCounter >> fanOut [
	"Answer the number of distinct classes of the receivers that could be resolved"

	^ receiverClasses size
]

{ #category : 'analysis' }
FanOutCounter >> fanOutIn: aCompiledMethod [
	"Answer the number of distinct classes of the receivers that could be resolved"

	self analyzeMethod: aCompiledMethod.
	^ receiverClasses size
]

{ #category : 'initialization' }
FanOutCounter >> initialize [
	"Start with no receiver"

	super initialize.
	receiverClasses := Set new.
	unresolvedReceivers := 0
]

{ #category : 'accessing' }
FanOutCounter >> receiverClasses [
	"Answer the names of the classes of the receivers that could be resolved"

	^ receiverClasses copy
]

{ #category : 'analysis' }
FanOutCounter >> receiverClassesIn: aCompiledMethod [
	"Answer the names of the classes of the receivers that could be resolved"

	self analyzeMethod: aCompiledMethod.
	^ receiverClasses copy
]

{ #category : 'accessing' }
FanOutCounter >> unresolvedReceivers [
	"Answer the number of sends whose receiver class cannot be told statically"

	^ unresolvedReceivers
]

{ #category : 'visiting' }
FanOutCounter >> visitMessageNode: aMessageNode [
	"Resolve the receiver of this send if possible, then look inside"

	(self classNameOfReceiver: aMessageNode receiver)
		ifNil: [ unresolvedReceivers := unresolvedReceivers + 1 ]
		ifNotNil: [ :name | receiverClasses add: name ].
	super visitMessageNode: aMessageNode
]
