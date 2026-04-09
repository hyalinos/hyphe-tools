Class {
	#name : 'CSVComparator',
	#superclass : 'Object',
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'verification' }
CSVComparator >> compareFile: collectedFile with: inferredFile [
    | collectedRows inferredRows inferredDict resultRow resultCollection key |

    collectedRows := self rowsToDicts: (self readCSV: collectedFile).
    inferredRows := self rowsToDicts: (self readCSV: inferredFile).
    inferredDict := self toDictByKey: inferredRows.

    resultCollection := OrderedCollection new.

    collectedRows do: [ :row |
        | inferred |
        
        key := (row at: 'methodName'), '|', (row at: 'class').

        resultRow := ResultRow new.
        resultRow package: (row at: 'package' ifAbsent: [ '' ]).
        resultRow className: (row at: 'class').
        resultRow methodSelector: (row at: 'methodName').
        resultRow typeCollected: (row at: 'collectedType' ifAbsent: ['absent']).

        inferred := inferredDict at: key ifAbsent: [ nil ].

        inferred
            ifNil: [
                resultRow typeInferred: ''.
                resultRow result: nil
            ]
            ifNotNil: [
                resultRow typeInferred: (inferred at: 'inferredType').
                resultRow result: ((resultRow typeCollected = resultRow typeInferred) | ((row at: 'commonType') = resultRow typeInferred))
            ]. 

        resultCollection add: resultRow.
    ].

    ^ resultCollection
]

{ #category : 'verification' }
CSVComparator >> compareFile: collectedFile withDictionary: inferredDictionary [
    | collectedRows inferredRows inferredDict resultRow resultCollection key |

    collectedRows := self rowsToDicts: (self readCSV: collectedFile).
    inferredDict := self toDictionaryByKey: inferredDictionary.

    resultCollection := OrderedCollection new.

    collectedRows do: [ :row |
        | inferred inferredTypes|
        
        key := (row at: 'methodName'), '|', (row at: 'className').

        resultRow := ResultRow new.
        resultRow package: (row at: 'package' ifAbsent: [ '' ]).
        resultRow className: (row at: 'className').
        resultRow methodSelector: (row at: 'methodName').
        resultRow typeCollected: (row at: 'typeCollected' ifAbsent: ['']).

        inferred := inferredDict at: key ifAbsent: [ nil ].

        inferred
            ifNil: [
                resultRow typeInferred: ''.
                resultRow result: nil
            ]
            ifNotNil: [
                resultRow typeInferred: (
   						 String streamContents: [ :s |
        					((inferred at: 'type' ifAbsent: [#()]))
          					  doWithIndex: [ :t :i |
               				 i > 1 ifTrue: [ s nextPutAll: ' | ' ].
               				 s nextPutAll: t asString.
            					].
   							 ]
							).
				

				inferredTypes := inferred at: 'type' ifAbsent: [#()].
				resultRow result:
   				  (inferredTypes anySatisfy: [ :t |
       		  (t asString = resultRow typeCollected)
       		   or: [ (row at: 'commonType' ifAbsent: ['']) = t asString ]
   				 ]).
			].
                "resultRow result: ((resultRow typeCollected = resultRow typeInferred) | ((row at: 'commonType') = resultRow typeInferred))
            ]. "

        		resultCollection add: resultRow.
    ].

    ^ resultCollection
]

{ #category : 'as yet unclassified' }
CSVComparator >> compteResults: aResultCompared [
		| nilCompte falseCompte trueCompte total|
		nilCompte := 0.
		falseCompte := 0.
		trueCompte := 0.
		total := 0.
		aResultCompared do: [ :row | 
			|result|
			total := total +1.
			result := row result .
			result ifNil: [ nilCompte := nilCompte + 1 ]. 
			(result = true) ifTrue: [ trueCompte := trueCompte + 1 ].
			(result = false) ifTrue: [ falseCompte := falseCompte + 1 ].
		].
		^ Dictionary new
		  at: 'total' put:total;
        at: 'nil' put: nilCompte;
        at: 'true' put: trueCompte;
        at: 'false' put: falseCompte;
        yourself.
]

{ #category : 'as yet unclassified' }
CSVComparator >> exportResultsToCSV: results toFile: fileName [
    | stream line |

    stream := (FileLocator workingDirectory / fileName) writeStream.

    "Header"
    line := 'package,className,methodSelector,typeCollected,typeInferred,result'.
    stream nextPutAll: line; nextPutAll: String crlf.

    "Data"
    results do: [ :r |
        line := (r package ifNil: ['']) , ',' , 
                (r className ifNil: ['']) , ',' ,
                (r methodSelector ifNil: ['']) , ',' ,
                (r typeCollected ifNil: ['']) , ',' ,
                (r typeInferred ifNil: ['']) , ',' ,
                (r result isNil ifTrue: ['nil'] ifFalse: [ r result printString ]).
        stream nextPutAll: line; nextPutAll: String crlf.
    ].

    stream close.
]

{ #category : 'as yet unclassified' }
CSVComparator >> expotResults: results toFile: path [
	| writer |
	writer := NeoCSVWriter on: ((FileLocator workingDirectory / path) writeStream).
	writer separator: $,.
	writer writeField: #('package' 'class' 'methodSelector' 'typeCollected' 'typeInferred' 'result').
	results do: [ :r| 
		writer writeField: {
			r package.
			r className.
			r methodClass.
			r typeCollected.
			r typeInferred.
			(r result isNil
         	  ifTrue: ['nil']
    		  ifFalse: [ r result asString ])
		}.		
   ].
   writer close
]

{ #category : 'as yet unclassified' }
CSVComparator >> readCSV: aFile [
    | rows |
    rows := OrderedCollection new.
"(FileLocator workingDirectory / aFile) readStreamDo: [ :stream |
        (NeoCSVReader on: stream)
            separator: $,;
            do: [ :row | rows add: row ].
    ].
	"aFile readStreamDo: [ :stream | 
		(NeoCSVReader on: stream)
			separator: $,;
			do: [ :row | rows add: row  ].
	].    
    ^ rows
]

{ #category : 'as yet unclassified' }
CSVComparator >> rowsToDicts: rows [
	| header result|
	header := rows first.
	result := OrderedCollection new.
	(rows allButFirst) do: [ :row | 
		| dict |
		dict := Dictionary new.
		1 to: header size do: [ :i |
			dict at: (header at: i) put: (row at: i ifAbsent:['']) asString trimBoth
		 ].
		result add: dict. 
   ].
	^ result
]

{ #category : 'as yet unclassified' }
CSVComparator >> toDictByKey: rows [
	| dict |
	dict := Dictionary new.
	rows do: [ :row |
		| key | 
		key := (row at: 'methodName'), '|', (row at: 'class').
		dict at: key put: row.		
	].
	^ dict
]

{ #category : 'as yet unclassified' }
CSVComparator >> toDictionaryByKey: inferredCollection [
    | dict |
    dict := Dictionary new.
    inferredCollection do: [ :each |
        | key |
        key := (each at: 'methodName'), '|', (each at: 'className').
        dict at: key put: each.
    ].
    ^ dict
]
