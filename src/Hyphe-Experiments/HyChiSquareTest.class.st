"
The chi-square test of independence on a table of counts (rows x columns), used to tell whether a result (correct or not, agreement or not) depends on the group. Rows or columns that are all 0 are ignored. statistic is nil when the table has less than two non-empty rows or columns, then there is nothing to test. pValue is the probability of a statistic at least that large if the result did not depend on the group (a small one, below 0.05 for example, says it does depend); cramersV (0 to 1) is the strength of the dependence. The test is not reliable when many expected counts are below 5.
"
Class {
	#name : 'HyChiSquareTest',
	#superclass : 'Object',
	#instVars : [
		'observed',
		'statistic',
		'degreesOfFreedom'
	],
	#category : 'Hyphe-Experiments-Analysis',
	#package : 'Hyphe-Experiments',
	#tag : 'Analysis'
}

{ #category : 'probability' }
HyChiSquareTest class >> lnGamma: x [
	"Natural logarithm of the gamma function, by the Lanczos approximation (x > 0.5)"

	| coefficients y t sum |
	coefficients := #( 0.99999999999980993 676.5203681218851 -1259.1392167224028 771.32342877765313 -176.61502916214059
	                   12.507343278686905 -0.13857109526572012 9.9843695780195716e-6 1.5056327351493116e-7 ).
	y := x - 1.
	t := y + 7.5.
	sum := coefficients first.
	1 to: 8 do: [ :i | sum := sum + ((coefficients at: i + 1) / (y + i)) ].
	^ 0.5 * (2 * Float pi) ln + (y + 0.5 * t ln) - t + sum ln
]

{ #category : 'probability' }
HyChiSquareTest class >> lowerSeriesOf: a at: x [
	"Regularized lower incomplete gamma function P(a, x) by its series, good for x < a + 1"

	| sum term n |
	sum := term := 1.0 / a.
	n := 1.
	[ term abs > (sum abs * 1.0e-14) and: [ n < 1000 ] ] whileTrue: [
			term := term * x / (a + n).
			sum := sum + term.
			n := n + 1 ].
	^ sum * (x negated + (a * x ln) - (self lnGamma: a)) exp
]

{ #category : 'instance creation' }
HyChiSquareTest class >> on: aTableOfCounts [
	"Create the test for a table: an array of rows, each an array of counts"

	^ self new
		  setTable: aTableOfCounts;
		  yourself
]

{ #category : 'probability' }
HyChiSquareTest class >> upperFractionOf: a at: x [
	"Regularized upper incomplete gamma function Q(a, x) by its continued fraction (modified Lentz), good for x >= a + 1"

	| tiny b c d h i delta an |
	tiny := 1.0e-300.
	b := x + 1 - a.
	c := 1.0 / tiny.
	d := 1.0 / b.
	h := d.
	i := 1.
	[ i < 1000 ] whileTrue: [
			an := i negated * (i - a).
			b := b + 2.
			d := an * d + b.
			d abs < tiny ifTrue: [ d := tiny ].
			c := b + (an / c).
			c abs < tiny ifTrue: [ c := tiny ].
			d := 1.0 / d.
			delta := d * c.
			h := h * delta.
			(delta - 1.0) abs < 1.0e-14
				ifTrue: [ i := 1000 ]
				ifFalse: [ i := i + 1 ] ].
	^ h * (x negated + (a * x ln) - (self lnGamma: a)) exp
]

{ #category : 'probability' }
HyChiSquareTest class >> upperTailOf: aStatistic degreesOfFreedom: aNumber [
	"Answer P(X >= aStatistic) for a chi-square variable X with that many degrees of freedom: the regularized upper incomplete gamma function Q(df / 2, statistic / 2)"

	| a x |
	a := aNumber / 2.0.
	x := aStatistic / 2.0.
	x <= 0 ifTrue: [ ^ 1.0 ].
	^ x < (a + 1)
		  ifTrue: [ 1.0 - (self lowerSeriesOf: a at: x) ]
		  ifFalse: [ self upperFractionOf: a at: x ]
]

{ #category : 'accessing' }
HyChiSquareTest >> cramersV [
	"Answer the strength of the dependence, between 0 (none) and 1 (total), nil if the table cannot be tested"

	^ statistic ifNotNil: [ (statistic / (self total * ((observed size min: observed first size) - 1))) sqrt ]
]

{ #category : 'accessing' }
HyChiSquareTest >> degreesOfFreedom [
	"Answer the degrees of freedom (rows - 1) * (columns - 1), nil if the table cannot be tested"

	^ degreesOfFreedom
]

{ #category : 'accessing' }
HyChiSquareTest >> isSignificantAt: aLevel [
	"Answer true if the p-value is below the level (0.05 for example); false if the table cannot be tested"

	^ self pValue ifNil: [ false ] ifNotNil: [ :p | p < aLevel ]
]

{ #category : 'accessing' }
HyChiSquareTest >> observed [
	"Answer the table without its empty rows and columns"

	^ observed
]

{ #category : 'accessing' }
HyChiSquareTest >> pValue [
	"Answer the probability of a statistic at least this large when the result does not depend on the group, nil if the table cannot be tested"

	^ statistic ifNotNil: [ self class upperTailOf: statistic degreesOfFreedom: degreesOfFreedom ]
]

{ #category : 'initialization' }
HyChiSquareTest >> setTable: aTableOfCounts [
	"Remove the empty rows and columns and compute the statistic"

	| rows columns total |
	rows := aTableOfCounts reject: [ :row | row sum = 0 ].
	columns := (1 to: (aTableOfCounts isEmpty
			             ifTrue: [ 0 ]
			             ifFalse: [ aTableOfCounts first size ])) select: [ :index | (aTableOfCounts sum: [ :row | row at: index ]) > 0 ].
	observed := rows collect: [ :row | columns collect: [ :index | row at: index ] ].
	(observed size < 2 or: [ columns size < 2 ]) ifTrue: [ ^ self ].
	total := observed sum: [ :row | row sum ].
	degreesOfFreedom := observed size - 1 * (columns size - 1).
	statistic := 0.
	observed withIndexDo: [ :row :rowIndex |
			row withIndexDo: [ :count :columnIndex |
					| expected |
					expected := row sum * (observed sum: [ :each | each at: columnIndex ]) / total.
					statistic := statistic + ((count - expected) squared / expected) ] ].
	statistic := statistic asFloat
]

{ #category : 'accessing' }
HyChiSquareTest >> statistic [
	"Answer the chi-square statistic, nil if the table cannot be tested"

	^ statistic
]

{ #category : 'accessing' }
HyChiSquareTest >> total [
	"Answer the sum of all the counts"

	^ observed sum: [ :row | row sum ]
]
