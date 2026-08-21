Class {
	#name : 'BaselineOfHypheCFG',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheCFG',
	#package : 'BaselineOfHypheCFG'
}

{ #category : 'baselines' }
BaselineOfHypheCFG class >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: #'Hyphe-CFG';
				package: #'Hyphe-CFG-Tests' with: [ spec requires: #(#'Hyphe-CFG') ].

			spec
				group: 'Core' with: #( 'Hyphe-CFG' 'Hyphe-CFG-Tests' );
				group: 'default' with: #( 'Core' ) ]
]
