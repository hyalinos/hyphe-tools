Class {
	#name : 'RatioSelfSendsTestData',
	#superclass : 'Object',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'adding' }
RatioSelfSendsTestData >> add: a and: b [
	| res |
	res := a + b.
	^ res
]

{ #category : 'adding' }
RatioSelfSendsTestData >> double: x [
	^ x * 2

]

{ #category : 'adding' }
RatioSelfSendsTestData >> highSelfMessage [
	| res|
    res := (self double: (self two)) 
        + (self double: (self two))
        + (self two)
]

{ #category : 'adding' }
RatioSelfSendsTestData >> lowSelfMessage [
    | a |
    a := 5.
    ^ a + (self two)
]

{ #category : 'adding' }
RatioSelfSendsTestData >> mediumSelfMessage [
    | a |
    a := self two.
    ^ (self double: a) + (self two)
]

{ #category : 'adding' }
RatioSelfSendsTestData >> noSelfMessage [
    | a b |
    a := 5.
    b := 10.
    ^ a + b
]

{ #category : 'adding' }
RatioSelfSendsTestData >> two [
 	^ 2
 

]

{ #category : 'adding' }
RatioSelfSendsTestData >> veryHighSelfMessage [
   | a b res| 
   a := 3.
	b := 4.
	res := (self add:a and: b) + (self double:a).
	^ res + (self two).
]
