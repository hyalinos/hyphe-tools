"
A type in the notation of the ground truth: one atom (see HyTypeAtom) or a union of atoms written with | : Integer, r, String | ?, UndefinedObject | a1. Tool results use the same notation, with class names only. Use HyTypeExpression parse: 'String | ?'.
"
Class {
	#name : 'HyTypeExpression',
	#superclass : 'Object',
	#instVars : [
		'atoms'
	],
	#category : 'Hyphe-Experiments-Data',
	#package : 'Hyphe-Experiments',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyTypeExpression class >> atoms: someAtoms [
	"Create a union of atoms, without twice the same one"

	^ self new
		  setAtoms: someAtoms asOrderedCollection removeDuplicates;
		  yourself
]

{ #category : 'instance creation' }
HyTypeExpression class >> classNames: someNames [
	"Create a union of classes from their names"

	^ self atoms: (someNames collect: [ :each | HyTypeAtom named: each ])
]

{ #category : 'instance creation' }
HyTypeExpression class >> parse: aString [
	"Create the type written in aString. Answer nil for nil, an empty string or nil as text: no type."

	| text |
	aString ifNil: [ ^ nil ].
	text := aString trim.
	(text isEmpty or: [ text = 'nil' ]) ifTrue: [ ^ nil ].
	^ self atoms: (('|' split: text) collect: [ :part | HyTypeAtom parse: part ])
]

{ #category : 'comparing' }
HyTypeExpression >> = anObject [
	"Two types are equal when they have the same atoms, in any order"

	^ self class == anObject class and: [ self keys = anObject keys ]
]

{ #category : 'accessing' }
HyTypeExpression >> atoms [
	"Answer the atoms of the union"

	^ atoms
]

{ #category : 'accessing' }
HyTypeExpression >> classNames [
	"Answer the names of the classes written in the type, not including r"

	^ (atoms select: [ :atom | atom isClass ]) collect: [ :atom | atom name ]
]

{ #category : 'testing' }
HyTypeExpression >> hasAbstract [
	"Answer true if ! is in the union"

	^ atoms anySatisfy: [ :atom | atom isAbstract ]
]

{ #category : 'testing' }
HyTypeExpression >> hasArgument [
	"Answer true if the type of an argument is in the union"

	^ atoms anySatisfy: [ :atom | atom isArgument ]
]

{ #category : 'testing' }
HyTypeExpression >> hasReceiver [
	"Answer true if r is in the union"

	^ atoms anySatisfy: [ :atom | atom isReceiver ]
]

{ #category : 'testing' }
HyTypeExpression >> hasUnknown [
	"Answer true if ? is in the union"

	^ atoms anySatisfy: [ :atom | atom isUnknown ]
]

{ #category : 'comparing' }
HyTypeExpression >> hash [
	"Hash of the atoms"

	^ self keys hash
]

{ #category : 'testing' }
HyTypeExpression >> isConcrete [
	"Answer true if the type is made only of class names"

	^ atoms allSatisfy: [ :atom | atom isClass ]
]

{ #category : 'accessing' }
HyTypeExpression >> keys [
	"Answer the atoms as sorted strings, to compare types independently of the order of the union"

	^ (atoms collect: [ :atom | atom printString ]) asSortedCollection asArray
]

{ #category : 'printing' }
HyTypeExpression >> printOn: aStream [
	"Print in the notation of the ground truth: String | ?"

	atoms do: [ :atom | aStream print: atom ] separatedBy: [ aStream nextPutAll: ' | ' ]
]

{ #category : 'accessing' }
HyTypeExpression >> resolvedClassNamesFor: aMethodRef [
	"Answer the set of the class names of the type, where r is the class of the method"

	| names |
	names := Set withAll: self classNames.
	self hasReceiver ifTrue: [ names add: aMethodRef className ].
	^ names
]

{ #category : 'accessing' }
HyTypeExpression >> resolvedFor: aMethodRef [
	"Answer the same type where r is replaced by the class of the method, so that a tool that says r and a tool that says the class agree"

	^ HyTypeExpression atoms: (atoms collect: [ :atom |
				   atom isReceiver
					   ifTrue: [ HyTypeAtom named: aMethodRef className ]
					   ifFalse: [ atom ] ])
]

{ #category : 'initialization' }
HyTypeExpression >> setAtoms: someAtoms [
	"Set the atoms"

	atoms := someAtoms
]
