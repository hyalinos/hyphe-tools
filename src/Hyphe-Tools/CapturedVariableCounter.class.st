"
I calculate the number of captured variable in a given method ( local variable used in block).
To run this code: 
- use a 'method:=  aClass >> aMethod ' as argument of the method who calculate the amount of captured variable:
   numberOfCapturedVariables: method.

"
Class {
	#name : 'CapturedVariableCounter',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'methodVariables',
		'capturedVariables',
		'inBlock'
	],
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'initialization' }
CapturedVariableCounter >> capturedVariables [
    ^ capturedVariables
]

{ #category : 'initialization' }
CapturedVariableCounter >> initialize [
    super initialize.
    methodVariables := Set new.
    capturedVariables := Set new.
    inBlock := false.
]

{ #category : 'initialization' }
CapturedVariableCounter >> numberOfCapturedVariables: aMethod [
	 self initialize .
    aMethod ast acceptVisitor: self.
    ^ self capturedVariables size
]

{ #category : 'initialization' }
CapturedVariableCounter >> visitBlockNode: aBlockNode [
    | old |
    old := inBlock.
    inBlock := true.
    
    super visitBlockNode: aBlockNode.
    
    inBlock := old.
]

{ #category : 'initialization' }
CapturedVariableCounter >> visitMethodNode: aNode [
    
    aNode arguments do: [:arg | methodVariables add: arg binding ].
    aNode temporaries do: [:temp | methodVariables add: temp binding ].

    super visitMethodNode: aNode.
]

{ #category : 'initialization' }
CapturedVariableCounter >> visitVariableNode: aVariable [
    (inBlock and: [ methodVariables includes: aVariable binding ])
        ifTrue: [
            capturedVariables add: aVariable binding
        ].
    
    super visitVariableNode: aVariable.

]
