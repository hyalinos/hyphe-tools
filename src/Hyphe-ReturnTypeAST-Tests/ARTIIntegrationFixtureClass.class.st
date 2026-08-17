"
Fixture class for ARTIIntegrationTest (REQ-T3): a small, deliberately varied mix
of methods (a literal return, a self return, a parameter return, a <primitive:>-gated method, an
empty-body method, and both a self-new and a safe-global-new class-side method) with a known expected
ARTIInferenceReport, used to exercise the full pipeline end to end rather than one check at a time.
"
Class {
	#name : 'ARTIIntegrationFixtureClass',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Tests-Fixtures',
	#package : 'Hyphe-ReturnTypeAST-Tests',
	#tag : 'Fixtures'
}

{ #category : 'fixtures' }
ARTIIntegrationFixtureClass class >> makeViaObjectNew [

	^ Object new
]

{ #category : 'fixtures' }
ARTIIntegrationFixtureClass class >> makeViaSelfNew [
	"self new is explicitly out of scope for check 7, and matches none of the other 9 checks either,
	so this deliberately surfaces as Unknown."

	^ self new
]

{ #category : 'fixtures' }
ARTIIntegrationFixtureClass >> emptyBody [
	"just a comment, no statements"

	
]

{ #category : 'fixtures' }
ARTIIntegrationFixtureClass >> hasPrimitive [

	<primitive: 60>
	^ self primitiveFailed: #hasPrimitive
]

{ #category : 'fixtures' }
ARTIIntegrationFixtureClass >> returnsArg: x [

	^ x
]

{ #category : 'fixtures' }
ARTIIntegrationFixtureClass >> returnsFive [

	^ 5
]

{ #category : 'fixtures' }
ARTIIntegrationFixtureClass >> returnsSelf [

	^ self
]
