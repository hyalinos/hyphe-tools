"
Methods with 2 and 3 explicit returns, for the tests of the experiments (groups by number of return points).
"
Class {
	#name : 'HYEReturnPointsTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Experiments-Tests',
	#package : 'Hyphe-Experiments-Tests'
}

{ #category : 'fixture' }
HYEReturnPointsTestData >> threeReturns: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 1 ].
	x ifFalse: [ ^ 2 ].
	^ 3
]

{ #category : 'fixture' }
HYEReturnPointsTestData >> threeReturnsAgain: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 'a' ].
	x ifFalse: [ ^ 'b' ].
	^ 'c'
]

{ #category : 'fixture' }
HYEReturnPointsTestData >> twoReturns: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 1 ].
	^ 2
]

{ #category : 'fixture' }
HYEReturnPointsTestData >> twoReturnsAgain: x [
	"Fixture of the tests of the return points experiment (fixture): it is analyzed, never run."

	x ifTrue: [ ^ 'a' ].
	^ 'b'
]
