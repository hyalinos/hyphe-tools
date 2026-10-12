Class {
	#name : 'BaselineOfHyMpReturnTypeProfiler',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHyMpReturnTypeProfiler',
	#package : 'BaselineOfHyMpReturnTypeProfiler'
}

{ #category : 'baselines' }
BaselineOfHyMpReturnTypeProfiler >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: #MethodProxies with: [ spec repository: #'github://pharo-contributions/MethodProxies/src' ].

			spec
				package: #'Hyphe-TypeModel';
				package: #HyMpReturnTypeProfiler with: [ spec requires: #(#'Hyphe-TypeModel' #MethodProxies ) ];
				package: #'HyMpReturnTypeProfiler-Tests' with: [ spec requires: #( #HyMpReturnTypeProfiler ) ].

			spec
				group: 'Core' with: #(#'Hyphe-TypeModel' 'HyMpReturnTypeProfiler' 'HyMpReturnTypeProfiler-Tests' );
				group: 'default' with: #( 'Core' ) ]
]
