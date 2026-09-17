"
A single observation: one instrumented method call, captured after it returned normally. Records the actual runtime receiver class (which may differ from definingClass due to inheritance), where the method is defined, its selector, and the actual class of the value it returned.
"
Class {
	#name : 'HyMpObservation',
	#superclass : 'Object',
	#instVars : [
		'receiverClass',
		'definingClass',
		'selector',
		'returnClass'
	],
	#category : 'HyMpReturnTypeProfiler',
	#package : 'HyMpReturnTypeProfiler'
}

{ #category : 'accessing' }
HyMpObservation >> definingClass [

	^ definingClass
]

{ #category : 'printing' }
HyMpObservation >> printOn: aStream [

	aStream
		nextPutAll: definingClass name asString;
		nextPutAll: '>>';
		print: selector;
		nextPutAll: ' -> ';
		nextPutAll: returnClass name asString
]

{ #category : 'accessing' }
HyMpObservation >> receiverClass [

	^ receiverClass
]

{ #category : 'initialization' }
HyMpObservation >> receiverClass: aClass definingClass: dClass selector: aSelector returnClass: rClass [

	receiverClass := aClass.
	definingClass := dClass.
	selector := aSelector.
	returnClass := rClass
]

{ #category : 'accessing' }
HyMpObservation >> returnClass [

	^ returnClass
]

{ #category : 'accessing' }
HyMpObservation >> selector [

	^ selector
]
