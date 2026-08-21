Class {
	#name : 'BaselineOfHypheReturnTypeConstraint',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheReturnTypeConstraint',
	#package : 'BaselineOfHypheReturnTypeConstraint'
}

{ #category : 'baselines' }
BaselineOfHypheReturnTypeConstraint class >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: #'Hyphe-TypeModel';
				package: #'Hyphe-ReturnTypeConstraint' with: [ spec requires: #( #'Hyphe-TypeModel' ) ];
				package: #'Hyphe-ReturnTypeConstraint-Tests' with: [ spec requires: #( #'Hyphe-ReturnTypeConstraint' ) ];
				package: #'Hyphe-ReturnTypeConstraint-UI' with: [ spec requires: #( #'Hyphe-ReturnTypeConstraint' ) ].

			spec
				group: #'Core' with: #( #'Hyphe-TypeModel' #'Hyphe-ReturnTypeConstraint' #'Hyphe-ReturnTypeConstraint-Tests' );
				group: #'UI' with: #( #'Hyphe-ReturnTypeConstraint-UI' );
				group: #'All' with: #( #'Core' #'UI' );
				group: #'default' with: #( #'Core' ) ]
]
