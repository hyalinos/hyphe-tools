Class {
	#name : 'BaselineOfHypheReturnTypeHeuristic',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheReturnTypeHeuristic',
	#package : 'BaselineOfHypheReturnTypeHeuristic'
}

{ #category : 'baselines' }
BaselineOfHypheReturnTypeHeuristic class >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: #'Hyphe-ReturnTypeHeuristic';
				package: #'Hyphe-ReturnTypeHeuristic-Tests'
				with: [ spec requires: #'Hyphe-ReturnTypeHeuristic' ].

			spec
				group: 'Core'
				with:
					#( 'Hyphe-ReturnTypeHeuristic' 'Hyphe-ReturnTypeHeuristic-Tests' );
				group: 'default' with: #( 'Core' ) ]
]
