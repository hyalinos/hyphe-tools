Class {
	#name : 'CTIConfigurationPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'scopeAllRadio',
		'scopePackageRadio',
		'scopeClassRadio',
		'packageList',
		'classList',
		'basicNewCheck',
		'basicNewExample',
		'blockEvalCheck',
		'blockEvalExample',
		'arithmeticCheck',
		'arithmeticExample',
		'singleImplCheck',
		'singleImplExample',
		'changedLabel',
		'saveButton',
		'cancelButton',
		'defaultButton',
		'runButton',
		'statusLabel',
		'savedConfig'
	],
	#category : 'Hyphe-ReturnTypeConstraint-UI',
	#package : 'Hyphe-ReturnTypeConstraint-UI'
}

{ #category : 'instance creation' }
CTIConfigurationPresenter class >> open [

	^ self new open
]

{ #category : 'accessing' }
CTIConfigurationPresenter >> basicNewCheck [

	^ basicNewCheck
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> collectSeeds [

	| seeds |
	seeds := OrderedCollection new.
	scopeAllRadio state ifTrue: [ Smalltalk allClasses do: [ :c | c selectors do: [ :s | seeds add: c -> s ] ] ].
	scopePackageRadio state ifTrue: [
			| pkgName |
			pkgName := packageList selectedItem.
			pkgName ifNotNil: [
					(Smalltalk allClasses select: [ :c |
							 [ c package name = pkgName ]
								 on: Error
								 do: [ :e | false ] ]) do: [ :c | c selectors do: [ :s | seeds add: c -> s ] ] ] ].
	scopeClassRadio state ifTrue: [
			| clsName cls |
			clsName := classList selectedItem.
			clsName ifNotNil: [
					cls := Smalltalk at: clsName asSymbol ifAbsent: [ nil ].
					cls ifNotNil: [ cls selectors do: [ :s | seeds add: cls -> s ] ] ] ].
	^ seeds
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> connectPresenters [

	scopeAllRadio whenActivatedDo: [ self updateEnablement ].
	scopePackageRadio whenActivatedDo: [ self updateEnablement ].
	scopeClassRadio whenActivatedDo: [ self updateEnablement ].
	packageList whenSelectedItemChangedDo: [ :item | self updatePackageClasses ].

	basicNewCheck whenChangedDo: [ self updateDirtyIndicator ].
	blockEvalCheck whenChangedDo: [ self updateDirtyIndicator ].
	arithmeticCheck whenChangedDo: [ self updateDirtyIndicator ].
	singleImplCheck whenChangedDo: [ self updateDirtyIndicator ].

	saveButton action: [ self doSave ].
	cancelButton action: [ self doCancel ].
	defaultButton action: [ self doDefault ].
	runButton action: [ self doRun ]
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> currentConfigFromCheckboxes [

	| cfg |
	cfg := CTIConfig new.
	cfg basicNewHeuristic: basicNewCheck state.
	cfg blockEvaluationHeuristic: blockEvalCheck state.
	cfg arithmeticHeuristic: arithmeticCheck state.
	cfg singleImplementorHeuristic: singleImplCheck state.
	^ cfg
]

{ #category : 'layout' }
CTIConfigurationPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (self newLabel
				   label: 'Analysis scope:';
				   yourself)
		  expand: false;
		  add: scopeAllRadio expand: false;
		  add: scopePackageRadio expand: false;
		  add: packageList expand: false;
		  add: scopeClassRadio expand: false;
		  add: classList expand: false;
		  add: (self newLabel
				   label: 'Heuristics:';
				   yourself)
		  expand: false;
		  add: (self heuristicRowFor: basicNewCheck example: basicNewExample) expand: false;
		  add: (self heuristicRowFor: blockEvalCheck example: blockEvalExample) expand: false;
		  add: (self heuristicRowFor: arithmeticCheck example: arithmeticExample) expand: false;
		  add: (self heuristicRowFor: singleImplCheck example: singleImplExample) expand: false;
		  add: changedLabel expand: false;
		  add: (SpBoxLayout newLeftToRight
				   add: defaultButton expand: false;
				   add: cancelButton expand: false;
				   add: saveButton expand: false;
				   add: runButton expand: false;
				   yourself)
		  expand: false;
		  add: statusLabel expand: false;
		  yourself
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> doCancel [

	self resetCheckboxesToConfig: savedConfig.
	self updateDirtyIndicator.
	statusLabel label: 'Cancelled - form reverted to last saved state.'
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> doDefault [

	self resetCheckboxesToConfig: CTIConfig new.
	self updateDirtyIndicator.
	statusLabel label: 'Form reset to defaults (not saved).'
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> doRun [

	| seeds |
	seeds := self collectSeeds.
	seeds isEmpty ifTrue: [
			statusLabel label: 'Nothing to analyze - pick a scope (and package/class if needed).'.
			^ self ].
	runButton enabled: false.
	runButton label: 'Running...'.
	statusLabel label: 'Analysis running (' , seeds size printString
		, ' methods) - this can take a couple of minutes for the whole image, please wait...'.
	[
		| u inf fileName |
		[
			u := CTIUniverse new.
			u buildFromImage.
			inf := CTIInferer new.
			inf universe: u.
			inf config: savedConfig.
			inf run: seeds.
			fileName := self resultsDirectory / ('cti-' , self scopeLabelForFileName , '-' , self timestampString , '.csv').
			inf printCSVTo: fileName.
			statusLabel label: 'Done. ' , inf methodInfos size printString , ' methods analyzed. CSV: ' , fileName pathString ]
			on: Error
			do: [ :e | statusLabel label: 'Failed: ' , e messageText ].
		runButton enabled: true.
		runButton label: 'Run Analysis' ] fork
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> doSave [

	savedConfig := self currentConfigFromCheckboxes.
	self updateDirtyIndicator.
	statusLabel label: 'Saved.'
]

{ #category : 'layout' }
CTIConfigurationPresenter >> heuristicRowFor: aCheck example: anExample [

	^ SpBoxLayout newLeftToRight
		  add: aCheck expand: false;
		  add: anExample expand: true;
		  yourself
]

{ #category : 'accessing' }
CTIConfigurationPresenter >> initialExtent [

	^ 640 @ 560
]

{ #category : 'initialization' }
CTIConfigurationPresenter >> initializePresenters [

	savedConfig := CTIConfig new.

	scopeAllRadio := self newRadioButton.
	scopePackageRadio := self newRadioButton.
	scopeClassRadio := self newRadioButton.
	scopeAllRadio associatedRadioButtons: {
			scopePackageRadio.
			scopeClassRadio }.
	scopeAllRadio label: 'Whole image'.
	scopePackageRadio label: 'Package'.
	scopeClassRadio label: 'Class in package'.
	scopeAllRadio state: true.

	packageList := self newDropList.
	packageList items: (PackageOrganizer default packages collect: #name) asSortedCollection asOrderedCollection.

	classList := self newDropList.
	classList items: #(  ).

	basicNewCheck := self newCheckBox.
	basicNewCheck label: 'New / basicNew'.
	basicNewExample := self newExampleText: 'Example: Foo new -> Foo'.

	blockEvalCheck := self newCheckBox.
	blockEvalCheck label: 'Block evaluation'.
	blockEvalExample := self newExampleText: 'Example: cond ifTrue: [42] ifFalse: [a string] -> Union(SmallInteger, ByteString)'.

	arithmeticCheck := self newCheckBox.
	arithmeticCheck label: 'Arithmetic'.
	arithmeticExample := self newExampleText: 'Example: x + y -> some Number subclass'.

	singleImplCheck := self newCheckBox.
	singleImplCheck label: 'Single implementor'.
	singleImplExample := self newExampleText:
		                     'Example: min empty, exactly one class understands all sent messages -> that class is taken'.

	self resetCheckboxesToConfig: savedConfig.

	changedLabel := self newLabel.
	changedLabel label: ''.

	saveButton := self newButton.
	saveButton label: 'Save'.
	cancelButton := self newButton.
	cancelButton label: 'Cancel'.
	defaultButton := self newButton.
	defaultButton label: 'Default'.
	runButton := self newButton.
	runButton label: 'Run Analysis'.

	statusLabel := self newLabel.
	statusLabel label: ''.

	self updateEnablement.
	self updateDirtyIndicator
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> isDirty [

	| cur |
	cur := self currentConfigFromCheckboxes.
	^ cur basicNewHeuristic ~= savedConfig basicNewHeuristic or: [
			  cur blockEvaluationHeuristic ~= savedConfig blockEvaluationHeuristic or: [
					  cur arithmeticHeuristic ~= savedConfig arithmeticHeuristic or: [
						  cur singleImplementorHeuristic ~= savedConfig singleImplementorHeuristic ] ] ]
]

{ #category : 'building' }
CTIConfigurationPresenter >> newExampleText: aString [

	| lbl |
	lbl := self newLabel.
	lbl label: aString.
	lbl color: Color gray.
	^ lbl
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> resetCheckboxesToConfig: aConfig [

	basicNewCheck state: aConfig basicNewHeuristic.
	blockEvalCheck state: aConfig blockEvaluationHeuristic.
	arithmeticCheck state: aConfig arithmeticHeuristic.
	singleImplCheck state: aConfig singleImplementorHeuristic
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> resultsDirectory [

	| dir |
	dir := FileLocator imageDirectory / 'constraint-analysis'.
	dir ensureCreateDirectory.
	^ dir
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> scopeLabelForFileName [

	scopeAllRadio state ifTrue: [ ^ 'image' ].
	scopePackageRadio state ifTrue: [ ^ (packageList selectedItem ifNil: [ 'package' ]) asString ].
	scopeClassRadio state ifTrue: [ ^ (classList selectedItem ifNil: [ 'class' ]) asString ].
	^ 'unknown'
]

{ #category : 'accessing' }
CTIConfigurationPresenter >> statusLabel [

	^ statusLabel
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> timestampString [

	| now |
	now := DateAndTime now.
	^ String streamContents: [ :s |
			  s
				  << now year printString;
				  << (now month printPaddedWith: $0 to: 2);
				  << (now dayOfMonth printPaddedWith: $0 to: 2);
				  << '-';
				  << (now hour printPaddedWith: $0 to: 2);
				  << (now minute printPaddedWith: $0 to: 2);
				  << (now second printPaddedWith: $0 to: 2) ]
]

{ #category : 'accessing' }
CTIConfigurationPresenter >> title [

	^ 'CTI — Настройка анализа'
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> updateDirtyIndicator [

	self isDirty
		ifTrue: [ changedLabel label: 'Unsaved changes' ]
		ifFalse: [ changedLabel label: '' ]
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> updateEnablement [

	packageList enabled: (scopePackageRadio state or: [ scopeClassRadio state ]).
	classList enabled: scopeClassRadio state.
	scopeClassRadio state ifTrue: [ self updatePackageClasses ]
]

{ #category : 'protocol' }
CTIConfigurationPresenter >> updatePackageClasses [

	| pkgName pkg |
	pkgName := packageList selectedItem.
	pkgName ifNil: [
			classList items: #(  ).
			^ self ].
	pkg := PackageOrganizer default packageNamed: pkgName ifAbsent: [ nil ].
	pkg ifNil: [
			classList items: #(  ).
			^ self ].
	classList items: (pkg classes collect: #name) asSortedCollection asOrderedCollection
]

{ #category : 'accessing' }
CTIConfigurationPresenter >> windowTitle [

	^ 'CTI — Analysis Configuration'
]
