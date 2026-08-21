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
				package: #'Hyphe-ReturnTypeConstraint';
				package: #'Hyphe-ReturnTypeConstraint-Tests' with: [ spec requires: #'Hyphe-ReturnTypeConstraint' ].

			spec
				group: 'Core' with: #( 'Hyphe-ReturnTypeConstraint' 'Hyphe-ReturnTypeConstraint-Tests' );
				group: 'default' with: #( 'Core' ) ]
]
