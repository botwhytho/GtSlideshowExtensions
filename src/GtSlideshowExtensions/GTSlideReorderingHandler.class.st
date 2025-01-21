Class {
	#name : #GTSlideReorderingHandler,
	#superclass : #BlCustomEventHandler,
	#instVars : [
		'originalPosition',
		'dragStartPosition',
		'allowedOutOfBounds',
		'direction',
		'overlay',
		'parent',
		'placeholder'
	],
	#classVars : [
		'Any',
		'Horizontal',
		'Vertical'
	],
	#category : #'GtSlideshowExtensions-Drag & Drop'
}

{ #category : #'class initialization' }
GTSlideReorderingHandler class >> initialize [	
	Any := #any.
	Vertical := #vertical.
	Horizontal := #horizontal
]

{ #category : #'api - pull handler' }
GTSlideReorderingHandler >> allowOutOfBounds [
	"Allow the pulled element to be pulled outside of the parent bounds"
	
	allowedOutOfBounds := true
]

{ #category : #'api - pull handler' }
GTSlideReorderingHandler >> beFree [
	direction := Any
]

{ #category : #'api - pull handler' }
GTSlideReorderingHandler >> beHorizontal [
	direction := Horizontal
]

{ #category : #'api - pull handler' }
GTSlideReorderingHandler >> beVertical [
	direction := Vertical
]

{ #category : #'private - pulling' }
GTSlideReorderingHandler >> computePullDelta: aDragDelta [
	<return: #Number>
	
	direction = Any
		ifTrue: [ ^ aDragDelta ].
		
	direction = Vertical
		ifTrue: [ ^ 0 @ aDragDelta y ].
		
	direction = Horizontal
		ifTrue: [ ^ aDragDelta x @ 0 ].
		
	^ direction
]

{ #category : #'api - pull handler' }
GTSlideReorderingHandler >> disallowOutOfBounds [
	"Do not allow the pulled element to be pulled outside of the parent bounds"
	
	allowedOutOfBounds := false
]

{ #category : #'event handling' }
GTSlideReorderingHandler >> dragEndEvent: anEvent [
	"anEvent consumed: true."
	| draggable |
	draggable := anEvent currentTarget.
	overlay removeChild: draggable.
	parent replaceChild: placeholder with: draggable.
	overlay detach.

	anEvent currentTarget dispatchEvent: BlPullEndEvent new.
	parent dispatchEvent: (BlChildOrderingPotentiallyChangedEvent parent: parent)
]

{ #category : #'event handling' }
GTSlideReorderingHandler >> dragEvent: anEvent [
	| dragPosition dragDelta aNewPosition |
	dragPosition := anEvent currentTarget
		globalPointToParent: anEvent position.
	self movePlaceholderIfOverOtherChild: anEvent.
	dragDelta := dragPosition
		- (dragStartPosition ifNil: [ dragStartPosition := dragPosition ]).
	dragDelta := self computePullDelta: dragDelta.
	aNewPosition := (originalPosition
		ifNil: [ originalPosition := anEvent currentTarget position ])
		+ dragDelta.
	allowedOutOfBounds
		ifFalse: [ | aMaxPosition |
			aMaxPosition := anEvent currentTarget hasParent
				ifTrue: [ anEvent currentTarget parent extent - anEvent currentTarget extent ]
				ifFalse: [ 0 @ 0 ].
			aNewPosition := aNewPosition min: aMaxPosition max: 0 @ 0 ].
	anEvent currentTarget relocate: aNewPosition.
	anEvent consumed: true.
	anEvent currentTarget
		dispatchEvent:
			(BlPullEvent new
				initialPosition: originalPosition;
				oldPosition: dragPosition;
				newPosition: aNewPosition;
				delta: dragDelta)
]

{ #category : #'event handling' }
GTSlideReorderingHandler >> dragStartEvent: anEvent [
	|draggable |
	anEvent consumed: true.
	draggable := anEvent currentTarget.
	parent := draggable parent.
	overlay := BlOverlayElement on: parent.
	parent parent addChild: overlay.

	"drag start position in parent"
	dragStartPosition := draggable globalPointToParent: anEvent position.

	"element position in parent"
	originalPosition := draggable position.
	placeholder := self placeholderFor: draggable.
	parent replaceChild: draggable with: placeholder.
	overlay addChild: draggable.

	anEvent currentTarget dispatchEvent: BlPullStartEvent new
]

{ #category : #'api - accessing' }
GTSlideReorderingHandler >> eventsToHandle [
	^ { BlDragStartEvent . BlDragEvent . BlDragEndEvent }
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
		addEventHandler: GTSlideReorderingHandler new;
		yourself.
	pane addChild: element].
^pane
]

{ #category : #'event handling' }
GTSlideReorderingHandler >> movePlaceholderIfOverOtherChild: anEvent [
	| mouseOverOther |
	mouseOverOther := placeholder.
	parent children
		do: [ :each | 
			(each containsGlobalPoint: anEvent position)
				ifTrue: [ mouseOverOther := each ] ].
	mouseOverOther = placeholder
		ifFalse: [ | index |
			index := parent childIndexOf: mouseOverOther.
			parent removeChild: placeholder.
			parent addChild: placeholder at: index ]
]

{ #category : #'event handling' }
GTSlideReorderingHandler >> placeholderFor: draggable [ 
	^BlElement new
		size: draggable size;
		border: (draggable border copyWithStyle: BlStrokeStyle dashed);
		margin: draggable margin;
		background: (draggable background paint color alpha: 0.2);
		yourself
]
