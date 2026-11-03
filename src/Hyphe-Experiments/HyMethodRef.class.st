"
Identifies a method of the image by its package, its class and its selector, the way the data files of the experiments do. The class of a class side method is written with the suffix class (OrderedCollection class). Two references are equal when class and selector are equal (the package is only informative). compiledMethod finds the method in the image, nil if it does not exist (any more).
"
Class {
	#name : 'HyMethodRef',
	#superclass : 'Object',
	#instVars : [
		'package',
		'className',
		'selector'
	],
	#category : 'Hyphe-Experiments-Data',
	#package : 'Hyphe-Experiments',
	#tag : 'Data'
}

{ #category : 'instance creation' }
HyMethodRef class >> fromCompiledMethod: aCompiledMethod [
	"Create the reference of a compiled method"

	^ self package: aCompiledMethod package name class: aCompiledMethod methodClass name selector: aCompiledMethod selector
]

{ #category : 'instance creation' }
HyMethodRef class >> fromRecord: aRecord [
	"Create a reference from a record of a CSV file (see HyCsv): the columns package, class and selector, with the names used by the different files of the experiments. Answer nil if there is no class or no selector."

	| class selector |
	class := HyCsv record: aRecord valueAt: #( 'class' 'classname' ).
	selector := HyCsv record: aRecord valueAt: #( 'selector' 'methodselector' 'methodname' 'methodename' ).
	(class isNil or: [ selector isNil ]) ifTrue: [ ^ nil ].
	^ self package: (HyCsv record: aRecord valueAt: #( 'package' )) class: class selector: selector asSymbol
]

{ #category : 'instance creation' }
HyMethodRef class >> package: aPackageName class: aClassName selector: aSelector [
	"Create a reference"

	^ self new
		  setPackage: aPackageName class: aClassName selector: aSelector;
		  yourself
]

{ #category : 'comparing' }
HyMethodRef >> = anObject [
	"Two references are equal when the class and the selector are"

	^ self class == anObject class and: [ className = anObject className and: [ selector = anObject selector ] ]
]

{ #category : 'finding' }
HyMethodRef >> behavior [
	"Answer the class (or metaclass) of the image the method belongs to, nil if there is none"

	^ (Smalltalk globals at: self instanceClassName asSymbol ifAbsent: [ nil ]) ifNotNil: [ :class |
			  self isClassSide
				  ifTrue: [ class class ]
				  ifFalse: [ class ] ]
]

{ #category : 'accessing' }
HyMethodRef >> className [
	"Answer the name of the class, with the suffix class for a class side method"

	^ className
]

{ #category : 'finding' }
HyMethodRef >> compiledMethod [
	"Answer the compiled method this reference names, nil if the class or the method is not in the image"

	^ self behavior ifNotNil: [ :behavior | behavior compiledMethodAt: selector ifAbsent: [ nil ] ]
]

{ #category : 'comparing' }
HyMethodRef >> hash [
	"Hash of the class and of the selector"

	^ className hash bitXor: selector hash
]

{ #category : 'accessing' }
HyMethodRef >> instanceClassName [
	"Answer the name of the class without the suffix class: OrderedCollection for OrderedCollection class"

	^ self isClassSide
		  ifTrue: [ className allButLast: 6 ]
		  ifFalse: [ className ]
]

{ #category : 'testing' }
HyMethodRef >> isClassSide [
	"Answer true if the method is on the class side"

	^ className endsWith: ' class'
]

{ #category : 'accessing' }
HyMethodRef >> package [
	"Answer the name of the package of the method (nil if unknown)"

	^ package
]

{ #category : 'printing' }
HyMethodRef >> printOn: aStream [
	"Print as Class>>#selector"

	aStream
		nextPutAll: className asString;
		nextPutAll: '>>#';
		nextPutAll: selector asString
]

{ #category : 'accessing' }
HyMethodRef >> selector [
	"Answer the selector of the method"

	^ selector
]

{ #category : 'initialization' }
HyMethodRef >> setPackage: aPackageName class: aClassName selector: aSelector [
	"Set the three parts of the reference"

	package := aPackageName.
	className := aClassName.
	selector := aSelector asSymbol
]
