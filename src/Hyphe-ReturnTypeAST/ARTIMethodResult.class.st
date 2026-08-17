"
One output record: a reference to a processed method (package/class/selector/classSide,
sufficient to re-identify it) together with its inferred ARTIType (see ARTIPipeline). Instances are
created only via the class-side #package:class:selector:classSide:type:.
"
Class {
	#name : 'ARTIMethodResult',
	#superclass : 'Object',
	#instVars : [
		'packageName',
		'className',
		'selector',
		'classSide',
		'type'
	],
	#category : 'Hyphe-ReturnTypeAST-Pipeline',
	#package : 'Hyphe-ReturnTypeAST',
	#tag : 'Pipeline'
}

{ #category : 'instance creation' }
ARTIMethodResult class >> package: aPackageName class: aClassName selector: aSelector classSide: aBoolean type: aType [

	^ self new
		  setPackage: aPackageName
		  class: aClassName
		  selector: aSelector
		  classSide: aBoolean
		  type: aType;
		  yourself
]

{ #category : 'accessing' }
ARTIMethodResult >> className [

	^ className
]

{ #category : 'accessing' }
ARTIMethodResult >> classSide [

	^ classSide
]

{ #category : 'accessing' }
ARTIMethodResult >> packageName [

	^ packageName
]

{ #category : 'printing' }
ARTIMethodResult >> printOn: aStream [

	aStream
		nextPutAll: packageName asString;
		nextPutAll: '.';
		nextPutAll: className asString.
	classSide ifTrue: [ aStream nextPutAll: ' class' ].
	aStream
		nextPutAll: '>>#';
		nextPutAll: selector asString;
		nextPutAll: ' -> ';
		print: type
]

{ #category : 'accessing' }
ARTIMethodResult >> selector [

	^ selector
]

{ #category : 'private' }
ARTIMethodResult >> setPackage: aPackageName class: aClassName selector: aSelector classSide: aBoolean type: aType [

	packageName := aPackageName.
	className := aClassName.
	selector := aSelector.
	classSide := aBoolean.
	type := aType
]

{ #category : 'accessing' }
ARTIMethodResult >> type [

	^ type
]
