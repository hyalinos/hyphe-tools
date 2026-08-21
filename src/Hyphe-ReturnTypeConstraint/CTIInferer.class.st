Class {
	#name : 'CTIInferer',
	#superclass : 'Object',
	#instVars : [
		'universe',
		'implementorIndex',
		'methodInfos',
		'ivarNodes',
		'sendLinks',
		'queue',
		'queuedSet',
		'stats',
		'allVars',
		'linkQueue',
		'linkQueuedSet',
		'config',
		'numberMask'
	],
	#category : 'Hyphe-ReturnTypeConstraint',
	#package : 'Hyphe-ReturnTypeConstraint'
}

{ #category : 'entry points' }
CTIInferer class >> inferClass: aClass [

	| u inf seeds |
	u := CTIUniverse new.
	u buildFromImage.
	inf := self new.
	inf universe: u.
	seeds := OrderedCollection new.
	aClass selectors do: [ :s | seeds add: aClass -> s ].
	inf run: seeds.
	^ inf
]

{ #category : 'entry points' }
CTIInferer class >> inferImage [

	| u inf seeds |
	u := CTIUniverse new.
	u buildFromImage.
	inf := self new.
	inf universe: u.
	seeds := OrderedCollection new.
	Smalltalk allClasses do: [ :c | c selectors do: [ :s | seeds add: c -> s ] ].
	inf run: seeds.
	^ inf
]

{ #category : 'entry points' }
CTIInferer class >> inferPackage: aPackageName [

	| u inf seeds |
	u := CTIUniverse new.
	u buildFromImage.
	inf := self new.
	inf universe: u.
	seeds := OrderedCollection new.
	(Smalltalk allClasses select: [ :c |
			 [ c package name = aPackageName ]
				 on: Error
				 do: [ :e | false ] ]) do: [ :c | c selectors do: [ :s | seeds add: c -> s ] ].
	inf run: seeds.
	^ inf
]

{ #category : 'accessing' }
CTIInferer >> allVars [

	^ allVars
]

{ #category : 'solving' }
CTIInferer >> applyNewSelector: aSelector to: v [

	| newMax |
	self bump: #applyCalls.
	(v msgs includes: aSelector) ifTrue: [ ^ self ].
	self bump: #applyNewSelectorWork.
	v addMessage: aSelector.
	newMax := v maxBits bitAnd: (self implementorsOf: aSelector).
	newMax = v maxBits ifTrue: [ ^ self ].
	v maxBits: newMax.
	v subtypes do: [ :sub | self enqueue: sub ].
	(config singleImplementorHeuristic and: [ newMax ~= 0 and: [ (newMax bitAnd: newMax - 1) = 0 ] ]) ifTrue: [
			(v minBits bitAnd: newMax) = newMax ifFalse: [
					v minBits: (v minBits bitOr: newMax).
					v supertypes do: [ :sup | self enqueue: sup ] ] ]
]

{ #category : 'building' }
CTIInferer >> buildImplementorIndex [

	| idx cache |
	cache := Dictionary new.
	idx := Dictionary new: 80000.
	Smalltalk allClasses do: [ :c |
			| mask |
			mask := self subtreeMaskFor: c cache: cache.
			c selectors do: [ :s | idx at: s put: ((idx at: s ifAbsent: [ 0 ]) bitOr: mask) ] ].
	implementorIndex := idx.
	numberMask := self subtreeMaskFor: Number cache: cache
]

{ #category : 'building' }
CTIInferer >> buildNodeFor: aNode scope: scope info: info class: aClass [

	| cname |
	cname := aNode class name.
	cname == #OCLiteralValueNode ifTrue: [
			^ self newVar
				  minBits: (universe maskFor: aNode value class);
				  name: 'lit';
				  yourself ].
	(cname == #OCLiteralArrayNode or: [ cname == #OCArrayNode ]) ifTrue: [
			^ self newVar
				  minBits: (universe maskFor: Array);
				  name: 'arr';
				  yourself ].
	cname == #OCAssignmentNode ifTrue: [
			| rhs target |
			rhs := self
				       nodeFor: aNode value
				       scope: scope
				       info: info
				       class: aClass.
			target := self
				          nodeFor: aNode variable
				          scope: scope
				          info: info
				          class: aClass.
			target addSubtype: rhs.
			self enqueue: target.
			^ rhs ].
	cname == #OCVariableNode ifTrue: [
			^ self
				  nodeForVariable: aNode
				  scope: scope
				  info: info
				  class: aClass ].
	cname == #OCMessageNode ifTrue: [
			^ self
				  nodeForMessage: aNode
				  scope: scope
				  info: info
				  class: aClass ].
	(config blockEvaluationHeuristic and: [ cname == #OCBlockNode ]) ifTrue: [
			^ self
				  nodeForBlock: aNode
				  scope: scope
				  info: info
				  class: aClass ].
	^ self newVar
		  name: 'inert-' , cname;
		  yourself
]

{ #category : 'stats' }
CTIInferer >> bump: aKey [

	stats at: aKey put: (stats at: aKey ifAbsent: [ 0 ]) + 1
]

{ #category : 'reporting' }
CTIInferer >> classNamesFor: bits [

	| out b |
	out := OrderedCollection new.
	b := bits.
	[ b ~= 0 ] whileTrue: [
			| pos mask |
			pos := b lowBit.
			mask := 1 bitShift: pos - 1.
			out add: (universe classAt: pos - 1) name.
			b := b bitClear: mask ].
	^ out asSortedCollection asArray
]

{ #category : 'accessing' }
CTIInferer >> config [

	^ config
]

{ #category : 'accessing' }
CTIInferer >> config: aConfig [

	config := aConfig
]

{ #category : 'building' }
CTIInferer >> declaringClassFor: aClass ivarNamed: aName [

	| c |
	c := aClass.
	[ c notNil ] whileTrue: [
			(c instVarNames includes: aName) ifTrue: [ ^ c ].
			c := c superclass ].
	^ aClass
]

{ #category : 'solving' }
CTIInferer >> drainLinkQueue [

	| any |
	any := false.
	[ linkQueue isEmpty ] whileFalse: [
			| lnk |
			lnk := linkQueue removeFirst.
			linkQueuedSet remove: lnk.
			(config blockEvaluationHeuristic and: [ (self isBlockValueSelector: lnk selector) and: [ lnk receiverVar blockInfo notNil ] ])
				ifTrue: [
						| blk |
						blk := lnk receiverVar blockInfo.
						lnk argVars size = blk paramVars size ifTrue: [
								lnk argVars with: blk paramVars do: [ :a :p |
										p addSubtype: a.
										self enqueue: p ].
								lnk sendVar addSubtype: blk returnVar.
								self enqueue: lnk sendVar.
								any := true ] ]
				ifFalse: [
						| bits |
						bits := lnk receiverVar minBits bitXor: lnk linkedMask.
						bits ~= 0 ifTrue: [
								lnk linkedMask: lnk receiverVar minBits.
								[ bits ~= 0 ] whileTrue: [
										| bitPos mask cls linkInfo |
										self bump: #linkOnceBitScan.
										bitPos := bits lowBit.
										mask := 1 bitShift: bitPos - 1.
										cls := universe classAt: bitPos - 1.
										bits := bits bitClear: mask.
										linkInfo := self lookupMethod: cls selector: lnk selector.
										linkInfo ifNotNil: [
												lnk argVars with: linkInfo paramVars do: [ :a :p |
														p addSubtype: a.
														self enqueue: p ].
												lnk sendVar addSubtype: linkInfo returnVar.
												self enqueue: lnk sendVar.
												any := true ] ] ] ] ].
	^ any
]

{ #category : 'solving' }
CTIInferer >> drainQueue [

	[ queue isEmpty ] whileFalse: [
			| v |
			v := queue removeFirst.
			queuedSet remove: v.
			self processMin: v.
			self processMsgs: v ]
]

{ #category : 'solving' }
CTIInferer >> enqueue: aVar [

	(queuedSet includes: aVar) ifFalse: [
			queuedSet add: aVar.
			queue addLast: aVar ]
]

{ #category : 'solving' }
CTIInferer >> enqueueLink: aLink [

	(linkQueuedSet includes: aLink) ifFalse: [
			linkQueuedSet add: aLink.
			linkQueue addLast: aLink ]
]

{ #category : 'building' }
CTIInferer >> generateBlockBody: aNode info: info class: aClass scope: scope blockInfo: blk [

	| stmts last |
	stmts := aNode body statements.
	stmts isEmpty ifTrue: [
			blk returnVar minBits: (blk returnVar minBits bitOr: (universe maskFor: UndefinedObject)).
			self enqueue: blk returnVar.
			^ self ].
	stmts allButLast do: [ :s |
			self
				nodeFor: s
				scope: scope
				info: info
				class: aClass ].
	last := stmts last.
	last class name == #OCReturnNode
		ifTrue: [
				info returnVar addSubtype: (self
						 nodeFor: last value
						 scope: scope
						 info: info
						 class: aClass) ]
		ifFalse: [
				blk returnVar addSubtype: (self
						 nodeFor: last
						 scope: scope
						 info: info
						 class: aClass) ].
	self enqueue: blk returnVar
]

{ #category : 'building' }
CTIInferer >> generateBody: ast info: info class: aClass scope: scope [

	| sawReturn |
	sawReturn := false.
	ast body statements do: [ :s |
			s class name == #OCReturnNode
				ifTrue: [
						sawReturn := true.
						info returnVar addSubtype: (self
								 nodeFor: s value
								 scope: scope
								 info: info
								 class: aClass) ]
				ifFalse: [
						self
							nodeFor: s
							scope: scope
							info: info
							class: aClass ] ].
	sawReturn ifFalse: [ info returnVar addSubtype: info selfVar ].
	self enqueue: info returnVar
]

{ #category : 'building' }
CTIInferer >> generateForMethod: aClass selector: aSelector [

	| info ast scope |
	self bump: #genAttempts.
	info := self methodInfoFor: aClass selector: aSelector.
	info generated ifTrue: [ ^ info ].
	self bump: #genActual.
	info generated: true.
	info selfVar minBits: (info selfVar minBits bitOr: (universe maskFor: aClass)).
	ast := (aClass >> aSelector) ast.
	scope := Dictionary new.
	info paramVars: (ast arguments collect: [ :a |
				 | pv |
				 pv := self newVar
					       name: aClass name , '>>' , aSelector asString , '.' , a name;
					       yourself.
				 scope at: a name put: pv.
				 pv ]) asOrderedCollection.
	self
		generateBody: ast
		info: info
		class: aClass
		scope: scope.
	^ info
]

{ #category : 'accessing' }
CTIInferer >> implementorIndex [

	^ implementorIndex
]

{ #category : 'accessing' }
CTIInferer >> implementorsOf: aSelector [

	^ implementorIndex at: aSelector ifAbsent: [ 0 ]
]

{ #category : 'initialization' }
CTIInferer >> initialize [

	super initialize.
	methodInfos := Dictionary new.
	ivarNodes := Dictionary new.
	sendLinks := OrderedCollection new.
	queue := OrderedCollection new.
	queuedSet := IdentitySet new.
	allVars := OrderedCollection new.
	stats := Dictionary new.
	linkQueue := OrderedCollection new.
	linkQueuedSet := IdentitySet new.
	config := CTIConfig new
]

{ #category : 'building' }
CTIInferer >> isArithmeticSelector: aSelector [

	^ #( #+ #- #* #/ #'//' ) includes: aSelector
]

{ #category : 'building' }
CTIInferer >> isBlockValueSelector: aSelector [

	^ #( #value #value: #value:value: #value:value:value: #valueWithArguments: ) includes: aSelector
]

{ #category : 'building' }
CTIInferer >> isBlockValueSend: aNode [

	^ #( #value #value: #value:value: #value:value:value: #valueWithArguments: ) includes: aNode selector
]

{ #category : 'building' }
CTIInferer >> isPrimitiveCreation: aNode recv: recv [

	(aNode selector == #new or: [ aNode selector == #basicNew ]) ifFalse: [ ^ false ].
	recv class name == #OCVariableNode ifFalse: [ ^ false ].
	recv variable class name == #GlobalVariable ifFalse: [ ^ false ].
	^ recv variable value isKindOf: Behavior
]

{ #category : 'building' }
CTIInferer >> ivarNodeFor: aClass name: aName [

	| declaring key |
	declaring := self declaringClassFor: aClass ivarNamed: aName.
	key := declaring -> aName.
	^ ivarNodes at: key ifAbsentPut: [
			  self newVar
				  name: declaring name , '.' , aName;
				  yourself ]
]

{ #category : 'building' }
CTIInferer >> lookupMethod: aClass selector: aSelector [

	| c |
	c := aClass.
	[ c notNil ] whileTrue: [
			(c includesSelector: aSelector) ifTrue: [ ^ self generateForMethod: c selector: aSelector ].
			c := c superclass ].
	^ nil
]

{ #category : 'building' }
CTIInferer >> methodInfoFor: aClass selector: aSelector [

	| byClass |
	byClass := methodInfos at: aClass ifAbsentPut: [ Dictionary new ].
	^ byClass at: aSelector ifAbsentPut: [
			  | info |
			  info := CTIMethodInfo new.
			  info targetClass: aClass.
			  info selector: aSelector.
			  info returnVar: (self newVar
					   name: aClass name , '>>' , aSelector asString , '^';
					   yourself).
			  info selfVar: (self newVar
					   name: aClass name , '>>' , aSelector asString , '.self';
					   yourself).
			  info ]
]

{ #category : 'accessing' }
CTIInferer >> methodInfos [

	^ methodInfos
]

{ #category : 'building' }
CTIInferer >> newVar [

	| v |
	v := CTIVar new.
	v maxBits: universe allMask.
	allVars add: v.
	self enqueue: v.
	^ v
]

{ #category : 'building' }
CTIInferer >> nodeFor: aNode scope: scope info: info class: aClass [

	^ self
		  buildNodeFor: aNode
		  scope: scope
		  info: info
		  class: aClass
]

{ #category : 'building' }
CTIInferer >> nodeForBlock: aNode scope: scope info: info class: aClass [

	| blk blockScope v |
	blk := CTIBlockInfo new.
	blockScope := scope copy.
	blk paramVars: (aNode arguments collect: [ :a |
				 | pv |
				 pv := self newVar
					       name: 'blockParam-' , a name;
					       yourself.
				 blockScope at: a name put: pv.
				 pv ]) asOrderedCollection.
	blk returnVar: (self newVar
			 name: 'blockReturn';
			 yourself).
	self
		generateBlockBody: aNode
		info: info
		class: aClass
		scope: blockScope
		blockInfo: blk.
	v := self newVar
		     name: 'block';
		     yourself.
	v blockInfo: blk.
	^ v
]

{ #category : 'building' }
CTIInferer >> nodeForMessage: aNode scope: scope info: info class: aClass [

	| recvNode argNodes sendVar link recv |
	recv := aNode receiver.
	recvNode := self
		            nodeFor: recv
		            scope: scope
		            info: info
		            class: aClass.
	argNodes := aNode arguments collect: [ :a |
			            self
				            nodeFor: a
				            scope: scope
				            info: info
				            class: aClass ].
	self applyNewSelector: aNode selector to: recvNode.
	(config basicNewHeuristic and: [ self isPrimitiveCreation: aNode recv: recv ]) ifTrue: [
			^ self newVar
				  minBits: (universe maskFor: recv variable value);
				  name: 'new-' , aNode selector;
				  yourself ].
	(config arithmeticHeuristic and: [ self isArithmeticSelector: aNode selector ]) ifTrue: [
			^ self newVar
				  minBits: numberMask;
				  name: 'arith-' , aNode selector;
				  yourself ].
	sendVar := self newVar
		           name: 'send-' , aNode selector;
		           yourself.
	link := CTISendLink new.
	link
		receiverVar: recvNode;
		argVars: argNodes;
		sendVar: sendVar;
		selector: aNode selector.
	sendLinks add: link.
	recvNode addLinkClient: link.
	self enqueueLink: link.
	^ sendVar
]

{ #category : 'building' }
CTIInferer >> nodeForVariable: aNode scope: scope info: info class: aClass [

	| v vname vcname |
	v := aNode variable.
	vcname := v class name.
	(vcname == #SelfVariable or: [ vcname == #SuperVariable ]) ifTrue: [ ^ info selfVar ].
	vname := v name.
	vcname == #ArgumentVariable ifTrue: [
			^ scope at: vname ifAbsent: [
					  self newVar
						  name: vname;
						  yourself ] ].
	vcname == #TemporaryVariable ifTrue: [
			^ scope at: vname ifAbsentPut: [
					  self newVar
						  name: vname;
						  yourself ] ].
	vcname == #InstanceVariableSlot ifTrue: [ ^ self ivarNodeFor: aClass name: vname ].
	^ self newVar
		  name: 'var-' , vname;
		  yourself
]

{ #category : 'exporting' }
CTIInferer >> printCSVTo: aFileReference [

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream |
			ZnBufferedWriteStream
				on: stream
				do: [ :out |
						| writer |
						writer := NeoCSVWriter on: out.
						writer writeHeader: { #Package. #Class. #ClassSide. #Selector. #Type }.
						methodInfos keysAndValuesDo: [ :cls :bySelector |
								bySelector keysAndValuesDo: [ :sel :info |
										| pkgName typeStr |
										typeStr := (self typeFor: info returnVar minBits) asString.
										pkgName := [ cls package name ]
											           on: Error
											           do: [ :e | '' ].
										writer nextPut: {
												pkgName asString.
												cls name asString.
												false.
												sel asString.
												typeStr } ] ] ] ]
]

{ #category : 'solving' }
CTIInferer >> processMin: v [

	| newMin |
	self bump: #minCalls.
	newMin := v minBits.
	v subtypes do: [ :s | newMin := newMin bitOr: s minBits ].
	v blockInfo isNil ifTrue: [
			v subtypes do: [ :s |
					(v blockInfo isNil and: [ s blockInfo notNil ]) ifTrue: [
							v blockInfo: s blockInfo.
							v linkClients do: [ :lnk | self enqueueLink: lnk ] ] ] ].
	newMin ~= v minBits ifTrue: [
			v minBits: newMin.
			v supertypes do: [ :sup | self enqueue: sup ].
			v linkClients do: [ :lnk | self enqueueLink: lnk ] ]
]

{ #category : 'solving' }
CTIInferer >> processMsgs: v [

	self bump: #msgsCalls.
	v supertypes do: [ :sup | sup msgs do: [ :sel | self applyNewSelector: sel to: v ] ]
]

{ #category : 'solving' }
CTIInferer >> run: seedPairs [

	| progressed rounds |
	self buildImplementorIndex.
	seedPairs do: [ :pair | self generateForMethod: pair key selector: pair value ].
	rounds := 0.
	[
		self drainQueue.
		progressed := self drainLinkQueue.
		rounds := rounds + 1.
		progressed ] whileTrue.
	^ rounds
]

{ #category : 'accessing' }
CTIInferer >> sendLinks [

	^ sendLinks
]

{ #category : 'stats' }
CTIInferer >> statsReport [

	^ stats associations asSortedCollection: [ :a :b | a key <= b key ]
]

{ #category : 'building' }
CTIInferer >> subtreeMaskFor: aClass cache: cache [

	^ cache at: aClass ifAbsentPut: [
			  | mm |
			  mm := universe maskFor: aClass.
			  aClass subclasses do: [ :sub | mm := mm bitOr: (self subtreeMaskFor: sub cache: cache) ].
			  mm ]
]

{ #category : 'reporting' }
CTIInferer >> typeFor: bits [

	| names |
	names := self classNamesFor: bits.
	names isEmpty ifTrue: [ ^ HTMType unknown ].
	names size = 1 ifTrue: [ ^ HTMType classRef: names first ].
	^ HTMType union: (names collect: [ :n | HTMType classRef: n ])
]

{ #category : 'accessing' }
CTIInferer >> universe [

	^ universe
]

{ #category : 'accessing' }
CTIInferer >> universe: u [

	universe := u
]
