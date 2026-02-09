Class {
	#name : 'BaselineOfHypheTools',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheTools',
	#package : 'BaselineOfHypheTools'
}

{ #category : 'baselines' }
BaselineOfHypheTools >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: #'MethodProxies' with: [ spec repository: 'github://pharo-contributions/MethodProxies/src' ].

			spec 
				package: #'Hyphe-Tools' with: [ spec requires: #( #'MethodProxies' ) ];
				package: #'Hyphe-Tools-Tests' with: [ spec requires: #'Hyphe-Tools' ].

			spec
				group: 'Core' with: #( 'Hyphe-Tools' 'Hyphe-Tools-Tests' );
				group: 'default' with: #( 'Hyphe-Tools' 'Hyphe-Tools-Tests' ) 
	]
]
