"
Extension check (added after the original 10, plus ARTIDynamicArrayCheck; see the
comparison-with-OCTypingVisitor findings). Matches ExplicitReturn(Expr) where Expr is a read of a
TemporaryVariable that is assigned exactly once anywhere in the method, where that one assignment is
itself a direct, unconditional top-level statement of the method body, and where the terminal being
classified occurs in a later top-level statement -- i.e. the assignment is guaranteed to have already
run. The assigned values own type is then determined by delegating to the same fixed set of checks
ARTICascadeShapeCheck delegates to (plus itself is deliberately excluded from that set, to keep
classification single-pass -- see the design discussion: chains like x := 5. y := x. ^ y are out of
scope for this version and remain Unknown). Deliberately scoped to TemporaryVariable only, never
instance/class variables: only a literal assignment node in this same method can change a temps
value, whereas an instance variable could be mutated as a side effect of any message send between the
assignment and the read, which this static, single-method analysis cannot see.
"
Class {
	#name : 'ARTISingleAssignmentTempCheck',
	#superclass : 'Object',
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'classifying' }
ARTISingleAssignmentTempCheck class >> classify: aTerminal context: aContext [

	| exprNode methodNode tempName assignmentStatement laterStatement |
	(aTerminal isKindOf: ARTIExplicitReturnTerminal) ifFalse: [ ^ nil ].
	exprNode := aTerminal returnValueNode.
	(exprNode isKindOf: OCVariableNode) ifFalse: [ ^ nil ].
	(exprNode variable isKindOf: TemporaryVariable) ifFalse: [ ^ nil ].

	methodNode := aContext methodNode.
	tempName := exprNode variable name.
	assignmentStatement := self
		                       soleTopLevelAssignmentTo: tempName
		                       in: methodNode.
	assignmentStatement ifNil: [ ^ nil ].

	laterStatement := (self
		                   statementsAfter: assignmentStatement
		                   in: methodNode)
		                  detect: [ :stmt |
		                  self
			                  statement: stmt
			                  containsNode: aTerminal returnNode ]
		                  ifNone: [ nil ].
	laterStatement ifNil: [ ^ nil ].

	^ self classifyRhs: assignmentStatement value context: aContext
]

{ #category : 'private' }
ARTISingleAssignmentTempCheck class >> classifyRhs: exprNode context: aContext [

	self delegateCheckClasses do: [ :checkClass |
			| result |
			result := checkClass matchExpr: exprNode context: aContext.
			result ifNotNil: [ ^ result ] ].
	^ nil
]

{ #category : 'accessing' }
ARTISingleAssignmentTempCheck class >> delegateCheckClasses [
	"The type of the single assignment's right-hand side is determined by delegating to exactly these
	checks -- deliberately excluding this check itself, so classification stays a single pass with no
	fixed-point iteration (see the design discussion: chained temp-to-temp assignments like
	x := 5. y := x. ^ y are out of scope for this version)."

	^ {
		  ARTILiteralCheck.
		  ARTIClassGlobalReadCheck.
		  ARTISelfCheck.
		  ARTISelfClassCheck.
		  ARTIClassNameNewCheck.
		  ARTITypeVarCheck.
		  ARTICascadeShapeCheck.
		  ARTIBlockLiteralCheck.
		  ARTIDynamicArrayCheck }
]

{ #category : 'private' }
ARTISingleAssignmentTempCheck class >> soleTopLevelAssignmentTo: aName in: methodNode [
	"Answers the method's own top-level statement that assigns aName, provided that is the *only*
	assignment to aName anywhere in the method (including inside nested blocks/branches) and that
	assignment is itself a direct, unconditional top-level statement (not nested inside a conditional
	branch). Otherwise answers nil -- either case is too complex to classify soundly in this version."

	| matchingAssignments assignmentNode |
	matchingAssignments := methodNode assignmentNodes select: [ :a |
		                       a variable name = aName ].
	matchingAssignments size = 1 ifFalse: [ ^ nil ].
	assignmentNode := matchingAssignments first.
	^ methodNode body statements
		  detect: [ :s | s == assignmentNode ]
		  ifNone: [ nil ]
]

{ #category : 'private' }
ARTISingleAssignmentTempCheck class >> statement: aStatement containsNode: aTargetNode [
	"Whether aTargetNode is aStatement itself or occurs anywhere within it -- including inside nested
	conditional branches -- used to confirm a terminal is reached only after the defining assignment."

	^ aStatement == aTargetNode or: [
		  aStatement allChildren anySatisfy: [ :each | each == aTargetNode ] ]
]

{ #category : 'private' }
ARTISingleAssignmentTempCheck class >> statementsAfter: aStatement in: methodNode [

	| statements index |
	statements := methodNode body statements.
	index := statements indexOf: aStatement.
	index = 0 ifTrue: [ ^ #(  ) ].
	^ statements copyFrom: index + 1 to: statements size
]
