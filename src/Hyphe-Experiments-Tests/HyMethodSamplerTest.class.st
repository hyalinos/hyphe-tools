"
Tests of HyMethodSampler on a small pool of known methods.
"
Class {
	#name : 'HyMethodSamplerTest',
	#superclass : 'HyExperimentsAbstractTest',
	#category : 'Hyphe-Experiments-Tests-Grouping',
	#package : 'Hyphe-Experiments-Tests',
	#tag : 'Grouping'
}

{ #category : 'helpers' }
HyMethodSamplerTest >> pool [
	"The methods of MetricsTestData and ReturnPointsTestData: several of each return point group"

	^ MetricsTestData methods , ReturnPointsTestData methods
]

{ #category : 'helpers' }
HyMethodSamplerTest >> sampler [
	"A sampler on the pool, with a seeded generator"

	^ (HyMethodSampler scheme: HyGroupScheme returnPoints)
		  pool: self pool;
		  random: (Random seed: 7);
		  yourself
]

{ #category : 'tests' }
HyMethodSamplerTest >> testCompleteDataset [
	"Each group is completed to the wanted size with methods that are not in the dataset (G3 and G4 have only two methods in the pool, so they stay at 2); the new entries are in the dataset and answered"

	| scheme dataset drawn |
	scheme := HyGroupScheme returnPoints.
	dataset := HyGroundTruthDataset named: 'small'.
	dataset add: (self entryOf: (self refOf: #mixedSends in: MetricsTestData) truth: 'r').
	dataset add: (self entryOf: (self refOf: #noSends in: MetricsTestData) truth: 'SmallInteger').
	dataset assignGroups: scheme.

	drawn := self sampler completeDataset: dataset toSize: 3.

	self assert: (drawn at: (scheme groupNamed: 'G1')) size equals: 2.
	self assert: (drawn at: (scheme groupNamed: 'G2')) size equals: 2.
	self assert: (drawn at: (scheme groupNamed: 'G3')) size equals: 2.
	self assert: (drawn at: (scheme groupNamed: 'G4')) size equals: 2.
	self assert: dataset size equals: 2 + 8.
	self assert: (dataset entriesInGroup: (scheme groupNamed: 'G1')) size equals: 3.
	self assert: dataset refs size equals: dataset size
]

{ #category : 'tests' }
HyMethodSamplerTest >> testExcludedMethodsAreNeverDrawn [
	"Methods of the excluded dataset are not in the sample, even if the pool is small"

	| scheme dataset sampler entries |
	scheme := HyGroupScheme returnPoints.
	dataset := HyGroundTruthDataset named: 'excluded'.
	(MetricsTestData methods select: [ :method | (scheme measure: method) = 0 ]) allButFirst do: [ :method |
		dataset add: (HyGroundTruthEntry ref: (HyMethodRef fromCompiledMethod: method) truth: nil) ].
	sampler := self sampler
		           excluding: dataset;
		           yourself.

	entries := (sampler sample: (Dictionary new
			             at: (scheme groupNamed: 'G1') put: 1000;
			             yourself)) at: (scheme groupNamed: 'G1').

	self assert: (entries select: [ :entry | dataset includesRef: entry ref ]) isEmpty.
	self assert: entries size < 1000
]

{ #category : 'tests' }
HyMethodSamplerTest >> testMethodsOfTheImageAreTheDefaultPool [
	"Without a pool the whole image is used (the sample is one method, to be quick)"

	| scheme sampler entries |
	scheme := HyGroupScheme statementCount.
	sampler := (HyMethodSampler scheme: scheme)
		           random: (Random seed: 1);
		           yourself.

	entries := (sampler sample: (Dictionary new
			             at: (scheme groupNamed: 'G2') put: 2;
			             yourself)) at: (scheme groupNamed: 'G2').

	self assert: entries size equals: 2.
	self assert: (entries allSatisfy: [ :entry | entry count between: 2 and: 3 ])
]

{ #category : 'tests' }
HyMethodSamplerTest >> testPoolWithTooFewMethods [
	"A group gets fewer methods than wanted if the pool has not enough, no error"

	| scheme entries |
	scheme := HyGroupScheme returnPoints.
	entries := (self sampler sample: (Dictionary new
			             at: (scheme groupNamed: 'G4') put: 50;
			             yourself)) at: (scheme groupNamed: 'G4').

	self assert: entries size equals: 2
]

{ #category : 'tests' }
HyMethodSamplerTest >> testSameSeedSameSample [
	"A seeded generator gives the same sample again, another seed another one"

	| scheme need first second other |
	scheme := HyGroupScheme returnPoints.
	need := [
		        Dictionary new
			        at: (scheme groupNamed: 'G1') put: 4;
			        yourself ].
	first := ((self sampler sample: need value) at: (scheme groupNamed: 'G1')) collect: [ :entry | entry ref ].
	second := ((self sampler sample: need value) at: (scheme groupNamed: 'G1')) collect: [ :entry | entry ref ].
	other := (((self sampler
		            random: (Random seed: 99);
		            yourself) sample: need value) at: (scheme groupNamed: 'G1')) collect: [ :entry | entry ref ].

	self assert: first asArray equals: second asArray.
	self deny: first asArray = other asArray
]

{ #category : 'tests' }
HyMethodSamplerTest >> testSampleGivesTheWantedNumberInTheRightGroups [
	"Methods of the pool, each in its group, with their count"

	| scheme sample |
	scheme := HyGroupScheme returnPoints.
	sample := self sampler sample: (Dictionary new
			           at: (scheme groupNamed: 'G1') put: 3;
			           at: (scheme groupNamed: 'G4') put: 1;
			           yourself).

	self assert: (sample at: (scheme groupNamed: 'G1')) size equals: 3.
	self assert: (sample at: (scheme groupNamed: 'G4')) size equals: 1.
	sample keysAndValuesDo: [ :group :entries |
			entries do: [ :entry |
					self assert: entry group equals: group.
					self assert: (group includes: entry count).
					self assert: entry truth isNil.
					self assert: entry count equals: (scheme measure: entry ref compiledMethod) ] ]
]

{ #category : 'tests' }
HyMethodSamplerTest >> testSampledMethodsAreDistinct [
	"A method is drawn once"

	| scheme entries |
	scheme := HyGroupScheme returnPoints.
	entries := (self sampler sample: (Dictionary new
			             at: (scheme groupNamed: 'G1') put: 10;
			             yourself)) at: (scheme groupNamed: 'G1').

	self assert: (entries collect: [ :entry | entry ref ]) asSet size equals: entries size
]
