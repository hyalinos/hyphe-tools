Class {
	#name : 'NilDensityTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodNil [
	| x y z|
	(z == nil) ifTrue: [ ^ x :=0 ].
	x ifNil: [ ^ y := 2 ].
	y isNil.

	
]

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodWithEqualityNil [
    | z |
    
    (z == nil) ifTrue: [ ^ 0 ].
    
    ^ z
]

{ #category : 'data' }
NilDensityTestData >> methodWithEqualsNil [
	| x |
	x = nil ifTrue: [ ^ 0 ].
	^ x
]

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodWithIfNil [
    | x |
    
    x ifNil: [ x := 10 ].
    
    ^ x
]

{ #category : 'data' }
NilDensityTestData >> methodWithIfNilIfNotNil [
	| x |
	^ x ifNil: [ 0 ] ifNotNil: [ :v | v ]
]

{ #category : 'data' }
NilDensityTestData >> methodWithIfNotNil [
	| x |
	x ifNotNil: [ :v | ^ v ].
	^ 0
]

{ #category : 'data' }
NilDensityTestData >> methodWithIfNotNilIfNil [
	| x |
	^ x ifNotNil: [ :v | v ] ifNil: [ 0 ]
]

{ #category : 'data' }
NilDensityTestData >> methodWithIsNotNil [
	| x |
	x isNotNil ifTrue: [ ^ 1 ].
	^ 0
]

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodWithMultipleNilChecks [
    | x y z |
    
    x ifNil: [ x := 0 ].
    
    y notNil ifTrue: [
        z := y
    ].
    
    z == nil ifTrue: [ ^ -1 ].
    
    ^ z
]

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodWithNestedNilChecks [
    | x y |
    
    x ifNil: [
        y isNil ifTrue: [
            ^ nil
        ]
    ].
    
    ^ x
]

{ #category : 'data' }
NilDensityTestData >> methodWithNilOnTheLeft [
	| x |
	nil == x ifTrue: [ ^ 0 ].
	^ x
]

{ #category : 'data' }
NilDensityTestData >> methodWithNilValuesOnly [
	| x |
	x := nil.
	^ nil
]

{ #category : 'data' }
NilDensityTestData >> methodWithNotEqualNil [
	| x |
	x ~= nil ifTrue: [ ^ 1 ].
	^ 0
]

{ #category : 'data' }
NilDensityTestData >> methodWithNotIdenticalNil [
	| x |
	x ~~ nil ifTrue: [ ^ 1 ].
	^ 0
]

{ #category : 'data' }
NilDensityTestData >> methodWithNotNil [
	| x |
	x notNil ifTrue: [ ^ 1 ].
	^ 0
]

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodWithSingleIsNil [
    | x |
    
    x isNil ifTrue: [ ^ 0 ].
    
    ^ x
]

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodWithoutNil [
    | x y |
    
    x := 1.
    y := x + 2.
    
    ^ y
]
