"
I was created to structure data in CSVComparator.
"
Class {
	#name : 'ResultRow',
	#superclass : 'Object',
	#instVars : [
		'package',
		'className',
		'methodSelector',
		'typeCollected',
		'typeInferred',
		'result'
	],
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'accessing' }
ResultRow >> className [
	^ className
]

{ #category : 'accessing' }
ResultRow >> className: aClassName [
	className := aClassName 
]

{ #category : 'accessing' }
ResultRow >> methodSelector [
	^ methodSelector
]

{ #category : 'accessing' }
ResultRow >> methodSelector: aMethodSelecor [
	methodSelector := aMethodSelecor 
]

{ #category : 'accessing' }
ResultRow >> package [
	^ package
]

{ #category : 'accessing' }
ResultRow >> package: aPackage [
	package := aPackage
]

{ #category : 'accessing' }
ResultRow >> result [
	^ result
]

{ #category : 'accessing' }
ResultRow >> result: aResult [
	result := aResult
]

{ #category : 'accessing' }
ResultRow >> toDictionaryByKey: resultRow [
    | dict |
    dict := Dictionary new.
    resultRow do: [ :each |
        | key |
        key := (each at: 'methodName'), '|', (each at: 'className').
        dict at: key put: each.
    ].
    ^ dict
]

{ #category : 'accessing' }
ResultRow >> typeCollected [
	^ typeCollected
]

{ #category : 'accessing' }
ResultRow >> typeCollected: aTypeCollected [
	typeCollected := aTypeCollected 
]

{ #category : 'accessing' }
ResultRow >> typeInferred [
	^ typeInferred
]

{ #category : 'accessing' }
ResultRow >> typeInferred: aTypeInferred [
	typeInferred := aTypeInferred
]
