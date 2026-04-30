Class {
	#name : 'CascadeCounterTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'as yet unclassified' }
CascadeCounterTestData >> cascadeDifferentReceiver [
    | x |
    x := String new
        addAll: 'Hello';
        addAll: ' World'.
    ^ x
]

{ #category : 'as yet unclassified' }
CascadeCounterTestData >> cascadeWithYourself [
    ^ OrderedCollection new
        add: 1;
        add: 2;
        yourself
]

{ #category : 'as yet unclassified' }
CascadeCounterTestData >> multipleCascades [
    | x |
    x := OrderedCollection new
        add: 1;
        add: 2;
        add: 3.
    ^ x size
]

{ #category : 'as yet unclassified' }
CascadeCounterTestData >> nestedCascade [
    | x |
    x := OrderedCollection new.
    x add: (OrderedCollection new
                add: 1;
                add: 2;
                yourself).
    ^ x size
]

{ #category : 'as yet unclassified' }
CascadeCounterTestData >> noCascade [
    | x |
    x := OrderedCollection new.
    x add: 1.
    x add: 2.
    ^ x size
]

{ #category : 'as yet unclassified' }
CascadeCounterTestData >> oneCascade [
    | x |
    x := OrderedCollection new
        add: 1;
        add: 2.
    ^ x size
]

{ #category : 'as yet unclassified' }
CascadeCounterTestData >> separateCascades [
    | x y |
    x := OrderedCollection new
        add: 1;
        add: 2.

    y := OrderedCollection new
        add: 3;
        add: 4;
        add: 5.

    ^ x size + y size
]
