"
Task 5 fixture, paired with HYIExpandFixtureA -- a subclass overriding shared (returns a different literal) and adding its own selector bar, so AllDefiners/expand(N) has real multi-class content to walk.
"
Class {
	#name : 'HYIExpandFixtureB',
	#superclass : 'HYIExpandFixtureA',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixture' }
HYIExpandFixtureB >> bar [
	"A selector only B defines -- AllDefiners(#bar) should find just this class."

	^ 2
]

{ #category : 'fixture' }
HYIExpandFixtureB >> shared [
	"Overrides A's own with a different literal -- AllDefiners(#shared) should find both classes."

	^ 'from B'
]
