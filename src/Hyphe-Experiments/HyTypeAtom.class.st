"
One element of a type in the notation of the ground truth: a class name (String), r (the type of the receiver, i.e. the method returns self), a or a1, a2... a_n (the type of an argument: of the n-th one, or of an unspecified one when there is no number), ? (the type could not be determined: polymorphic, or depends on the context) and ! (no type to give: the method is abstract, or a primitive). The kind is one of #class #receiver #argument #unknown #abstract.
"
Class {
	#name : 'HyTypeAtom',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'name',
		'index'
	],
	#category : 'Hyphe-Experiments-Data',
	#package : 'Hyphe-Experiments',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyTypeAtom class >> abstract [
	"Create the atom of a method with no type to give (abstract, primitive)"

	^ self new setKind: #abstract name: nil index: nil
]

{ #category : 'instance creation' }
HyTypeAtom class >> argument: anIndexOrNil [
	"Create the atom of the type of an argument, of the one at the index, or of an unspecified one (nil)"

	^ self new setKind: #argument name: nil index: anIndexOrNil
]

{ #category : 'instance creation' }
HyTypeAtom class >> named: aClassName [
	"Create the atom of a class"

	^ self new setKind: #class name: aClassName index: nil
]

{ #category : 'instance creation' }
HyTypeAtom class >> parse: aString [
	"Create the atom written in the notation of the ground truth: a class name, r, a, a1, a_2, ? or !. A leading # (symbol syntax of the tool results) is ignored."

	| text digits |
	text := aString trim.
	(text beginsWith: '#') ifTrue: [ text := text allButFirst ].
	text = '?' ifTrue: [ ^ self unknown ].
	text = '!' ifTrue: [ ^ self abstract ].
	text = 'r' ifTrue: [ ^ self receiver ].
	text = 'a' ifTrue: [ ^ self argument: nil ].
	(text size > 1 and: [ text first = $a ]) ifTrue: [
			digits := text allButFirst copyWithout: $_.
			(digits isNotEmpty and: [ digits allSatisfy: #isDigit ]) ifTrue: [ ^ self argument: digits asInteger ] ].
	^ self named: text
]

{ #category : 'instance creation' }
HyTypeAtom class >> receiver [
	"Create the atom of the type of the receiver (the method returns self)"

	^ self new setKind: #receiver name: nil index: nil
]

{ #category : 'instance creation' }
HyTypeAtom class >> unknown [
	"Create the atom of an undeterminable type"

	^ self new setKind: #unknown name: nil index: nil
]

{ #category : 'comparing' }
HyTypeAtom >> = anObject [
	"Atoms are equal when kind, name and index are"

	^ self class == anObject class and: [ kind = anObject kind and: [ name = anObject name and: [ index = anObject index ] ] ]
]

{ #category : 'comparing' }
HyTypeAtom >> hash [
	"Hash of the parts"

	^ (kind hash bitXor: name hash) bitXor: index hash
]

{ #category : 'accessing' }
HyTypeAtom >> index [
	"Answer the number of the argument of an argument atom, nil when it is not specified"

	^ index
]

{ #category : 'testing' }
HyTypeAtom >> isAbstract [
	"Answer true if the atom is no type (abstract or primitive method)"

	^ kind = #abstract
]

{ #category : 'testing' }
HyTypeAtom >> isArgument [
	"Answer true if the atom is the type of an argument"

	^ kind = #argument
]

{ #category : 'testing' }
HyTypeAtom >> isClass [
	"Answer true if the atom is a class name"

	^ kind = #class
]

{ #category : 'testing' }
HyTypeAtom >> isReceiver [
	"Answer true if the atom is the type of the receiver"

	^ kind = #receiver
]

{ #category : 'testing' }
HyTypeAtom >> isUnknown [
	"Answer true if the atom is an undeterminable type"

	^ kind = #unknown
]

{ #category : 'accessing' }
HyTypeAtom >> kind [
	"Answer the kind: #class #receiver #argument #unknown or #abstract"

	^ kind
]

{ #category : 'accessing' }
HyTypeAtom >> name [
	"Answer the class name of a class atom, nil for the other kinds"

	^ name
]

{ #category : 'printing' }
HyTypeAtom >> printOn: aStream [
	"Print in the notation of the ground truth"

	kind = #class ifTrue: [ ^ aStream nextPutAll: name ].
	kind = #receiver ifTrue: [ ^ aStream nextPut: $r ].
	kind = #unknown ifTrue: [ ^ aStream nextPut: $? ].
	kind = #abstract ifTrue: [ ^ aStream nextPut: $! ].
	aStream nextPut: $a.
	index ifNotNil: [ aStream print: index ]
]

{ #category : 'initialization' }
HyTypeAtom >> setKind: aKind name: aName index: anIndex [
	"Set the parts of the atom"

	kind := aKind.
	name := aName.
	index := anIndex
]
