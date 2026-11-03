"
I count the distinct classes a method knows (CBO, Coupling Between Objects, at method level), the more it names concrete classes the less polymorphic it is. I count: the classes the method names (OrderedCollection new), the classes of its literals (3 is a SmallInteger, 'a' a String, #(1) an Array; nil, true and false are not counted), and the class that self new / super new instantiates. Use: ClassReferencesCounter new countIn: aCompiledMethod; classesIn: gives the names, explicitClasses, literalClasses and implicitClasses split them.
"
Class {
	#name : 'ClassReferencesCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'method',
		'explicitClasses',
		'literalClasses',
		'implicitClasses'
	],
	#category : 'Hyphe-Analysis-StaticAnalysis',
	#package : 'Hyphe-Analysis',
	#tag : 'StaticAnalysis'
}

{ #category : 'analysis' }
ClassReferencesCounter >> analyzeMethod: aCompiledMethod [
	"Collect the classes the method refers to. Answer the receiver."

	method := aCompiledMethod.
	explicitClasses := Set new.
	literalClasses := Set new.
	implicitClasses := Set new.
	aCompiledMethod ast acceptVisitor: self
]

{ #category : 'accessing' }
ClassReferencesCounter >> classes [
	"Answer the names of all the classes the method refers to"

	^ explicitClasses union: (literalClasses union: implicitClasses)
]

{ #category : 'analysis' }
ClassReferencesCounter >> classesIn: aCompiledMethod [
	"Answer the names of the classes the method refers to"

	self analyzeMethod: aCompiledMethod.
	^ self classes
]

{ #category : 'accessing' }
ClassReferencesCounter >> count [
	"Answer the number of distinct classes the method refers to"

	^ self classes size
]

{ #category : 'analysis' }
ClassReferencesCounter >> countIn: aCompiledMethod [
	"Answer the number of distinct classes the method refers to (CBO at method level)"

	self analyzeMethod: aCompiledMethod.
	^ self count
]

{ #category : 'accessing' }
ClassReferencesCounter >> explicitClasses [
	"Answer the names of the classes written in the method"

	^ explicitClasses copy
]

{ #category : 'accessing' }
ClassReferencesCounter >> implicitClasses [
	"Answer the name of the class instantiated by self new or super new, if any"

	^ implicitClasses copy
]

{ #category : 'initialization' }
ClassReferencesCounter >> initialize [
	"Start with no class"

	super initialize.
	explicitClasses := Set new.
	literalClasses := Set new.
	implicitClasses := Set new
]

{ #category : 'accessing' }
ClassReferencesCounter >> literalClasses [
	"Answer the names of the classes of the literals of the method"

	^ literalClasses copy
]

{ #category : 'visiting' }
ClassReferencesCounter >> visitLiteralArrayNode: aLiteralArrayNode [
	"A literal array is an instance of Array (or ByteArray), and so are its elements"

	literalClasses add: aLiteralArrayNode value class name.
	super visitLiteralArrayNode: aLiteralArrayNode
]

{ #category : 'visiting' }
ClassReferencesCounter >> visitLiteralNode: aLiteralNode [
	"A literal is an instance of a class, except nil, true and false, which are constants of the language"

	| value |
	value := aLiteralNode value.
	(value isNil or: [ value == true or: [ value == false ] ]) ifFalse: [ literalClasses add: value class name ].
	super visitLiteralNode: aLiteralNode
]

{ #category : 'visiting' }
ClassReferencesCounter >> visitMessageNode: aMessageNode [
	"self new and super new instantiate the class of the method (the instance side one, if the method is on the class side)"

	((#( #new #basicNew #new: #basicNew: ) includes: aMessageNode selector) and: [
		 aMessageNode receiver isSelfVariable or: [ aMessageNode receiver isSuperVariable ] ]) ifTrue: [
			implicitClasses add: (method methodClass isClassSide
					 ifTrue: [ method methodClass soleInstance name ]
					 ifFalse: [ method methodClass name ]) ].
	super visitMessageNode: aMessageNode
]

{ #category : 'visiting' }
ClassReferencesCounter >> visitVariableNode: aVariableNode [
	"A global variable that holds a class (or a trait) is a class name"

	(aVariableNode isGlobalVariable and: [ aVariableNode binding value isBehavior ]) ifTrue: [
		explicitClasses add: aVariableNode binding value name ].
	super visitVariableNode: aVariableNode
]
