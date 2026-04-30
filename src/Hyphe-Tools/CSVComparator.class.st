"
*compareFile: with:
	-I compare two csv files (inferences files),and return a Dictionnayu as result
	-To run this code, I need 2 csv files as argument:
	compareFile: file1.csv with: file2.csv
*compareFile:with:with:with:with:with
	-I compare 5 csv files
*compareFile: withDictionary:
   -I compare a csv file with a dictionnary
	-I consider a csv file where the header are the same as the keys on the dictionary
	-I consider only the inference file.
*exportResultsToCSVStandard:toFile:
   -I export a collection of dictionary to a csv file
	-I consider all dictionary
	-To run this code, I need a list of dicitionary and the name of file as second argument
	  exportResultsToCSVStandard:aDictionary toFile: aFile
	
"
Class {
	#name : 'CSVComparator',
	#superclass : 'Object',
	#category : 'Hyphe-Tools',
	#package : 'Hyphe-Tools'
}

{ #category : 'as yet unclassified' }
CSVComparator >> allEqual: aCollection [
    aCollection isEmpty ifTrue: [ ^ false ].
    ^ aCollection allSatisfy: [ :each | each = aCollection first ]
]

{ #category : 'verification' }
CSVComparator >> compareAllStrategyCount: aDictionary [
"Count the number of the method who have the same result and different result in inference"
	|  count countSame countDiff sameRes diffRes |
	countSame := 0.
	countDiff := 0.
	count := Dictionary new.
	aDictionary do: [ :row | 
		| result |
		result := row at: 'comparaisonType'.
		result ifTrue: [ countSame := countSame + 1 ] ifFalse: [ countDiff := countDiff + 1 ].
  ].
	count at:'Same result for all Strategy' put: countSame .
	count at:'Different result for strategy' put: countDiff .
	
	^ count 
]

{ #category : 'verification' }
CSVComparator >> compareAllStrategyDiffence: aDictionary [
	|  res sameRes diffRes |
	res := Dictionary new.
	sameRes := OrderedCollection new.
	diffRes := OrderedCollection new.
	aDictionary do: [ :row | 
		| result |
		result := row at: 'comparaisonType'.
		result ifTrue: [  
			sameRes add: (row at: 'methodSelector' ).
			] ifFalse: [ 
			diffRes add: (row at: 'methodSelector').
			].
  ].
	res at: 'Same result for all strategies' put: sameRes .
	res at: 'Different result for strategies' put: diffRes .
	
	^ res
]

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
CSVComparator >> compareFile: collectedFile with:consensus with:biasedConsensus with: tieredStrategy with: weightedVoting with: biasedWeightedVoting [ 
    | collectedRows consensusRows consensusDict biasedConsensusRows biasedConsensusDict tieredStrategyRows tieredStrategyDict weightedVotingRows weightedVotingDict biasedWeightedVotingRows biasedWeightedVotingDict resultRow resultCollection key|

    collectedRows := self rowsToDicts: (self readCSV: collectedFile).
	 
	 "AllStrategy"
	
	 "consensus"
    consensusRows := self rowsToDicts: (self readCSV: consensus).
    consensusDict := self toDictionaryByKeyStrategy: consensusRows.
		
	 
	 "BiasedConsensus"
	 biasedConsensusRows := self rowsToDicts: (self readCSV: biasedConsensus).
    biasedConsensusDict := self toDictionaryByKeyStrategy: biasedConsensusRows.
	 "TieredStrategy"
	 tieredStrategyRows := self rowsToDicts: (self readCSV: tieredStrategy).
    tieredStrategyDict := self toDictionaryByKeyStrategy: tieredStrategyRows.
	 
	 "WeightedVoting "
	 weightedVotingRows := self rowsToDicts: (self readCSV: weightedVoting).
    weightedVotingDict := self toDictionaryByKeyStrategy: weightedVotingRows.
 
    "BiasedWeightedVoting"
	 biasedWeightedVotingRows := self rowsToDicts: (self readCSV: biasedWeightedVoting).
    biasedWeightedVotingDict := self toDictionaryByKeyStrategy: biasedWeightedVotingRows.
     
	 "Result"
    resultCollection := OrderedCollection new.

    collectedRows do: [ :row |
        | varConsensus varBiasedConsensus varTieredStrategy varWeightedVoting  varbiasedWeightedVoting  typeConsensus typeBiasedConsensus typeTieredStrategy typeWeightedVoting  typebiasedWeightedVoting comparaison allStrategy|
        
        key := (row at: 'methodName'), '|', (row at: 'className').
	
        resultRow := Dictionary new.
        resultRow at: 'package' put: (row at: 'package' ifAbsent: [ '' ]).
        resultRow at: 'className' put: (row at: 'className').
        resultRow at: 'methodSelector' put: (row at: 'methodName').
		  resultRow at: 'typeCollected' put: (row at: 'typeCollected').
		  "Consensus"
        varConsensus := consensusDict at: key ifAbsent: [ nil ].
		  typeConsensus := varConsensus
    								ifNotNil: [ varConsensus at: 'typeInferred' ]
   			 						ifNil: [ nil ].
		  "typeConsensus := (varConsensus at: 'typeInferred')."
		  resultRow at: 'consensus' put: typeConsensus.
		  "BiasedConsensus"
		  varBiasedConsensus := biasedConsensusDict at: key ifAbsent: [ nil ]. 
		  typeBiasedConsensus := varBiasedConsensus
											ifNotNil: [ varBiasedConsensus at: 'typeInferred' ]
											ifNil: [ nil ].
		
		  resultRow at: 'biasedConsensus' put: typeBiasedConsensus.
		
		  "TieredStrategy"
		  varTieredStrategy := (tieredStrategyDict at: key ifAbsent: [nil]).
		  typeTieredStrategy := varTieredStrategy 
											ifNotNil: [ varTieredStrategy at: 'typeInferred' ]
											ifNil: [ nil ].
		  resultRow at: 'tieredStrategy' put: typeTieredStrategy .
		
		  "WeightedVoting"
		  varWeightedVoting := (weightedVotingDict at: key ifAbsent: [nil]).
		  typeWeightedVoting :=varWeightedVoting
										ifNotNil: [ varWeightedVoting at: 'typeInferred' ]
										ifNil: [ nil ].
		  resultRow at: 'weightedVoting' put: typeWeightedVoting.
		
		  "BiasedWeigtedVoting"
		  varbiasedWeightedVoting := (biasedWeightedVotingDict at: key ifAbsent: [ nil ]).
		  typebiasedWeightedVoting := varbiasedWeightedVoting
												 ifNotNil: [ varbiasedWeightedVoting at: 'typeInferred' ]
										       ifNil: [ nil ].	
		 
		  resultRow at: 'biasedWeightedVoting' put: typebiasedWeightedVoting.
		 
		  "Comparaison"
		  allStrategy := {
   			 typeConsensus.
   			 typeBiasedConsensus.
    		 typeTieredStrategy.
    		typeWeightedVoting.
         typebiasedWeightedVoting
		  } .
		  

		 comparaison := self allEqual: allStrategy.
		  resultRow at: 'comparaisonType' put: comparaison.
        "AllResult"
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
        at: 'nil' put: ((nilCompte*100)/ total);
        at: 'true' put: ((trueCompte*100)/ total);
        at: 'false' put: ((falseCompte*100)/total);
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
CSVComparator >> exportResultsToCSVStandard: results toFile: fileName [
    | stream keys header line |

    stream := (FileLocator workingDirectory / fileName) writeStream.

    keys := results first keys asArray.
    header := String streamContents: [ :s |
        keys do: [ :k |
            s nextPutAll: k asString.
            s nextPut: $,.
        ].
        s skip: -1. 
    ].

    stream nextPutAll: header; nextPutAll: String crlf.

    results do: [ :r |
        line := String streamContents: [ :s |
            keys do: [ :k |
                | value |
                value := r at: k ifAbsent: [ '' ].
                s nextPutAll: value printString.
                s nextPut: $,.
            ].
            s skip: -1.
        ].

        stream nextPutAll: line; nextPutAll: String crlf.
    ].

    stream close.
]

{ #category : 'as yet unclassified' }
CSVComparator >> readCSV: aFile [
    | rows |
    rows := OrderedCollection new.
	"For a real File"
	(FileLocator workingDirectory / aFile) readStreamDo: [ :stream |
        (NeoCSVReader on: stream)
            separator: $,;
            do: [ :row | rows add: row ].
    ].
	
	"Using an in-memory FileSystem"
   "aFile readStreamDo: [ :stream | 
		(NeoCSVReader on: stream)
			separator: $,;
			do: [ :row | rows add: row  ].
	]. " 
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

{ #category : 'as yet unclassified' }
CSVComparator >> toDictionaryByKeyStrategy: inferredCollection [
    | dict |
    dict := Dictionary new.
    inferredCollection do: [ :each |
        | key |
        key := (each at: 'methodSelector'), '|', (each at: 'className').
        dict at: key put: each.
    ].
    ^ dict
]
