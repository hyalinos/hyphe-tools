Class {
	#name : 'BlocCountersTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
BlocCountersTestData >> blockInBlockInMessage [
    ^ [ #(1 2 3) do: [:x | x + 1 ] ]
]

{ #category : 'as yet unclassified' }
BlocCountersTestData >> blockWithReturn [
    ^ [ :x | ^ x + 1 ] value: 5
]

{ #category : 'as yet unclassified' }
BlocCountersTestData >> complexBlocks [
    | result |
    result := #(1 2 3 4) select: [:x |
        x even ifTrue: [
            #(10 20) collect: [:y |
                y + x
            ]
        ] ifFalse: [
            [ x * 2 ] value
        ].
        x > 2
    ].
    
    ^ result collect: [:z |
        z asString
    ]
]

{ #category : 'as yet unclassified' }
BlocCountersTestData >> methodWithBloc [
	| x somme|
	x := { 1, 2 ,3 }.
	somme := 0.
	x do:[:each| 
		somme := somme + each].
	^ somme
	
]

{ #category : 'as yet unclassified' }
BlocCountersTestData >> methodWithoutBloc [
	| x |
	x := 2.
	
]

{ #category : 'as yet unclassified' }
BlocCountersTestData >> twoBloc [
	| filtered |
    filtered := #(1 2 3) select: [:x | x > 1].
    ^ filtered collect: [:x | x * 2]
]
