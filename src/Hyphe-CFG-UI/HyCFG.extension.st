Extension { #name : 'HyCFG' }

{ #category : '*Hyphe-CFG-UI' }
HyCFG >> inspect [
	"Open the CFG inspector instead of the default inspector"

	^ self openInspector
]

{ #category : '*Hyphe-CFG-UI' }
HyCFG >> openInspector [
	"Open the Spec2 inspector on this CFG and answer it"

	^ HyCFGInspector openOn: self
]
