Class {
	#name : 'CSVComparatorTest',
	#superclass : 'TestCase',
	#instVars : [
		'createdFiles'
	],
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'running' }
CSVComparatorTest >> ensureFile: aName lines: someLines [
	"Write a file in the working directory unless it exists; remember it when created"

	| file |
	file := FileLocator workingDirectory / aName.
	file exists ifTrue: [ ^ self ].
	file writeStreamDo: [ :stream |
			someLines do: [ :line |
					stream
						nextPutAll: line;
						lf ] ].
	createdFiles add: file
]

{ #category : 'running' }
CSVComparatorTest >> setUp [
	"The three tests that read test.csv and test2.csv from the working directory find these files: they are written here when they do not exist, and removed afterwards (see tearDown)"

	super setUp.
	createdFiles := OrderedCollection new.
	self
		ensureFile: 'test.csv'
		lines:
			{ 'package,class,methodName,collectedType,commonType'. 'P1,A,add:,Integer,'. 'P1,A,remove:,String,'. 'P1,B,print:,Object,'.
			'P1,B,size,Integer,' }.
	self ensureFile: 'test2.csv' lines: { 'methodName,class,inferredType'. 'add:,A,Integer'. 'remove:,A,Boolean'. 'size,B,Integer' }
]

{ #category : 'running' }
CSVComparatorTest >> tearDown [
	"Remove the files that setUp created, leave the ones that already existed"

	createdFiles do: [ :file | file ensureDelete ].
	super tearDown
]

{ #category : 'tests' }
CSVComparatorTest >> testCompareMultipleStrategiesMemory [
"Test with FileSystem, To run with the real file, need to set up readCsv on CSVComparator"
    | fs fileCollected fileConsensus fileBiased fileTiered fileWeighted fileBiasedWeighted cmp results |

    fs := FileSystem memory.

    "Collected"
    fileCollected := fs / 'collected.csv'.
    fileCollected writeStreamDo: [ :s |
        s nextPutAll: 'package,className,methodName,typeCollected'; cr.
        s nextPutAll: 'P1,A,add:,Integer'; cr.
        s nextPutAll: 'P1,A,remove:,String'; cr.
        s nextPutAll: 'P1,B,print:,Object'.
    ].

    "Consensus"
    fileConsensus := fs / 'consensus.csv'.
    fileConsensus writeStreamDo: [ :s |
        s nextPutAll: 'methodSelector,className,typeInferred'; cr.
        s nextPutAll: 'add:,A,Integer'; cr.
        s nextPutAll: 'remove:,A,String'.
    ].

    "BiasedConsensus"
    fileBiased := fs / 'biased.csv'.
    fileBiased writeStreamDo: [ :s |
        s nextPutAll: 'methodSelector,className,typeInferred'; cr.
        s nextPutAll: 'add:,A,Integer'; cr.
        s nextPutAll: 'remove:,A,Boolean'.
    ].

    "TieredStrategy"
    fileTiered := fs / 'tiered.csv'.
    fileTiered writeStreamDo: [ :s |
        s nextPutAll: 'methodSelector,className,typeInferred'; cr.
        s nextPutAll: 'add:,A,Integer'.
    ].

    "WeightedVoting"
    fileWeighted := fs / 'weighted.csv'.
    fileWeighted writeStreamDo: [ :s |
        s nextPutAll: 'methodSelector,className,typeInferred'; cr.
        s nextPutAll: 'add:,A,Integer'; cr.
        s nextPutAll: 'remove:,A,String'.
    ].

    "BiasedWeightedVoting"
    fileBiasedWeighted := fs / 'biasedWeighted.csv'.
    fileBiasedWeighted writeStreamDo: [ :s |
        s nextPutAll: 'methodSelector,className,typeInferred'; cr.
        s nextPutAll: 'add:,A,Integer'.
    ].

    cmp := CSVComparator new.

    results := cmp 
        compareFile: fileCollected
        with: fileConsensus
        with: fileBiased
        with: fileTiered
        with: fileWeighted
        with: fileBiasedWeighted.

    "Taille"
    self assert: results size = 3.

    "Cas add: → tout pareil → true"
    self assert: (
        ((results detect: [ :r | (r at: 'methodSelector') = 'add:' ])
            at: 'comparaisonType')
    ) equals: true.

    "Cas remove: → différences → false"
    self assert: (
        ((results detect: [ :r | (r at: 'methodSelector') = 'remove:' ])
            at: 'comparaisonType')
    ) equals: false.

   
    "Vérification des valeurs extraites"
    self assert: (
        ((results detect: [ :r | (r at: 'methodSelector') = 'add:' ])
            at: 'consensus')
    ) equals: 'Integer'.

    self assert: (
        ((results detect: [ :r | (r at: 'methodSelector') = 'remove:' ])
            at: 'biasedConsensus')
    ) equals: 'Boolean'.
]

{ #category : 'tests' }
CSVComparatorTest >> testCompareWithMemoryAndDict [
	"Test using an in-memory FileSystem. 
To run this test with real files, ensure that CSVComparator>>readCSV is properly configured to read from the actual file system."
    | fs fileCollected inferredDict cmp results |

    fs := FileSystem memory.

 
    fileCollected := fs / 'collected.csv'.
    fileCollected writeStreamDo: [ :s |
        s nextPutAll: 'package,className,methodName,typeCollected,commonType'; nextPutAll: String lf.
        s nextPutAll: 'P1,A,add:,Integer,'; nextPutAll: String lf.
        s nextPutAll: 'P1,A,remove:,String,'; nextPutAll: String lf.
        s nextPutAll: 'P1,B,print:,Object,'.
    ].

    inferredDict := Dictionary new.

  
    inferredDict at: 'add:|A' put: (Dictionary new
        at: 'packageName' put: 'P1';
        at: 'className' put: 'A';
        at: 'methodName' put: 'add:';
        at: 'type' put: (OrderedCollection with: 'Integer');
        yourself).

   
    inferredDict at: 'remove:|A' put: (Dictionary new
        at: 'packageName' put: 'P1';
        at: 'className' put: 'A';
        at: 'methodName' put: 'remove:';
        at: 'type' put: (OrderedCollection with: 'Boolean');
        yourself).

    cmp := CSVComparator new.
    results := cmp compareFile: fileCollected withDictionary: inferredDict.

  
    self assert: results size = 3.

    self assert: (results anySatisfy: [ :r | r result = true ]).
    self assert: (results anySatisfy: [ :r | r result = false ]).
    self assert: (results anySatisfy: [ :r | r result isNil ]).

    self assert:
        ((results detect: [ :r | r methodSelector = 'add:' ]) typeInferred = 'Integer').

    self assert:
        ((results detect: [ :r | r methodSelector = 'remove:' ]) typeInferred = 'Boolean').

    self assert:
        ((results detect: [ :r | r methodSelector = 'print:' ]) result isNil).
]

{ #category : 'tests' }
CSVComparatorTest >> testComparison [
    | cmp results |

    cmp := CSVComparator new.
    results := cmp compareFile: 'test.csv' with: 'test2.csv'.
    self assert: results size = 4.
]

{ #category : 'tests' }
CSVComparatorTest >> testResultValue [
    | cmp results |

    cmp := CSVComparator new.
    results := cmp compareFile: 'test.csv' with: 'test2.csv'.

    self assert: (results anySatisfy: [ :r | r result isNil ]).
	 self assert: (results anySatisfy: [ :r | r result isNil ]).
	 self assert: (results anySatisfy: [ :r | r result = nil]).
	
]

{ #category : 'tests' }
CSVComparatorTest >> testResultValues [
    | cmp results |

    cmp := CSVComparator new.
    results := cmp compareFile: 'test.csv' with: 'test2.csv'.

    self assert: (results anySatisfy: [ :r | r result isNil ]).
]
