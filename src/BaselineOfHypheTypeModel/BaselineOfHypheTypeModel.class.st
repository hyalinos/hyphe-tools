Class {
	#name : 'BaselineOfHypheTypeModel',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheTypeModel',
	#package : 'BaselineOfHypheTypeModel'
}

{ #category : 'baselines' }
BaselineOfHypheTypeModel class >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec package: 'Hyphe-TypeModel'.
			spec
				group: 'Core' with: #( 'Hyphe-TypeModel' );
				group: 'default' with: #( 'Core' ) ]
]
