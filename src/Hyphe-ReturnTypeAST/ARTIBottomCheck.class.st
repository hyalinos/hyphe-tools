"
Check 6 (Bottom). Matches a BottomTerminal (produced directly by ARTIReachabilityEngine for a
standalone Bottom-selector send to self/super) and returns Bottom. A *return* of such a send, e.g.
^ self error: 'x', is a plain ExplicitReturn terminal instead and is not matched by this check.
"
Class {
	#name : 'ARTIBottomCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTIBottomCheck class >> classify: aTerminal context: aContext [
	"Matches a BottomTerminal, produced by the reachability engine only for a standalone
	keyword/unary send of error:/halt/subclassResponsibility/shouldNotImplement/notYetImplemented
	to self/super. A return of such a send, e.g. ^ self error: 'x', is a plain ExplicitReturn
	terminal instead and is not matched by this check."

	(aTerminal isKindOf: ARTIBottomTerminal) ifFalse: [ ^ nil ].
	^ HTMBottom new
]
