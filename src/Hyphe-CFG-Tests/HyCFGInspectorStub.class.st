"
An inspector that does not open dialogs, for tests: the file name the user would type is given with answerFilename:, the requests and the messages shown to the user are recorded.
"
Class {
	#name : 'HyCFGInspectorStub',
	#superclass : 'HyCFGInspector',
	#instVars : [
		'answeredFilename',
		'requests',
		'informed'
	],
	#category : 'Hyphe-CFG-Tests-UI',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'UI'
}

{ #category : 'accessing' }
HyCFGInspectorStub >> answerFilename: aStringOrNil [
	"Set what the user answers when asked for a file name (nil is cancelling)"

	answeredFilename := aStringOrNil
]

{ #category : 'exporting' }
HyCFGInspectorStub >> inform: aString [
	"Do not show anything: record the message"

	self informed add: aString
]

{ #category : 'accessing' }
HyCFGInspectorStub >> informed [
	"Answer the messages shown to the user"

	^ informed ifNil: [ informed := OrderedCollection new ]
]

{ #category : 'exporting' }
HyCFGInspectorStub >> requestFilename: aPrompt default: aFilename [
	"Do not ask: record the request and answer what was set with answerFilename:"

	self requests add: {
			aPrompt.
			aFilename }.
	^ answeredFilename
]

{ #category : 'accessing' }
HyCFGInspectorStub >> requests [
	"Answer the prompts and the default names the user was asked about, as { prompt. default } pairs"

	^ requests ifNil: [ requests := OrderedCollection new ]
]
