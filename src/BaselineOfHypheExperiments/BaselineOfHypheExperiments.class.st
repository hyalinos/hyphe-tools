Class {
	#name : 'BaselineOfHypheExperiments',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheExperiments',
	#package : 'BaselineOfHypheExperiments'
}

{ #category : 'baselines' }
BaselineOfHypheExperiments >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: 'NeoCSV' with: [ spec repository: 'github://svenvc/NeoCSV/repository' ].
			spec
				baseline: 'HypheAnalysis'
				with: [ spec repository: 'github://hyalinos/hyphe-tools/src' ].
			spec
				baseline: 'HypheReturnTypeAST'
				with: [ spec repository: 'github://hyalinos/hyphe-tools/src' ].

			spec
				package: #'Hyphe-Experiments'
				with: [ spec requires: #( 'NeoCSV' 'HypheAnalysis' 'HypheReturnTypeAST' ) ];
				package: #'Hyphe-Experiments-Tests'
				with: [ spec requires: #( #'Hyphe-Experiments' ) ].

			spec
				group: 'Core' with: #( 'Hyphe-Experiments' 'Hyphe-Experiments-Tests' );
				group: 'default' with: #( 'Core' ) ]
]
