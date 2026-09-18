"
Metacello baseline for Hyphe-Inferencer -- the Unconfident Type System / HYPHE inferencer (unconfident_type_system_full.md). Mirrors the DSL style of the sibling BaselineOfHypheReturnTypeAST etc.
"
Class {
	#name : 'BaselineOfHypheInferencer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfHypheInferencer',
	#package : 'BaselineOfHypheInferencer'
}

{ #category : 'baselines' }
BaselineOfHypheInferencer class >> baseline: spec [

	spec for: #common do: [
			spec
				package: 'Hyphe-Inferencer';
				package: 'Hyphe-Inferencer-Tests' with: [ spec requires: #( 'Hyphe-Inferencer' ) ].
			spec
				group: 'Core' with: #( 'Hyphe-Inferencer' );
				group: 'Tests' with: #( 'Hyphe-Inferencer-Tests' );
				group: 'All' with: #( 'Core' 'Tests' );
				group: 'default' with: #( 'Core' ) ]
]
