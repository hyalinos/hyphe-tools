"
I count the propostion of self sends message in a method
To run this code:
•	use a 'method:=  aClass >> aMethod ' as argument of the method who calculate the propostion of self sends :
    selfRatio: method.
"
Class {
	#name : 'RatioSelfSends',
	#superclass : 'OCProgramNodeVisitor',
	#instVars : [
		'selfNumber',
		'messageNumber'
	],
	#category : 'Hyphe-Analysis',
	#package : 'Hyphe-Analysis'
}

{ #category : 'as yet unclassified' }
RatioSelfSends class >> exampleRatioSelfSend [
  <script>
   | method count| 
	"Compiled method to analyze, as an argument"
	method := RatioSelfSendsTestData >> #highSelfMessage.
   "Return the proportion of message sends where the receiver is self, relative to the total number of sends."
	count := self new selfRatio: method.
	count inspect.
]

{ #category : 'initialization' }
RatioSelfSends >> initialize [ 
	super initialize.
	selfNumber := 0.
	messageNumber := 0.
]

{ #category : 'as yet unclassified' }
RatioSelfSends >> selfRatio: aMethod [
	| ratio |
	aMethod ast acceptVisitor: self.
	ratio := (selfNumber / messageNumber).
	^ ratio 
]

{ #category : 'initialization' }
RatioSelfSends >> visitMessageNode: aMessage [
    
	messageNumber := messageNumber + 1.
    
  super visitMessageNode: aMessage
]

{ #category : 'initialization' }
RatioSelfSends >> visitSelfNode: aSelfNode [
	selfNumber := selfNumber + 1.
	super visitSelfNode: aSelfNode 
]
