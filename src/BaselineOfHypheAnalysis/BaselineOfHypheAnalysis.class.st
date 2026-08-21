Class {
	#name : 'BaselineOfHypheAnalysis',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheAnalysis',
	#package : 'BaselineOfHypheAnalysis'
}

{ #category : 'baselines' }
BaselineOfHypheAnalysis class >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: #'MethodProxies' with: [ spec repository: #'github://pharo-contributions/MethodProxies/src' ].
			spec baseline: #'NeoCSV' with: [ spec repository: #'github://pharo-contributions/NeoCSV/src' ].

			spec
				package: #'Hyphe-Analysis' with: [ spec requires: #( #'MethodProxies' #'NeoCSV' ) ];
				package: #'Hyphe-Analysis-Tests' with: [ spec requires: #( #'Hyphe-Analysis' ) ].

			spec
				group: 'Core' with: #( 'Hyphe-Analysis' 'Hyphe-Analysis-Tests' );
				group: 'default' with: #( 'Core' ) ]
]

{ #category : 'baselines' }
BaselineOfHypheAnalysis >> baseline: spec [

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
