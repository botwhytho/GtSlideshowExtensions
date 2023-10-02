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
PrioritySlideshow class >> getCreateSlidesFor: aView [
	"true = false ifFalse: [ ^ aView empty ]."

	<gtClassView>
	self methods
		detect: [ :aMethod | aMethod selector = #slidePriorities ]
		ifNone: [ | emptyMethod |
			emptyMethod := (PrioritySlideshow >> #slidePriorities) ast.
			self compile: (DemoSlideshow >> #titleSlideFor:) ast formattedCode.
			emptyMethod statements last children first
				contents: {RBLiteralValueNode value: #titleSlideFor:}.
			self compile: emptyMethod formattedCode ].
	^ aView explicit
		title: 'Create Slides';
		tooltip: 'Create, modify & reorder slides.';
		priority: 0;
		stencil: [ | aSlideshow coderElement element pane renderSlide sidebar slideTemplate slides |
			coderElement := [ :aMethod | 
				| aModel aViewModel anElement |
				aModel := GtPharoMethodCoder forMethod: aMethod.
				aViewModel := aModel asCoderViewModel.
				anElement := GtExpandableMethodCoderElement new
						coderViewModel: aViewModel;
						collapse.
				aModel
					when: GtCoderMethodModified
					do: [ anElement fireEvent: BlSlideDefinitionChanged new ].
				anElement
					background: Color white;
					margin: (BlInsets
							top: 3
							right: 10
							bottom: 10
							left: 10);
					addAptitude: BrShadowAptitude new + BrGlamorousWithVerticalResizerAptitude new beBottom.
				anElement ].
			slideTemplate := [ :aSlideshow2 :aSelector | (aSlideshow2 perform: aSelector with: GtLiveSlide new) asElement ].
			aSlideshow := self new.
			renderSlide := [ slideTemplate value: aSlideshow value: #titleSlideFor: ].
			element := BrVerticalPane new.
			element
				constraintsDo: [ :c | 
					c vertical matchParent.
					c horizontal matchParent ];
				addChild: renderSlide value;
				addChild: (coderElement value: self >> #titleSlideFor:);
				when: BlSlideDefinitionChanged
					do: [ :anEvent | 
						anEvent consumed: true.
						element replaceChild: (element childAt: 1) with: renderSlide value ].
			element.
			pane := BrHorizontalPane new
					constraintsDo: [ :c | 
						c vertical matchParent.
						c horizontal matchParent ].
			sidebar := BrVerticalPane new
					background: Color white;
					margin: (BlInsets
							top: 10
							right: 10
							bottom: 10
							left: 10);
					addAptitude: BrShadowAptitude new;
					fitContent.
			sidebar
				when: BlChildOrderingPotentiallyChangedEvent
				do: [ :anEvent | self recompileMethodIfOrderChanged: anEvent ].
			slides := self getSlideSelectors collect: [ :each | self >> each ].
			slides
				do: [ :aSlideMethod | 
					| anElement |
					anElement := self
							generatePreviewElement: aSlideMethod
							withSlideshowInstance: aSlideshow.
					sidebar addChild: anElement ].
			pane
				addChild: (sidebar asScrollableElement
						constraintsDo: [ :c | 
							c horizontal fitContent.
							c vertical matchParent ]).
			pane addChild: element.
			pane ]
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
						c vertical fitContent.
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
			container asScrollableElement ]
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
	currentOrder := self getSlideSelectors.
	guiOrder := anEvent parent children collect: [ :each | each id identifier ].
	currentOrder asArray = guiOrder asArray
		ifFalse: [ self recompileMethod: guiOrder ]
]