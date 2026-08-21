Class {
	#name : 'BaselineOfHyphe',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHyphe',
	#package : 'BaselineOfHyphe'
}

{ #category : 'baselines' }
BaselineOfHyphe class >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: #'MethodProxies' with: [ spec repository: #'github://pharo-contributions/MethodProxies/src' ].
			spec baseline: #'NeoCSV' with: [ spec repository: #'github://pharo-contributions/NeoCSV/src' ].

			spec
				package: #'Hyphe-TypeModel';
				package: #'Hyphe-ReturnTypeAST' with: [ spec requires: #( #'Hyphe-TypeModel' #'NeoCSV' ) ];
				package: #'Hyphe-ReturnTypeAST-Tests' with: [ spec requires: #( #'Hyphe-ReturnTypeAST' ) ];
				package: #'Hyphe-ReturnTypeAST-Analysis' with: [ spec requires: #( #'Hyphe-ReturnTypeAST' #'NeoCSV' ) ];
				package: #'Hyphe-ReturnTypeAST-Analysis-Tests' with: [ spec requires: #( #'Hyphe-ReturnTypeAST-Analysis' #'Hyphe-ReturnTypeAST-Tests' ) ];
				package: #'Hyphe-ReturnTypeHeuristic' with: [ spec requires: #( #'Hyphe-TypeModel' ) ];
				package: #'Hyphe-ReturnTypeHeuristic-Tests' with: [ spec requires: #( #'Hyphe-ReturnTypeHeuristic' ) ];
				package: #'Hyphe-ReturnTypeConstraint' with: [ spec requires: #( #'Hyphe-TypeModel' ) ];
				package: #'Hyphe-ReturnTypeConstraint-Tests' with: [ spec requires: #( #'Hyphe-ReturnTypeConstraint' ) ];
				package: #'Hyphe-ReturnTypeConstraint-UI' with: [ spec requires: #( #'Hyphe-ReturnTypeConstraint' ) ];
				package: #'Hyphe-Analysis' with: [ spec requires: #( #'MethodProxies' #'NeoCSV' ) ];
				package: #'Hyphe-Analysis-Tests' with: [ spec requires: #( #'Hyphe-Analysis' ) ];
				package: #'Hyphe-CFG';
				package: #'Hyphe-CFG-Tests' with: [ spec requires: #( #'Hyphe-CFG' ) ].

			spec
				group: #'inference'
				with: #( #'Hyphe-TypeModel'
					   #'Hyphe-ReturnTypeAST' #'Hyphe-ReturnTypeAST-Tests'
					   #'Hyphe-ReturnTypeHeuristic' #'Hyphe-ReturnTypeHeuristic-Tests'
					   #'Hyphe-ReturnTypeConstraint' #'Hyphe-ReturnTypeConstraint-Tests' );
				group: #'analysis'
				with: #( #'Hyphe-Analysis' #'Hyphe-Analysis-Tests' #'Hyphe-CFG' #'Hyphe-CFG-Tests'
					   #'Hyphe-ReturnTypeAST-Analysis' #'Hyphe-ReturnTypeAST-Analysis-Tests' );
				group: #'all'
				with: #( #'inference' #'analysis' #'Hyphe-ReturnTypeConstraint-UI' );
				group: #'default' with: #( #'all' ) ]
]
