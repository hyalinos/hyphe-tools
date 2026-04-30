Class {
	#name : 'AssignmentCountersTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> assignmentInBlock [
    | x |
    x := 1.
    [ x := x + 1 ] value.
    ^ x
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> assignmentInIf [
    | x |
    x := 1.
    x > 0 ifTrue: [
        x := x + 1
    ].
    ^ x
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> assignmentInLoop [
    | sum |
    sum := 0.
    #(1 2 3) do: [:x |
        sum := sum + x
    ].
    ^ sum
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> assignmentWithReturn [
    | x |
    x := 5.
    ^ x := x + 1
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> chainedAssignment [
    | x y |
    x := y := 5.
    ^ x + y
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> complexAssignments [
    | x y |
    x := 1.
    y := 2.
    
    x > 0 ifTrue: [
        y := x + y.
        [ x := y * 2 ] value
    ] ifFalse: [
        x := 0
    ].
    
    ^ x + y
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> multipleAssignments [
    | x y z |
    x := 1.
    y := 2.
	 z:= 3.
    ^ x + y
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> nestedBlockAssignment [
    | x |
    x := 0.
    [ 
        [ x := x + 1 ] value
    ] value.
    ^ x
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> noAssignment [
    ^ 1 + 2
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> oneAssignment [
    | x |
    x := 5.
    ^ x
]

{ #category : 'as yet unclassified' }
AssignmentCountersTestData >> reassignment [
    | x |
    x := 1.
    x := x + 1.
    x := x + 2.
    ^ x
]
