"
AllDefiners(sel) (Sec 3.3.1, Case 3): every class (and metaclass -- a metaclass is an ordinary class, Sec 3.3.2) in the image and kernel that OWN-defines a selector. Built ONCE via buildFromImage (a single scan, timed), then O(1) per lookup via a plain Dictionary. Needed because Case 3 lookup calls AllDefiners on every send whose receiver is Unknown(Top); a linear image scan per call would make the inferencer unusable (TASKS.md Task 5).
"
Class {
	#name : 'HYIDefinerIndex',
	#superclass : 'Object',
	#instVars : [
		'index',
		'buildTimeMs',
		'classCount',
		'methodCount'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIDefinerIndex class >> buildFromImage [
	"Single full-image scan: every class and metaclass, every OWN (not inherited) selector. Timed -- see buildTimeMs/classCount/methodCount, per TASKS.md Task 5's Done-when ('index construction time ... measured and reported')."

	| behaviors builtIndex methodTally elapsedMs |
	behaviors := OrderedCollection new.
	methodTally := 0.
	elapsedMs := [
		             Smalltalk allClasses do: [ :c |
				             behaviors
					             add: c;
					             add: c class ].
		             builtIndex := Dictionary new.
		             behaviors do: [ :b |
				             b selectors do: [ :sel |
						             methodTally := methodTally + 1.
						             (builtIndex at: sel ifAbsentPut: [ OrderedCollection new ]) add: b name asString ] ] ] millisecondsToRun.
	^ self new
		  setIndex: builtIndex
		  buildTimeMs: elapsedMs
		  classCount: behaviors size
		  methodCount: methodTally;
		  yourself
]

{ #category : 'querying' }
HYIDefinerIndex >> allDefiners: aSelector [
	"AllDefiners(sel), Sec 3.3.1 Case 3. O(1): a plain Dictionary lookup into the index built once by buildFromImage."

	^ index at: aSelector asSymbol ifAbsent: [ #(  ) ]
]

{ #category : 'accessing' }
HYIDefinerIndex >> buildTimeMs [
	"How long the one-time whole-image index build took, in milliseconds -- Task 5's Done-when explicitly asks for this to be measured and reported."

	^ buildTimeMs
]

{ #category : 'accessing' }
HYIDefinerIndex >> classCount [
	"How many classes and metaclasses the index was built over."

	^ classCount
]

{ #category : 'accessing' }
HYIDefinerIndex >> methodCount [
	"How many own-defined methods (across all indexed classes and metaclasses) the index was built over."

	^ methodCount
]

{ #category : 'printing' }
HYIDefinerIndex >> report [
	"A one-line human-readable summary of the index build -- classes, methods, distinct selectors, and timing."

	^ String streamContents: [ :s |
			  s
				  nextPutAll: 'HYIDefinerIndex: ';
				  print: classCount;
				  nextPutAll: ' classes+metaclasses, ';
				  print: methodCount;
				  nextPutAll: ' own methods, ';
				  print: self selectorCount;
				  nextPutAll: ' distinct selectors, built in ';
				  print: buildTimeMs;
				  nextPutAll: ' ms' ]
]

{ #category : 'accessing' }
HYIDefinerIndex >> selectorCount [
	"How many distinct selectors AllDefiners can answer for."

	^ index size
]

{ #category : 'private' }
HYIDefinerIndex >> setIndex: aDictionary buildTimeMs: ms classCount: aClassCount methodCount: aMethodCount [
	"Private initializer, called only from the class-side buildFromImage."

	index := aDictionary.
	buildTimeMs := ms.
	classCount := aClassCount.
	methodCount := aMethodCount
]
