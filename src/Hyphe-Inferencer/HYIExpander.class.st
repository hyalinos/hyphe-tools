"
expand(N) (Sec 3.1): the structural view of a class, computed on demand and NOT stored/cached persistently (unlike HYIDefinerIndex) -- expand(N) = methods(N) union (expand(superclass(N)) minus overridden(N)). Returns a plain Dictionary Symbol->String(definer class name); this is the reflective/image-access layer only -- it does not know about Sigma or produce HYIMethodType values (that cross-referencing belongs to Task 6's Lookup, which has both expand/AllDefiners and Sigma in scope).
"
Class {
	#name : 'HYIExpander',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'expanding' }
HYIExpander class >> expand: aClassName [
	"Public entry point, Sec 3.1: aClassName may name an ordinary class or a metaclass ('Foo class'), per Sec 3.3.2's 'a metaclass is an ordinary class' decision. Answers Dictionary Symbol->String(definer class name)."

	| behavior |
	behavior := self resolveClassNamed: aClassName.
	behavior ifNil: [ ^ self error: 'HYIExpander class>>expand: unknown class ' , aClassName ].
	^ self expandBehavior: behavior
]

{ #category : 'expanding' }
HYIExpander class >> expandBehavior: aBehavior [
	"expand(N) = methods(N) union (expand(superclass(N)) minus overridden(N)) -- Sec 3.1. Own selectors are written LAST so they correctly shadow (override) same-named inherited entries. Recomputed on every call, not cached (Task 5's 'not stored') -- only AllDefiners is a persistent index."

	| result |
	result := Dictionary new.
	aBehavior superclass ifNotNil: [ result addAll: (self expandBehavior: aBehavior superclass) ].
	aBehavior selectors do: [ :sel | result at: sel put: aBehavior name asString ].
	^ result
]

{ #category : 'expanding' }
HYIExpander class >> nearestDefinerOf: aClassName selector: aSelector [
	"The single-selector counterpart to expand: -- walks aClassName's own superclass chain (not the whole structural map) looking for the nearest OWN definer of aSelector. Used by Task 6's Lookup, which needs one selector at a time, not a class's whole shape."

	| behavior sel |
	behavior := self resolveClassNamed: aClassName.
	behavior ifNil: [ ^ nil ].
	sel := aSelector asSymbol.
	[ behavior notNil ] whileTrue: [
			(behavior includesSelector: sel) ifTrue: [ ^ behavior name asString ].
			behavior := behavior superclass ].
	^ nil
]

{ #category : 'private' }
HYIExpander class >> resolveClassNamed: aString [
	"A metaclass name (e.g. 'Foo class') is not itself a Smalltalk global -- resolve the instance-side class first, then take its metaclass."

	(aString endsWith: ' class') ifTrue: [
			| base |
			base := Smalltalk at: (aString copyFrom: 1 to: aString size - 6) asSymbol ifAbsent: [ ^ nil ].
			^ base class ].
	^ Smalltalk at: aString asSymbol ifAbsent: [ nil ]
]
