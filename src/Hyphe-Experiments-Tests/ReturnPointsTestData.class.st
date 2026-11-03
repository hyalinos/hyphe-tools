"
Methods with 2 and 3 explicit returns, for the tests of the experiments (groups by number of return points).
"
Class {
	#name : 'ReturnPointsTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Experiments-Tests',
	#package : 'Hyphe-Experiments-Tests'
}

{ #category : 'fixture' }
ReturnPointsTestData >> threeReturns: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 1 ].
	x ifFalse: [ ^ 2 ].
	^ 3
]

{ #category : 'fixture' }
ReturnPointsTestData >> threeReturnsAgain: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 'a' ].
	x ifFalse: [ ^ 'b' ].
	^ 'c'
]

{ #category : 'fixture' }
ReturnPointsTestData >> twoReturns: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 1 ].
	^ 2
]

{ #category : 'fixture' }
ReturnPointsTestData >> twoReturnsAgain: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 'a' ].
	^ 'b'
]
