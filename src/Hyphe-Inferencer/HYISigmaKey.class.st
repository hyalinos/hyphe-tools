"
The key of Sigma (Sec 3.3.2): (C, sel), where a metaclass is an ordinary class (className may already read e.g. 'Foo class') -- no separate side field. className/selector are Strings.
"
Class {
	#name : 'HYISigmaKey',
	#superclass : 'Object',
	#instVars : [
		'className',
		'selector'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYISigmaKey class >> class: aClassName selector: aSelector [
	"Constructor for the (C,sel) key Sigma is keyed by (Sec 3.3.2)."

	^ self new
		  setClassName: aClassName selector: aSelector;
		  yourself
]

{ #category : 'comparing' }
HYISigmaKey >> = other [
	"Equality is by (className, selector) pair -- a metaclass method's key already has ' class' folded into its className string, so no separate classSide field is needed."

	^ (other isKindOf: HYISigmaKey) and: [ className = other className and: [ selector = other selector ] ]
]

{ #category : 'accessing' }
HYISigmaKey >> className [
	"Answers the class name string -- 'Foo class' for a class-side method's key, plain 'Foo' for instance-side."

	^ className
]

{ #category : 'comparing' }
HYISigmaKey >> hash [
	"Consistent with =."

	^ className hash bitXor: selector hash
]

{ #category : 'printing' }
HYISigmaKey >> printOn: aStream [
	"Prints as ClassName>>#selector."

	aStream
		nextPutAll: className;
		nextPutAll: '>>#';
		nextPutAll: selector
]

{ #category : 'accessing' }
HYISigmaKey >> selector [
	"Answers the selector Symbol."

	^ selector
]

{ #category : 'private' }
HYISigmaKey >> setClassName: aClassName selector: aSelector [
	"Private initializer, called only from the class-side constructor."

	className := aClassName asString.
	selector := aSelector asSymbol
]
