"
I calculate the number of isNil / ifNil: / == nil occurrences per LOC in a given method.
I do not consider ^ nil, := nil

To run this code:
•	use a 'method:=  aClass >> aMethod ' as argument of the method who calculate the Nil-check density :
nilCountIn: method.
"
Class {
	#name : 'NilDensity',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'nilCount'
	],
	#category : 'Hyphe-Tools-StaticAnalysis',
	#package : 'Hyphe-Tools',
	#tag : 'StaticAnalysis'
}

{ #category : 'initialization' }
NilDensity >> initialize [ 
   super initialize.
	nilCount := 0.
	
]

{ #category : 'as yet unclassified' }
NilDensity >> nilCountIn: aMethod [
	|locCounter loc|
	locCounter := LOCCounter new.
	loc := locCounter linesOfCode: aMethod.
	aMethod ast acceptVisitor: self.
	
   ^ nilCount / loc
]

{ #category : 'visiting' }
NilDensity >> visitMessageNode: aMessageNode [
    | selector |

    selector := aMessageNode selector.

    " isNil "
    (selector = #isNil) ifTrue: [
       nilCount := nilCount + 1.
    ].

    " ifNil: "
    (selector = #ifNil:)ifTrue: [
      nilCount := nilCount + 1.
    ].

    " ==nil"
    (selector = #==) ifTrue: [
    (aMessageNode arguments first isLiteralNode
        and: [ aMessageNode arguments first value isNil ])
            ifTrue: [
                nilCount := nilCount + 1
            ].
        
    ].

    super visitMessageNode: aMessageNode.
]
