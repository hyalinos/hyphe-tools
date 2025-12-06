"
I am a method proxy handler. When a trapped method is being executed I collect its return value.
"
Class {
	#name : 'MpTypeFeedbackHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'collector',
		'method'
	],
	#category : 'Hyphe-Tools-TestProfiler',
	#package : 'Hyphe-Tools',
	#tag : 'TestProfiler'
}

{ #category : 'evaluating' }
MpTypeFeedbackHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: returnValue [

	collector addCollectedType: 
			{ method selector . method realClass . method package name .
			returnValue class }
]

{ #category : 'evaluating' }
MpTypeFeedbackHandler >> collector: anObject [

	collector := anObject
]

{ #category : 'initialization' }
MpTypeFeedbackHandler >> initialize [

	super initialize
]

{ #category : 'accessing' }
MpTypeFeedbackHandler >> method [

	^ method
]

{ #category : 'accessing' }
MpTypeFeedbackHandler >> method: aMethod [

	method := aMethod 
]
