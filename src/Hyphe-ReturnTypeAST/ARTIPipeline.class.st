"
REQ-A3, REQ-U1..U4. Ties gates + reachability + the 10 checks together into the per-method result,
separate from both the reachability engine and any individual check.
"
Class {
	#name : 'ARTIPipeline',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Pipeline',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Pipeline'
}

{ #category : 'accessing' }
ARTIPipeline class >> allChecks [
	"REQ-A1: each of the 12 checks (the original 10, plus ARTIDynamicArrayCheck and
	ARTISingleAssignmentTempCheck, both added after comparing against OCTypingVisitor) is
	independent; this is the only place that knows the full list."

	^ {
		  ARTILiteralCheck.
		  ARTIClassGlobalReadCheck.
		  ARTISelfCheck.
		  ARTISelfClassCheck.
		  ARTIImplicitNoReturnCheck.
		  ARTIBottomCheck.
		  ARTIClassNameNewCheck.
		  ARTITypeVarCheck.
		  ARTICascadeShapeCheck.
		  ARTIBlockLiteralCheck.
		  ARTIDynamicArrayCheck.
		  ARTISingleAssignmentTempCheck }
]

{ #category : 'classifying' }
ARTIPipeline class >> classifyTerminal: aTerminal context: aContext [
	"REQ-C1/REQ-C2: at most one check matches any given terminal, so first-match is unambiguous."

	self allChecks do: [ :checkClass |
			| result |
			result := checkClass classify: aTerminal context: aContext.
			result ifNotNil: [ ^ result ] ].
	^ nil
]

{ #category : 'inferring' }
ARTIPipeline class >> inferType: aCompiledMethod safetyTable: aSafetyTable [
	"REQ-U1..U4. Answers one of:
	- #excludedPrimitive  (REQ-G1: method carries a <primitive: N> pragma)
	- #excludedEmpty      (REQ-G2: method body has no statements)
	- an HTMType, the method's inferred return type"

	| methodNode terminals context classified anyNoMatch |
	(ARTIMethodGate isExcludedByPrimitive: aCompiledMethod) ifTrue: [
		^ #excludedPrimitive ].

	methodNode := aCompiledMethod ast.
	(ARTIMethodGate hasNoStatements: methodNode) ifTrue: [
		^ #excludedEmpty ].

	terminals := ARTIReachabilityEngine reachableTerminalsOf: methodNode.
	context := ARTICheckContext
		           methodNode: methodNode
		           safetyTable: aSafetyTable.

	classified := OrderedCollection new.
	anyNoMatch := false.
	terminals do: [ :terminal |
			| type |
			type := self classifyTerminal: terminal context: context.
			type
				ifNil: [ anyNoMatch := true ]
				ifNotNil: [
				(classified includes: type) ifFalse: [ classified add: type ] ] ].

	anyNoMatch ifTrue: [
			classified isEmpty ifTrue: [ ^ HTMUnknown new ].
			(classified includes: HTMUnknown new) ifFalse: [
				classified add: HTMUnknown new ] ].

	^ HTMUnion withMembers: classified
]
