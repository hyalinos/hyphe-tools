"
Tests for RTAPackageDistribution: grouping by package name, per-package
totals/counts, the grand total, and both the text report and CSV exports (counts and percentages),
against a small hand-built two-package result set independent of real image state.
"
Class {
	#name : 'RTAPackageDistributionTest',
	#superclass : 'TestCase',
	#category : 'Hyphe-ReturnTypeAST-Analysis-Tests-Tests',
	#package : 'Hyphe-ReturnTypeAST-Analysis-Tests',
	#tag : 'Tests'
}

{ #category : 'fixtures' }
RTAPackageDistributionTest >> sampleResults [
	"Deterministic, hand-built results across two fake packages -- independent of real image state."

	| results |
	results := OrderedCollection new.
	results add: (ARTIMethodResult
			 package: 'PkgA'
			 class: 'X'
			 selector: #a
			 classSide: false
			 type: (HTMClassRef named: #Integer)).
	results add: (ARTIMethodResult
			 package: 'PkgA'
			 class: 'X'
			 selector: #b
			 classSide: false
			 type: HTMSelf new).
	results add: (ARTIMethodResult
			 package: 'PkgA'
			 class: 'X'
			 selector: #c
			 classSide: true
			 type: (HTMClassRef named: #Integer)).
	results add: (ARTIMethodResult
			 package: 'PkgB'
			 class: 'Y'
			 selector: #d
			 classSide: false
			 type: HTMUnknown new).
	^ results
]

{ #category : 'tests' }
RTAPackageDistributionTest >> testCountsCSVHasOneRowPerPackage [

	| pkgDist file lines |
	pkgDist := RTAPackageDistribution onResults: self sampleResults.
	file := FileLocator temp / 'rta-package-counts-test.csv'.
	pkgDist printCountsCSVTo: file.
	[
		lines := file contents lines.
		self assert: lines size equals: 3. "header + PkgA + PkgB"
		self assert: (lines first includesSubstring: 'Package') ] ensure: [
		file ensureDelete ]
]

{ #category : 'tests' }
RTAPackageDistributionTest >> testEachPackageGetsItsOwnDistribution [

	| pkgDist |
	pkgDist := RTAPackageDistribution onResults: self sampleResults.
	self assert: (pkgDist distributionFor: 'PkgA') total equals: 3.
	self
		assert: ((pkgDist distributionFor: 'PkgA') countFor: #ClassRef)
		equals: 2.
	self
		assert: ((pkgDist distributionFor: 'PkgA') countFor: #Self)
		equals: 1.
	self assert: (pkgDist distributionFor: 'PkgB') total equals: 1.
	self
		assert: ((pkgDist distributionFor: 'PkgB') countFor: #Unknown)
		equals: 1
]

{ #category : 'tests' }
RTAPackageDistributionTest >> testGrandTotalIsSumAcrossPackages [

	| pkgDist |
	pkgDist := RTAPackageDistribution onResults: self sampleResults.
	self assert: pkgDist total equals: 4
]

{ #category : 'tests' }
RTAPackageDistributionTest >> testPackageNamesAreSortedAndDeduplicated [

	| pkgDist |
	pkgDist := RTAPackageDistribution onResults: self sampleResults.
	self assert: pkgDist packageNames asArray equals: #( 'PkgA' 'PkgB' )
]

{ #category : 'tests' }
RTAPackageDistributionTest >> testPercentagesCSVReflectsEachPackagesOwnTotal [

	| pkgDist file lines |
	pkgDist := RTAPackageDistribution onResults: self sampleResults.
	file := FileLocator temp / 'rta-package-percentages-test.csv'.
	pkgDist printPercentagesCSVTo: file.
	[
		lines := file contents lines.
		self assert: lines size equals: 3.
		"PkgA: 2 of 3 are ClassRef -> 66.67%"
		self assert: (lines second includesSubstring: '66.67') ] ensure: [
		file ensureDelete ]
]

{ #category : 'tests' }
RTAPackageDistributionTest >> testPrintReportListsEveryPackageAndATotalRow [

	| pkgDist report |
	pkgDist := RTAPackageDistribution onResults: self sampleResults.
	report := pkgDist printReport.
	self assert: (report includesSubstring: 'PkgA').
	self assert: (report includesSubstring: 'PkgB').
	self assert: (report includesSubstring: 'TOTAL')
]
