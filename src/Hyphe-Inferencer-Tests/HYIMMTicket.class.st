"
Merge Rule Matrix fixture: an issue-tracker-flavored class whose method names deliberately hit ARTH's real trusted name patterns (is-/has-/wants- prefixes, title/key/priority/default*Name), each body written to give ARTI and CTI a specific, sometimes agreeing and sometimes disagreeing, real answer -- feeds HYIMMTest.
"
Class {
	#name : 'HYIMMTicket',
	#superclass : 'Object',
	#instVars : [
		'title',
		'priorityValue',
		'urgent'
	],
	#category : 'Hyphe-Inferencer-Tests',
	#package : 'Hyphe-Inferencer-Tests'
}

{ #category : 'accessing' }
HYIMMTicket >> checkPreferences [
	"Infinitely self-recursive on purpose -- makes doubly sure neither ARTI nor CTI can pin anything down, isolating wantsNotification's Guessed-alone answer."

	^ self checkPreferences
]

{ #category : 'accessing' }
HYIMMTicket >> computeUrgencyScore [
	"Real but ambiguous arithmetic (3+4) -- CTI can't narrow it past a wide Number-family Union, unlike a bare literal."

	^ 3 + 4
]

{ #category : 'accessing' }
HYIMMTicket >> defaultStatusName [
	"Matches ARTH's trusted default[A-Z].*Name regex -- a plain string literal, everyone (ARTI/ARTH/CTI) agrees."

	^ 'open'
]

{ #category : 'accessing' }
HYIMMTicket >> delegate [
	"Infinitely self-recursive on purpose -- gives neither ARTI nor CTI anything to say, isolating reconcileState's pure-Unknown answer."

	^ self delegate
]

{ #category : 'accessing' }
HYIMMTicket >> internalNumericId [
	"A bare literal (42) CTI can resolve exactly -- feeds key's guess-vs-observation disagreement case."

	^ 42
]

{ #category : 'accessing' }
HYIMMTicket >> isArchived [
	"Deliberately mis-named: the is- prefix makes ARTH confidently guess Boolean, but the real body returns a String -- a realistic naming-lint smell, and the 'wrong guess is ignored outright' merge case."

	^ 'not actually a boolean'
]

{ #category : 'accessing' }
HYIMMTicket >> key [
	"Named for a String (an exact trusted ARTH pattern) but built like an Integer -- the flagship guess-vs-observation-disagree case."

	^ self internalNumericId
]

{ #category : 'accessing' }
HYIMMTicket >> priority [
	"Exact trusted ARTH pattern (-> Number); computeUrgencyScore's arithmetic keeps CTI from confirming it cleanly, landing in the irreducible 2-entry case instead."

	^ self computeUrgencyScore
]

{ #category : 'accessing' }
HYIMMTicket >> reconcileState [
	"A name matching no ARTH pattern, a body no static tool can classify -- the pure-Unknown control case."

	^ self delegate reconcile
]

{ #category : 'accessing' }
HYIMMTicket >> title [
	"Exact trusted ARTH pattern (-> String); a plain literal everyone agrees on -- the merge matrix's baseline 'everyone agrees' case."

	^ 'untitled ticket'
]

{ #category : 'accessing' }
HYIMMTicket >> wantsNotification [
	"Trusted wants- prefix (-> Boolean); the body gives neither ARTI nor CTI anything to say -- isolates a bare Guessed answer."

	^ self checkPreferences
]
