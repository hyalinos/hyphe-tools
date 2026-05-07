Class {
	#name : 'NilDensityTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
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

{ #category : 'as yet unclassified' }
NilDensityTestData >> methodWithIfNil [
    | x |
    
    x ifNil: [ x := 10 ].
    
    ^ x
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
