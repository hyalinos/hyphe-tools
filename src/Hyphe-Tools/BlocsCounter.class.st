"
* numberOfBlocIn: 

I calculate the total amount of the bloc in a method
To run this code:
- use a 'method:=  aClass >> aMethod ' as argument of the method who calculate the amount of bloc:
   numberOfBlocIn: method.

* maxDephBlocInMethod:

I calculate the max the depth of nested block closures within a method.
"
Class {
	#name : 'BlocsCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'blocNumber',
		'blockStack',
		'blockCounts'
	],
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'as yet unclassified' }
BlocsCounter >> dephBlocInMethod: aMethod [
	 aMethod ast acceptVisitor: self.
	 ^ blockCounts 
]

{ #category : 'initialization' }
BlocsCounter >> initialize [
	super initialize .
	blocNumber := 0.
	blockCounts := Dictionary new.
	blockStack := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
BlocsCounter >> maxDephBlocInMethod: aMethod [
	aMethod ast acceptVisitor: self.
  ^ blockCounts isEmpty
        ifTrue: [ 0 ]
        ifFalse: [ blockCounts values max ]
]

{ #category : 'as yet unclassified' }
BlocsCounter >> numberOfBlocIn: aMethod [
		aMethod ast acceptVisitor: self.
		^ blocNumber 
]

{ #category : 'as yet unclassified' }
BlocsCounter >> visitBlockNode: aBlock [
    blocNumber := blocNumber + 1.
    blockStack isEmpty ifTrue: [
        blockCounts at: aBlock put: 1.
    ] ifFalse: [  
        | root |
        root := blockStack first.
        blockCounts at: root put: ((blockCounts at: root) + 1).
    ].
    blockStack add: aBlock.
    super visitBlockNode: aBlock.
    blockStack removeLast.
]
