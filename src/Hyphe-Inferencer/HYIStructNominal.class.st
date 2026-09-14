"
tau ::= (S,N): a structural type (selectors: Dictionary of Symbol->HYIMethodType) with an optional nominal class-name string, retained only when S was derived by expand(N). nominal may be nil (an (S,{}) not derived from any class -- reserved, see Sec 2.2's open question; nothing in this codebase currently produces it).
"
Class {
	#name : 'HYIStructNominal',
	#superclass : 'HYIType',
	#instVars : [
		'selectors',
		'nominal'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIStructNominal class >> nominal: aNameOrNil [
	"Constructor for a purely nominal type (a bare class name, no structural selectors) -- the common case."

	^ self selectors: Dictionary new nominal: aNameOrNil
]

{ #category : 'instance creation' }
HYIStructNominal class >> selectors: aDictionary nominal: aNameOrNil [
	"Constructor for a (possibly) structural type: a Dictionary of Symbol->HYIMethodType plus an optional nominal class name, retained only when S was derived by expand(N) on a real class."

	^ self new
		  setSelectors: aDictionary nominal: aNameOrNil;
		  yourself
]

{ #category : 'comparing' }
HYIStructNominal >> = other [
	"Structural equality: same nominal class name (or both anonymous) and the same selector->MethodType structure."

	^ (other isKindOf: HYIStructNominal) and: [ nominal = other nominal and: [ selectors = other selectors ] ]
]

{ #category : 'private' }
HYIStructNominal >> classNamed: aName inheritsFromClassNamed: otherName [
	"Provisional Sec 3.1 nominal subtyping: live class-hierarchy check. Note the spec's own caveat (top of Sec 3): a subclass is not automatically a subtype -- this is a stand-in, to be replaced by expand()-based structural comparison once Task 5/6 build image access."

	| c1 c2 |
	aName = otherName ifTrue: [ ^ true ].
	c1 := Smalltalk at: aName asSymbol ifAbsent: [ ^ false ].
	c2 := Smalltalk at: otherName asSymbol ifAbsent: [ ^ false ].
	^ (c1 isKindOf: Behavior) and: [ (c2 isKindOf: Behavior) and: [ c1 inheritsFrom: c2 ] ]
]

{ #category : 'comparing' }
HYIStructNominal >> hash [
	"Consistent with =: combines the nominal name's hash with the structural selectors' hash."

	^ nominal hash bitXor: selectors hash
]

{ #category : 'testing' }
HYIStructNominal >> isStructNominal [
	"Overrides the abstract root's default false -- this IS the production it names."

	^ true
]

{ #category : 'testing' }
HYIStructNominal >> isSubtypeOf: other [
	"Sec 2.2/3.2.1's subtype check, used by the merge table's b<:a rows. Falls back to real class-hierarchy subtyping (classNamed:inheritsFromClassNamed:) when both sides carry a nominal class name; answers false (not an error) whenever either side is anonymous, since a purely structural type has no class hierarchy to walk."

	(super isSubtypeOf: other) ifTrue: [ ^ true ].
	(other isKindOf: HYIStructNominal) ifFalse: [ ^ false ].
	(nominal isNil or: [ other nominal isNil ]) ifTrue: [ ^ false ].
	^ self classNamed: nominal inheritsFromClassNamed: other nominal
]

{ #category : 'accessing' }
HYIStructNominal >> nominal [
	"Answers the nominal class name string, or nil for a purely anonymous structural type."

	^ nominal
]

{ #category : 'printing' }
HYIStructNominal >> printOn: aStream [
	"Prints as the nominal name (or <anon> if none), followed by [sel: Type, ...] for any structural selectors actually recorded."

	nominal ifNotNil: [ aStream nextPutAll: nominal ] ifNil: [ aStream nextPutAll: '<anon>' ].
	selectors isEmpty ifFalse: [
			aStream nextPutAll: '['.
			(selectors keys asSortedCollection: [ :a :b | a <= b ])
				do: [ :sel |
						aStream
							nextPutAll: sel;
							nextPutAll: ': '.
						(selectors at: sel) printOn: aStream ]
				separatedBy: [ aStream nextPutAll: ', ' ].
			aStream nextPutAll: ']' ]
]

{ #category : 'accessing' }
HYIStructNominal >> selectors [
	"Answers the Dictionary of Symbol->HYIMethodType this structural type carries, empty if the type is purely nominal."

	^ selectors
]

{ #category : 'private' }
HYIStructNominal >> setSelectors: aDictionary nominal: aNameOrNil [
	"Private initializer, called only from the class-side constructors."

	selectors := aDictionary.
	nominal := aNameOrNil
]
