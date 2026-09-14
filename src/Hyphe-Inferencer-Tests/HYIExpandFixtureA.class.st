"
Controlled inheritance fixture for HYIExpanderTest -- deliberately not a kernel class, so the test does not depend on kernel layout that could shift between images.
"
Class {
	#name : 'HYIExpandFixtureA',
	#superclass : 'Object',
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'fixture' }
HYIExpandFixtureA >> foo [
	"A selector only A defines -- AllDefiners(#foo) should find just this class."

	^ 1
]

{ #category : 'fixture' }
HYIExpandFixtureA >> shared [
	"Overridden by HYIExpandFixtureB with a different literal -- AllDefiners(#shared) should find both classes."

	^ 'from A'
]
