"
Shape Sandbox fixture -- an unrelated hierarchy (holds shapes; ivars shapes/primaryShape) used for the var-local/real-instantiation, block, and cross-class interprocedural cases the HYISBShape family alone doesn't cover.
"
Class {
	#name : 'HYISBShapeGroup',
	#superclass : 'Object',
	#instVars : [
		'shapes',
		'primaryShape'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'blocks' }
HYISBShapeGroup >> areaBlock [
	"A block literal returned as a value, never invoked during typing -- answers a BlockType; its own parameter s is typed independently of the enclosing method's Gamma."

	^ [ :s | s area ]
]

{ #category : 'accessing' }
HYISBShapeGroup >> describePrimary [
	"Three-hop interprocedural chain crossing classes: reads primaryShape (var-ivar, same class) then sends it describe -- which is HYISBShape>>describe's own polymorphic dispatch, on a completely different hierarchy."

	^ self primaryShape describe
]

{ #category : 'collecting' }
HYISBShapeGroup >> newBasket [
	"var-local holding a real object: | basket | basket := OrderedCollection new. ^ basket -- confirmed live and safe (resolves in well under a second, not a hang) before being run for real through Sigma; see the Shape Sandbox design doc's safety note."

	| basket |
	basket := OrderedCollection new.
	^ basket
]

{ #category : 'accessing' }
HYISBShapeGroup >> primaryShape [
	"var-ivar: reads whatever primaryShape: last assigned."

	^ primaryShape
]

{ #category : 'accessing' }
HYISBShapeGroup >> primaryShape: aShape [
	"assign-ivar: writes the ivar primaryShape/describePrimary read."

	primaryShape := aShape
]

{ #category : 'accessing' }
HYISBShapeGroup >> retype [
	"assign-local overwrites Gamma, not merges: x:=1 then x:='reassigned' -- must read back String only, no trace of the earlier SmallInteger, unlike assign-ivar's merge."

	| x |
	x := 1.
	x := 'reassigned'.
	^ x
]

{ #category : 'blocks' }
HYISBShapeGroup >> riskyBlock [
	"Blocks as the exception (Task 8): the block's BODY contains a Bottom send, but the block is never invoked here -- the enclosing method itself must NOT be Bottom."

	^ [ self error: 'never called directly' ]
]
