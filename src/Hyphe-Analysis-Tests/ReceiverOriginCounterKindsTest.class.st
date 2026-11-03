"
The accessors of ReceiverOriginCounter that the main tests do not need, ClassMetrics and MethodMetrics accessors.
"
Class {
	#name : 'ReceiverOriginCounterKindsTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-Analysis-Tests',
	#package : 'Hyphe-Analysis-Tests'
}

{ #category : 'tests' }
ReceiverOriginCounterKindsTest >> testLocalVariablesOthersAndTotal [
	"receiverLocalVariables:, receiverOthers: and totalSends: on the method with a temporary, a block and a global"

	| counter method |
	counter := ReceiverOriginCounter new.
	method := MetricsTestData >> #sendsToLocals.

	self assert: (counter receiverLocalVariables: method) equals: 1.
	self assert: (counter receiverOthers: method) equals: 1.
	self assert: (counter totalSends: method) equals: 4
]

{ #category : 'tests' }
ReceiverOriginCounterKindsTest >> testMetricsAccessors [
	"The class and the method that are measured can be read"

	self assert: (ClassMetrics on: WmcTestParent) theClass equals: WmcTestParent.
	self deny: (ClassMetrics on: WmcTestParent) includeClassSide.
	self assert: (MethodMetrics on: MetricsTestData >> #noSends) method equals: MetricsTestData >> #noSends
]
