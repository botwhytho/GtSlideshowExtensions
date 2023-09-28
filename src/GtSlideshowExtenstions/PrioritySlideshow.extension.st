Extension { #name : #PrioritySlideshow }

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> generatePreviewElement: aSlideMethod withSlideshowInstance: aSlideshow [
	| slide |
	slide := GtPresenterSlide new
			stencil: (aSlideshow perform: aSlideMethod selector with: GtLiveSlide new).
	^ GtPresenterSlidePreviewElement new
		id: aSlideMethod selector;
		exact: 384 @ 216;
		aptitude: BrShadowAptitude new;
		margin: (BlInsets all: 6);
		background: Color white;
		slideViewModel: (GtPresenterSlideViewModel new slide: slide);
		addEventHandler: GTSlideReorderingHandler new
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> getSlideSelectors [
	^ (self >> #slidePriorities) ast statements last children first contents
		collect: #value
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> gtReorderSlidesFor: aView [
	<gtClassView>
	| lastStatement |
	lastStatement := (self allMethods
			detect: [ :each | each selector = #slidePriorities ]) ast statements last.
	self
		flag: 'TODO: Better logic for when to hide vs show? Don''t show if no slides are in method or hard to parse.'.
	(lastStatement isReturn
		and: [ ({RBLiteralArrayNode.
				RBArrayNode} includes: lastStatement children first class)
				and: [ lastStatement children first contents isEmpty not ] ])
		ifFalse: [ ^ aView empty ].
	^ aView explicit
		title: 'Reorder Slides';
		tooltip: 'Visually reorder slides. Changes automatically save to the `slidePriorities` method.';
		priority: 10;
		stencil: [ | container slides slideshow |
			container := BlElement new
					layout: BlFlowLayout new;
					constraintsDo: [ :c | 
						c vertical matchParent.
						c horizontal matchParent ].
			slides := self getSlideSelectors collect: [ :each | self >> each ].
			slideshow := self new.
			slides
				do: [ :aSlideMethod | 
					| element |
					element := self
							generatePreviewElement: aSlideMethod
							withSlideshowInstance: slideshow.
					container addChild: element ].
			container
				when: BlChildOrderingPotentiallyChangedEvent
				do: [ :anEvent | self recompileMethodIfOrderChanged: anEvent ].
			container ]
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> recompileMethod: guiOrder [
	| method |
	method := self >> #slidePriorities.
	method ast statements last children first
		contents: (guiOrder collect: [ :aSymbol | RBLiteralValueNode value: aSymbol ]).
	self compile: method ast formattedCode
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> recompileMethodIfOrderChanged: anEvent [
	| currentOrder guiOrder |
	currentOrder := self getSlideSelectors collect: #value.
	guiOrder := anEvent parent children collect: [ :each | each id identifier ].
	currentOrder asArray = guiOrder asArray
		ifFalse: [ self recompileMethod: guiOrder ]
]
