Class {
	#name : #GTSlideReorderingHandler,
	#superclass : #DTReorderingHandler,
	#category : #'GtSlideshowExtenstions-Drag & Drop'
}

{ #category : #'event handling' }
GTSlideReorderingHandler >> dragEndEvent: anEvent [
	"anEvent consumed: true."
	| draggable |
	draggable := anEvent currentTarget.
	overlay removeChild: draggable.
	parent replaceChild: placeholder with: draggable.
	overlay detach.

	anEvent currentTarget dispatchEvent: BlPullEndEvent new.
	parent dispatchEvent: BlChildOrderingPotentiallyChangedEvent new
]

{ #category : #initialization }
GTSlideReorderingHandler >> initialize [
	super initialize.
	
	allowedOutOfBounds := false.
	direction := Any
]

{ #category : #accessing }
GTSlideReorderingHandler >> inplaceSorting [
	<gtExample>
	| pane |
	pane := BlElement new
		size: 700 @ 600;
		layout: BlFlowLayout new;
		border: (BlBorder paint: Color black);
		padding: (BlInsets all: 5)
		yourself.
	10 timesRepeat: [ |element|
	element := BlElement new
		size: 150 @ 100;
		border: (BlBorder paint: Color black);
		background: Color random;
		margin: (BlInsets all: 5);
		addEventHandler: DTReorderingHandler new;
		yourself.
	pane addChild: element].
	pane when: BlChildOrderingPotentiallyChangedEvent do: [ :anEvent | self inform: 'Ordering may have changed' ].
^pane
]
