Class {
	#name : 'BaselineOfHyMpReturnTypeProfiler',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHyMpReturnTypeProfiler',
	#package : 'BaselineOfHyMpReturnTypeProfiler'
}

{ #category : 'baselines' }
BaselineOfHyMpReturnTypeProfiler class >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: #MethodProxies with: [ spec repository: #'github://pharo-contributions/MethodProxies/src' ].

			spec
				package: #HyMpReturnTypeProfiler with: [ spec requires: #( #MethodProxies ) ];
				package: #'HyMpReturnTypeProfiler-Tests' with: [ spec requires: #( #HyMpReturnTypeProfiler ) ].

			spec
				group: 'Core' with: #( 'HyMpReturnTypeProfiler' 'HyMpReturnTypeProfiler-Tests' );
				group: 'default' with: #( 'Core' ) ]
]
