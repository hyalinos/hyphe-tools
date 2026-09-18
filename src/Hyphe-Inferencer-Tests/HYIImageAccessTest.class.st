"
Task 5: HYIDefinerIndex (AllDefiners) and HYIExpander (expand(N)) tests. Done-when (TASKS.md): AllDefiners is O(1) after indexing, and index construction time over a full image is measured and reported.
"
Class {
	#name : 'HYIImageAccessTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'tests' }
HYIImageAccessTest >> testAllDefinersFindsRealKnownDefiners [
	"AllDefiners(#printOn:) finds the real defining class (Object) and correctly excludes a class that merely inherits it (SmallInteger) rather than owning it."

	| idx definers |
	idx := HYIDefinerIndex buildFromImage.
	definers := idx allDefiners: #printOn:.
	self assert: (definers includes: 'Object').
	self
		assert: (definers includes: 'SmallInteger') not
		description: 'SmallInteger does not override printOn: -- Object is the definer'
]

{ #category : 'tests' }
HYIImageAccessTest >> testAllDefinersIncludesBothInstanceAndClassSideDefiners [
	"AllDefiners covers class-side definers too (a metaclass is an ordinary class, Sec 3.3.2) -- #new on 'SmallInteger class' is found alongside instance-side #printOn: on 'Object'."

	| idx |
	idx := HYIDefinerIndex buildFromImage.
	self assert: ((idx allDefiners: #new) includes: 'SmallInteger class').
	self assert: ((idx allDefiners: #printOn:) includes: 'Object')
]

{ #category : 'tests' }
HYIImageAccessTest >> testAllDefinersIsFastAfterIndexingProxyForO1 [
	"Not a formal complexity proof -- a practical proxy: many repeated lookups
	after indexing must stay fast (no per-call image rescan), per Task 5's
	Done-when (AllDefiners is O(1) after indexing)."

	| idx ms |
	idx := HYIDefinerIndex buildFromImage.
	ms := [ 1 to: 5000 do: [ :i | idx allDefiners: #printOn: ] ] millisecondsToRun.
	self assert: ms < 200 description: '5000 O(1) lookups took ' , ms printString , ' ms -- too slow for a hash lookup'
]

{ #category : 'tests' }
HYIImageAccessTest >> testAllDefinersOnANonexistentSelectorIsEmptyNotAnError [
	"A selector nothing in the image defines answers an empty collection, not an error."

	| idx |
	idx := HYIDefinerIndex buildFromImage.
	self assert: (idx allDefiners: #thisSelectorSurelyDoesNotExistAnywhereXYZ123) isEmpty
]

{ #category : 'tests' }
HYIImageAccessTest >> testExpandHandlesMetaclassNamesCorrectly [
	"expand(N) accepts a metaclass name string ('Foo class') directly and answers its class-side structural view."

	| result |
	result := HYIExpander expand: 'HYIExpandFixtureB class'.
	self assert: result notEmpty.
	self assert: (HYIExpander expand: 'HYIExpandFixtureA class') notEmpty
]

{ #category : 'tests' }
HYIImageAccessTest >> testExpandIncludesOwnAndInheritedSelectorsWithCorrectDefiners [
	"expand('HYIExpandFixtureB') includes both its own selector (bar) and an inherited one (foo), correctly attributed to whichever class actually defines each."

	| result |
	result := HYIExpander expand: 'HYIExpandFixtureB'.
	self assert: (result at: #foo) equals: 'HYIExpandFixtureA'.
	self assert: (result at: #bar) equals: 'HYIExpandFixtureB'
]

{ #category : 'tests' }
HYIImageAccessTest >> testExpandOfTheRootFixtureDoesNotSeeSubclassSelectors [
	"expand() only ever looks upward/at the class itself, never downward into subclasses -- A's own structural view has no knowledge of B's selectors."

	| resultA |
	resultA := HYIExpander expand: 'HYIExpandFixtureA'.
	self assert: (resultA includesKey: #bar) not description: 'a superclass''s expand() must not see its subclass''s own methods'
]

{ #category : 'tests' }
HYIImageAccessTest >> testExpandOnUnknownClassNameRaisesRatherThanSilentlyReturningEmpty [
	"A typo'd or nonexistent class name is a real error, not silently treated as 'no structure'."

	self should: [ HYIExpander expand: 'ThisClassDefinitelyDoesNotExist12345' ] raise: Error
]

{ #category : 'tests' }
HYIImageAccessTest >> testExpandOverriddenSelectorShowsTheSubclassAsDefiner [
	"When B overrides A's shared, each class's own expand() correctly attributes the selector to itself, not to the ancestor."

	| resultA resultB |
	resultA := HYIExpander expand: 'HYIExpandFixtureA'.
	resultB := HYIExpander expand: 'HYIExpandFixtureB'.
	self assert: (resultA at: #shared) equals: 'HYIExpandFixtureA'.
	self assert: (resultB at: #shared) equals: 'HYIExpandFixtureB'
]

{ #category : 'tests' }
HYIImageAccessTest >> testIndexConstructionIsMeasuredAndReported [
	"Task 5's Done-when: building the whole-image index over a real (thousands-of-classes) image is measured, and the timing shows up in its own report."

	| idx |
	idx := HYIDefinerIndex buildFromImage.
	self assert: idx buildTimeMs >= 0.
	self assert: idx classCount > 1000.
	self assert: idx methodCount > 1000.
	self assert: idx selectorCount > 1000.
	self assert: (idx report includesSubstring: 'ms')
]
