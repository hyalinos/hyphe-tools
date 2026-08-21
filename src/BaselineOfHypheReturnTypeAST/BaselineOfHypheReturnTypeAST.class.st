Class {
	#name : 'BaselineOfHypheReturnTypeAST',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheReturnTypeAST',
	#package : 'BaselineOfHypheReturnTypeAST'
}

{ #category : 'baselines' }
BaselineOfHypheReturnTypeAST >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: #'NeoCSV' with: [ spec repository: #'github://pharo-contributions/NeoCSV/src' ].

			spec
				package: #'Hyphe-TypeModel';
				package: #'Hyphe-ReturnTypeAST'
				with: [ spec requires: #(#'Hyphe-TypeModel' #'NeoCSV') ];
				package: #'Hyphe-ReturnTypeAST-Tests'
				with: [ spec requires: #(#'Hyphe-ReturnTypeAST') ];
				package: #'Hyphe-ReturnTypeAST-Analysis'
				with: [ spec requires: #(#'Hyphe-ReturnTypeAST' #'NeoCSV') ];
				package: #'Hyphe-ReturnTypeAST-Analysis-Tests' with: [
						spec requires:
								#( #'Hyphe-ReturnTypeAST-Analysis'
								   #'Hyphe-ReturnTypeAST-Tests' ) ].

			spec
				group: #'Core'
				with: #( #'Hyphe-TypeModel' #'Hyphe-ReturnTypeAST' #'Hyphe-ReturnTypeAST-Tests' );
				group: #'All'
				with: #( #'Hyphe-TypeModel' #'Hyphe-ReturnTypeAST' #'Hyphe-ReturnTypeAST-Tests'
					   #'Hyphe-ReturnTypeAST-Analysis' #'Hyphe-ReturnTypeAST-Analysis-Tests' );
				group: #'default' with: #( #'Core' ) ]
]
