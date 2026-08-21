Class {
	#name : 'RatioSelfSendsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
RatioSelfSendsTest >> testHighSelfMessage [
	| ratioSelf method ratio message|
	method := RatioSelfSendsTestData >> #highSelfMessage.
	ratioSelf := RatioSelfSends new.
	message := ratioSelf selfRatio: method.
	self assert: message equals: (5/7).
	
]

{ #category : 'tests' }
RatioSelfSendsTest >> testLowSelfMessage [
	| ratioSelf method ratio|
	method := RatioSelfSendsTestData >> #lowSelfMessage.
	ratioSelf := RatioSelfSends new.
	ratio := ratioSelf selfRatio: method.
	self assert: ratio equals: (1/2).
	
]

{ #category : 'tests' }
RatioSelfSendsTest >> testMediumSelfMessage [
	| ratioSelf method ratio|
	method := RatioSelfSendsTestData >> #mediumSelfMessage.
	ratioSelf := RatioSelfSends new.
	ratio := ratioSelf selfRatio: method.
	self assert: ratio equals: (3/4).
	
]

{ #category : 'tests' }
RatioSelfSendsTest >> testNoSelfMessage [
	| ratioSelf method ratio|
	method := RatioSelfSendsTestData >> #noSelfMessage.
	ratioSelf := RatioSelfSends new.
	ratio := ratioSelf selfRatio: method.
	self assert: ratio equals: (0).
	
]

{ #category : 'tests' }
RatioSelfSendsTest >> testVeryHighSelfMessage [
	| ratioSelf method ratio|
	method := RatioSelfSendsTestData >> #veryHighSelfMessage.
	ratioSelf := RatioSelfSends new.
	ratio := ratioSelf selfRatio: method.
	self assert: ratio equals: (3/5).
	
]
