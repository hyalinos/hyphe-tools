"
One recorded evaluation run, held LIVE in the image (not just exported to disk) so later work in this same session/image can query it on the fly without re-running the evaluation or re-parsing a CSV. groundTruth: Dictionary(HYISigmaKey->truth class name String). results: Dictionary(sourceName String -> Dictionary(HYISigmaKey->TypeResult)). tallies: Dictionary(sourceName -> the #exact/#consistent/#wrong/#noAnswer/#conflict tally Dictionary from HYIEvaluationHarness class>>tally:). Stored/queried via HYIEvaluationHarness class>>recordRun:/latestRun/runs.
"
Class {
	#name : 'HYIEvaluationRun',
	#superclass : 'Object',
	#instVars : [
		'label',
		'timestamp',
		'groundTruth',
		'results',
		'tallies'
	],
	#category : 'Hyphe-Inferencer',
	#package : 'Hyphe-Inferencer'
}

{ #category : 'instance creation' }
HYIEvaluationRun class >> label: aLabel groundTruth: gtDict results: resultsDict tallies: talliesDict [
	"Constructor for one recorded evaluation run."

	^ self new
		  setLabel: aLabel
		  groundTruth: gtDict
		  results: resultsDict
		  tallies: talliesDict;
		  yourself
]

{ #category : 'accessing' }
HYIEvaluationRun >> groundTruth [
	"Answers the hand-built ground-truth Dictionary (key -> trusted true type) this run was scored against."

	^ groundTruth
]

{ #category : 'accessing' }
HYIEvaluationRun >> keys [
	"All ground-truth keys, sorted for stable, repeatable reporting."

	^ groundTruth keys asSortedCollection: [ :a :b | a printString <= b printString ]
]

{ #category : 'accessing' }
HYIEvaluationRun >> label [
	"Answers this run's label, e.g. the scope name it was run over."

	^ label
]

{ #category : 'printing' }
HYIEvaluationRun >> printOn: aStream [
	"One-line summary: label, timestamp, ground-truth size, and which sources were scored."

	aStream nextPutAll:
		'HYIEvaluationRun(''' , label , ''' @ ' , timestamp printString , ', ' , groundTruth size printString , ' methods, sources: '
		, self sourceNames printString , ')'
]

{ #category : 'printing' }
HYIEvaluationRun >> report [
	"A short multi-line text report: one line per scored source, each showing that source's own tally."

	| s |
	s := WriteStream on: String new.
	s
		nextPutAll: 'Run: ' , label , ' (' , timestamp printString , ')';
		cr.
	self sourceNames do: [ :src |
			| t |
			t := self tallyFor: src.
			s
				nextPutAll: '  ' , src , ': ' , t printString;
				cr ].
	^ s contents
]

{ #category : 'accessing' }
HYIEvaluationRun >> resultFor: aKey source: aSourceName [
	"Answers what aSourceName said about aKey in this run, or nil if that source has no entry for that key."

	^ (results at: aSourceName ifAbsent: [ ^ nil ]) at: aKey ifAbsent: [ nil ]
]

{ #category : 'accessing' }
HYIEvaluationRun >> results [
	"Answers the full results Dictionary: source name -> (key -> TypeResult)."

	^ results
]

{ #category : 'private' }
HYIEvaluationRun >> setLabel: aLabel groundTruth: gtDict results: resultsDict tallies: talliesDict [
	"Private initializer, called only from the class-side constructor -- also stamps the run with its creation time."

	label := aLabel.
	timestamp := DateAndTime now.
	groundTruth := gtDict.
	results := resultsDict.
	tallies := talliesDict
]

{ #category : 'accessing' }
HYIEvaluationRun >> sourceNames [
	"Answers which sources (e.g. 'ARTI', 'Combined') this run has results for, as an Array."

	^ results keys asSortedCollection asArray
]

{ #category : 'accessing' }
HYIEvaluationRun >> tallies [
	"Answers the full tallies Dictionary: source name -> its #exact/#consistent/#wrong/#noAnswer/#conflict counts."

	^ tallies
]

{ #category : 'accessing' }
HYIEvaluationRun >> tallyFor: aSourceName [
	"Answers one source's tally, or nil if that source wasn't scored in this run."

	^ tallies at: aSourceName ifAbsent: [ nil ]
]

{ #category : 'accessing' }
HYIEvaluationRun >> timestamp [
	"When this run was recorded."

	^ timestamp
]

{ #category : 'accessing' }
HYIEvaluationRun >> verdictFor: aKey source: aSourceName [
	"Re-classifies aSourceName's answer for aKey against ground truth on demand, without needing to re-run anything -- nil if either the source has no answer or aKey isn't in ground truth."

	| r truth |
	r := self resultFor: aKey source: aSourceName.
	r ifNil: [ ^ nil ].
	truth := groundTruth at: aKey ifAbsent: [ ^ nil ].
	^ HYIEvaluationHarness classifyResult: r against: truth
]
