Class {
	#name : 'CSVComparatorTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Tools-Tests',
	#package : 'Hyphe-Tools-Tests'
}

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
