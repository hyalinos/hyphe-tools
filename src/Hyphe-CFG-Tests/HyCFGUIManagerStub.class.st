"
A UI manager that answers the requests of a dialog without showing it, for tests. Install it with UIManager default: and put the previous one back afterwards.
"
Class {
	#name : 'HyCFGUIManagerStub',
	#superclass : 'UIManager',
	#instVars : [
		'answer',
		'prompts'
	],
	#category : 'Hyphe-CFG-Tests-UI',
	#package : 'Hyphe-CFG-Tests',
	#tag : 'UI'
}

{ #category : 'accessing' }
HyCFGUIManagerStub >> answer: aString [
	"Set what the user types in the dialog"

	answer := aString
]

{ #category : 'accessing' }
HyCFGUIManagerStub >> prompts [
	"Answer the prompts and initial answers of the dialogs requested, as { prompt. initial answer } pairs"

	^ prompts ifNil: [ prompts := OrderedCollection new ]
]

{ #category : 'requests' }
HyCFGUIManagerStub >> request: aStringOrText initialAnswer: defaultAnswer [
	"Do not open a dialog: record the request and answer what was set"

	self prompts add: {
			aStringOrText.
			defaultAnswer }.
	^ answer
]
