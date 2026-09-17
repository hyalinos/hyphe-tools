"
One instance per instrumented method (not shared across methods, unlike a single global handler) -- definingClass/selector are fixed at creation time since a single MpMethodProxy always wraps one specific compiled method. Overrides MpHandler's arity-specific after-hooks (0 through 5 arguments -- MethodProxies' own hard limit, canHandle:'s arity < 6) to capture the receiver's actual class and the return value's actual class, then forwards to the shared collector. Deliberately does NOT override any before/instead hooks or the generic arguments:-taking variant -- MpMethodProxy's own prototypeTrapMethod picks the trap shape by reflectively checking which arity-specific selectors are overridden, and the generic variant is not one of them (confirmed live: overriding only the generic hook silently never fires).
"
Class {
	#name : 'HyMpReturnsHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'collector',
		'definingClass',
		'selector'
	],
	#category : 'HyMpReturnTypeProfiler',
	#package : 'HyMpReturnTypeProfiler'
}

{ #category : 'hooks' }
HyMpReturnsHandler >> afterExecutionWithReceiver: anObject returnValue: aReturnValue [

	self record: anObject returnValue: aReturnValue.
	^ aReturnValue
]

{ #category : 'hooks' }
HyMpReturnsHandler >> afterExecutionWithReceiver: anObject with: arg1 returnValue: aReturnValue [

	self record: anObject returnValue: aReturnValue.
	^ aReturnValue
]

{ #category : 'hooks' }
HyMpReturnsHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 returnValue: aReturnValue [

	self record: anObject returnValue: aReturnValue.
	^ aReturnValue
]

{ #category : 'hooks' }
HyMpReturnsHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 returnValue: aReturnValue [

	self record: anObject returnValue: aReturnValue.
	^ aReturnValue
]

{ #category : 'hooks' }
HyMpReturnsHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 returnValue: aReturnValue [

	self record: anObject returnValue: aReturnValue.
	^ aReturnValue
]

{ #category : 'hooks' }
HyMpReturnsHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 returnValue: aReturnValue [

	self record: anObject returnValue: aReturnValue.
	^ aReturnValue
]

{ #category : 'initialization' }
HyMpReturnsHandler >> collector: aCollector definingClass: dClass selector: aSelector [
	"One handler instance per instrumented method -- definingClass/selector never change
	 for the life of this handler, since it's always paired 1:1 with one MpMethodProxy
	 wrapping one specific compiled method."

	collector := aCollector.
	definingClass := dClass.
	selector := aSelector
]

{ #category : 'recording' }
HyMpReturnsHandler >> record: anObject returnValue: aReturnValue [
	"Shared by every arity-specific hook below. Never lets a recording failure break the
	 real call -- the whole point of after-only instrumentation is that it cannot affect
	 the value already computed, and a bug here must not change that."

	[
		collector
			recordReceiver: anObject class
			definingClass: definingClass
			selector: selector
			returnClass: aReturnValue class ]
		on: Error
		do: [ :e |  ]
]
