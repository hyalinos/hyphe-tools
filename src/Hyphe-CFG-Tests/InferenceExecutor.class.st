"
Main inference entry point. Ececutes with chosen inference tools and merging strategy
"
Class {
	#name : 'InferenceExecutor',
	#superclass : 'Object',
	#instVars : [
		'packages',
		'tools',
		'results',
		'merger',
		'packageFilter',
		'classFilter',
		'selectorFilter'
	],
	#category : 'Hyphe-CFG-Tests',
	#package : 'Hyphe-CFG-Tests'
}

{ #category : 'as yet unclassified' }
InferenceExecutor class >> executeWithPackage: packageName class: className selector: selector tools: selectedTools mergeStrategy: aStrategy [

    | package |

    package := PackageOrganizer default
        packageNamed: packageName
        ifAbsent: [ self error: 'Package not found: ', packageName ].

    ^ self new
        packages: { package };
        classFilter: className;
        selectorFilter: selector;
        tools: selectedTools;
        merger: (HyTypeMerger newWithStrategy: aStrategy tools: selectedTools);
        results: Dictionary new;
        executeFilter.
]

{ #category : 'accessing' }
InferenceExecutor >> classFilter: aString [
    classFilter := aString.


]

{ #category : 'as yet unclassified' }
InferenceExecutor >> executeFilter [

    | repoGroups filteredPackages  |

    filteredPackages := packages ifNil: [ #() ].
    filteredPackages := filteredPackages select: [ :pkg |
        pkg respondsTo: #name
    ].
    packageFilter ifNotNil: [
        filteredPackages := filteredPackages select: [ :pkg |
            pkg name = packageFilter
        ].
    ].
    filteredPackages := filteredPackages select: [ :pkg |
        pkg respondsTo: #definedClasses
    ].
	
   repoGroups := self groupPackagesByRepository: filteredPackages.
  
    repoGroups keysAndValuesDo: [:repoName :repoPackages |
        results at: repoName put:
            (self processRepositoryFilter: repoName packagesFilter: repoPackages)
    ].
	"results inspect."
	"Filtre"
	
    results keysAndValuesDo: [:repoName :merger |

        | items  filtered |

        (merger respondsTo: #results) ifTrue: [

            items := merger results.
				items inspect.
            filtered := items select: [:dict |

   			 | okClass okSelector |

    		  okClass :=
        			classFilter isNil
        				or: [
           			 (dict at: #className ifAbsent: [ nil ]) asString
          			  =
            			classFilter asString
        				].

   				 okSelector :=
        			selectorFilter isNil
        				or: [
            		(dict at: #methodName ifAbsent: [ nil ]) asString
           			 =
            			selectorFilter asString
       			 ].

    				okClass and: [ okSelector ]
				].
           
            results at: repoName put: filtered
        ]
    ].
		 
         ^ results 
]

{ #category : 'as yet unclassified' }
InferenceExecutor >> findRepositoryForPackageFilter: packageName [
	 | package workingCopy |	

    package := PackageOrganizer default packageNamed: packageName ifAbsent: [nil].
    package ifNil: [^ 'system'].
    
    "Try to find Iceberg repository"
    workingCopy := package mcWorkingCopy.
    workingCopy ifNotNil: [
        | repository |
        repository := IceRepository registeredRepositoryIncludingPackage: package.
        repository ifNotNil: [^ repository name]
    ].
    
    "If no git repository found, it's a system package"

   
    ^ 'system'
]

{ #category : 'accessing' }
InferenceExecutor >> packageFilter: aString [
    packageFilter := aString.


]

{ #category : 'as yet unclassified' }
InferenceExecutor >> processRepositoryFilter: repoName packagesFilter: repoPackages [

		| inferenceResults items|

    	inferenceResults := Mycelium mycelium.

    	tools do: [:tool |

   		 | rawResult normalizedPackages |

    		normalizedPackages := repoPackages collect: [:p |
        		(p isKindOf: Package)
            ifTrue: [ p name asSymbol ]
            ifFalse: [ p asSymbol ]
   		 ].

    		rawResult := tool runHypheInference: normalizedPackages.

   		 tool hypheExporter export: rawResult to: inferenceResults.

		].
	

    ^ merger mergeHyTypes: inferenceResults
]

{ #category : 'accessing' }
InferenceExecutor >> selectorFilter: aString [
    selectorFilter := aString.
]
