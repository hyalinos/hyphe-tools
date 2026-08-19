"
Immutable snapshot of the calibration numbers reported for one ARTHPattern in selector-frequency-analysis.md: the determinate sample size used, the agreement rate against the AST ground-truth tool (Hyphe-ReturnTypeAST), and the largest single-package share among the determinate matches (the package-concentration check). Data only -- never consulted by the matching engine at runtime. Exists so the pattern catalog documents its own evidence, and so a future recalibration run can flag drift from these numbers.
"
Class {
	#name : 'ARTHCalibrationMetadata',
	#superclass : 'Object',
	#instVars : [
		'sampleSize',
		'agreementRatePercent',
		'packageSpreadTopSharePercent',
		'sourceNote'
	],
	#category : 'Hyphe-ReturnTypeHeuristic',
	#package : 'Hyphe-ReturnTypeHeuristic'
}

{ #category : 'instance creation' }
ARTHCalibrationMetadata class >> n: aSampleSize agreementRatePercent: aRate topSharePercent: aShare note: aNote [

	^ self new
		  setSampleSize: aSampleSize
		  agreementRatePercent: aRate
		  packageSpreadTopSharePercent: aShare
		  note: aNote
]

{ #category : 'accessing' }
ARTHCalibrationMetadata >> agreementRatePercent [

	^ agreementRatePercent
]

{ #category : 'accessing' }
ARTHCalibrationMetadata >> packageSpreadTopSharePercent [

	^ packageSpreadTopSharePercent
]

{ #category : 'printing' }
ARTHCalibrationMetadata >> printOn: aStream [

	aStream
		nextPutAll: 'n=';
		print: sampleSize;
		nextPutAll: ' rate=';
		print: agreementRatePercent;
		nextPutAll: '% top1=';
		print: packageSpreadTopSharePercent;
		nextPutAll: '%'
]

{ #category : 'accessing' }
ARTHCalibrationMetadata >> sampleSize [

	^ sampleSize
]

{ #category : 'private' }
ARTHCalibrationMetadata >> setSampleSize: aSampleSize agreementRatePercent: aRate packageSpreadTopSharePercent: aShare note: aNote [

	sampleSize := aSampleSize.
	agreementRatePercent := aRate.
	packageSpreadTopSharePercent := aShare.
	sourceNote := aNote
]

{ #category : 'accessing' }
ARTHCalibrationMetadata >> sourceNote [

	^ sourceNote
]
