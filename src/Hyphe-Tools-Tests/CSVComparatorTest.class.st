Class {
	#name : 'CSVComparatorTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

{ #category : 'tests' }
CSVComparatorTest >> testCompareMemory [
    | fs fileCollected fileInferred cmp results |

    
    fs := FileSystem memory.

   
    fileCollected := fs / 'collected.csv'.
    fileCollected writeStreamDo: [ :s |
        s nextPutAll: 'package,class,methodName,collectedType,commonType'; cr.
        s nextPutAll: 'P1,A,add:,Integer,'; cr.
        s nextPutAll: 'P1,A,remove:,String,'; cr.
        s nextPutAll: 'P1,B,print:,Object,'.
    ].

   
    fileInferred := fs / 'inferred.csv'.
    fileInferred writeStreamDo: [ :s |
        s nextPutAll: 'methodName,class,inferredType'; cr.
        s nextPutAll: 'add:,A,Integer'; cr.
        s nextPutAll: 'remove:,A,Boolean'.
    ].

   
    cmp := CSVComparator new.

   
    results := cmp compareFile: fileCollected with: fileInferred.

   
    self assert: (results size = 3).

    
    self assert: (results anySatisfy: [ :r | r result = true ]).
    self assert: (results anySatisfy: [ :r | r result = false ]).
    self assert: (results anySatisfy: [ :r | r result isNil ]).

    
    self assert: ((results detect: [ :r | r methodSelector = 'add:' ]) typeInferred = 'Integer').

    
    self assert: ((results detect: [ :r | r methodSelector = 'remove:' ]) typeInferred = 'Boolean').




]

{ #category : 'tests' }
CSVComparatorTest >> testCompareWithMemoryAndDict [
    | fs fileCollected inferredDict cmp results |

    fs := FileSystem memory.

    "CSV en mémoire"
    fileCollected := fs / 'collected.csv'.
    fileCollected writeStreamDo: [ :s |
        s nextPutAll: 'package,className,methodName,typeCollected,commonType'; nextPutAll: String lf.
        s nextPutAll: 'P1,A,add:,Integer,'; nextPutAll: String lf.
        s nextPutAll: 'P1,A,remove:,String,'; nextPutAll: String lf.
        s nextPutAll: 'P1,B,print:,Object,'.
    ].

    inferredDict := Dictionary new.

    "Méthode add: dans A"
    inferredDict at: 'add:|A' put: (Dictionary new
        at: 'packageName' put: 'P1';
        at: 'className' put: 'A';
        at: 'methodName' put: 'add:';
        at: 'type' put: (OrderedCollection with: 'Integer');
        yourself).

    "Méthode remove: dans A"
    inferredDict at: 'remove:|A' put: (Dictionary new
        at: 'packageName' put: 'P1';
        at: 'className' put: 'A';
        at: 'methodName' put: 'remove:';
        at: 'type' put: (OrderedCollection with: 'Boolean');
        yourself).

    cmp := CSVComparator new.
    results := cmp compareFile: fileCollected withDictionary: inferredDict.

    "Assertions"
    "self assert: results size = 3.

    self assert: (results anySatisfy: [ :r | r result = false ]).
    self assert: (results anySatisfy: [ :r | r result = false ]).
    self assert: (results anySatisfy: [ :r | r result isNil ]).

    self assert:
        ((results detect: [ :r | r methodSelector = 'add:' ]) typeInferred = 'Integer').

    self assert:
        ((results detect: [ :r | r methodSelector = 'remove:' ]) typeInferred = 'Boolean').

    self assert:
        ((results detect: [ :r | r methodSelector = 'print:' ]) result isNil)."
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
