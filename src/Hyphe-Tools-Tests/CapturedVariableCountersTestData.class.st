Class {
	#name : 'CapturedVariableCountersTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> argumentMethodNotCaptured: n [
    [ n + 1 ] value
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> blockLocalNotCaptured [
    | x |
    x := 1.
    [ :y | y + 1 ] value: x
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> captureVariable [
    | x y |
    x := 1.
    y := 2.
    
    [ x + 1 ] value

 
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> complexCapture [
    | x y z |
    x := 1.
    y := 2.
    z := 3.

    [ 
        x > 0 ifTrue: [
            y + x
        ].
        [ z + 1 ] value
    ] value
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> duplicateUse [
    | x |
    x := 1.
    [ x + x + x ] value
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> ifElseCapture [
    | x y |
    x := 1.
    y := 2.
    x > 0
        ifTrue: [ x + 1 ]
        ifFalse: [ y + 1 ]
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> ifTrueCapture [
    | x |
    x := 1.
    x > 0 ifTrue: [
        x + 1
    ]
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> mixedVariables [
    | x |
    x := 1.
    [ :y | x + y ] value: 2
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> multipleBlocksDifferentVars [
    | x y |
    x := 1.
    y := 2.
    [ x + 1 ] value.
    [ y + 1 ] value
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> multipleBlocksSameVar [
    | x |
    x := 1.
    [ x + 1 ] value.
    [ x + 2 ] value
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> nestedBlockCapture [
    | x |
    x := 1.
    [ 
        [ x + 1 ] value
    ] value
]

{ #category : 'as yet unclassified' }
CapturedVariableCountersTestData >> noCapture [
    [ :x | x + 1 ] value: 5
]
