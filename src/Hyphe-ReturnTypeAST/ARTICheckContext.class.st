"
Bundles the contextual information a check may need: the method's AST (OCMethodNode) and the
Layer-0 safety table. Individual checks use only what they declare they need.
"
Class {
	#name : 'ARTICheckContext',
	#superclass : 'Object',
	#instVars : [
		'methodNode',
		'safetyTable'
	],
	#category : 'Hyphe-ReturnTypeAST-Checks',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Checks'
}

{ #category : 'instance creation' }
ARTICheckContext class >> methodNode: aMethodNode safetyTable: aSafetyTable [

	^ self new
		  setMethodNode: aMethodNode safetyTable: aSafetyTable;
		  yourself
]

{ #category : 'accessing' }
ARTICheckContext >> methodNode [

	^ methodNode
]

{ #category : 'accessing' }
ARTICheckContext >> safetyTable [

	^ safetyTable
]

{ #category : 'private' }
ARTICheckContext >> setMethodNode: aMethodNode safetyTable: aSafetyTable [

	methodNode := aMethodNode.
	safetyTable := aSafetyTable
]
