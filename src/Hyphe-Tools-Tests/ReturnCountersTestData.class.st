Class {
	#name : 'ReturnCountersTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
ReturnCountersTestData >> ifReturns [
    ^ (1 > 0
        ifTrue: [ ^ 1 ]
        ifFalse: [ ^ 2 ])
]

{ #category : 'as yet unclassified' }
ReturnCountersTestData >> multipleReturns [
    1 > 0 ifTrue: [ ^ 1 ].
    ^ 2
]

{ #category : 'as yet unclassified' }
ReturnCountersTestData >> noReturn [
    1 + 2
]

{ #category : 'as yet unclassified' }
ReturnCountersTestData >> oneReturn [
    ^ 1 + 2
]

{ #category : 'as yet unclassified' }
ReturnCountersTestData >> returnBoth [
    [ ^ 1 ] value.
    ^ 2
]

{ #category : 'as yet unclassified' }
ReturnCountersTestData >> returnInCollect [
    ^ #(1 2 3) collect: [:x |
        x > 1 ifTrue: [ ^ x ].
        x
    ]
]

{ #category : 'as yet unclassified' }
ReturnCountersTestData >> trickyReturns [
    [ :x |
        x > 0 ifTrue: [ ^ x ].
        [ ^ x + 1 ] value
    ] value: 5.
    ^ 10
]
