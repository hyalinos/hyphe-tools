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

			spec package: #'Hyphe-Tools' with: [ spec requires: #( #'MethodProxies' ) ].

			spec
				group: 'Core' with: #( #'Hyphe-Tools' );
				group: 'default' with: #( #'Hyphe-Tools' ) 
	]
]
