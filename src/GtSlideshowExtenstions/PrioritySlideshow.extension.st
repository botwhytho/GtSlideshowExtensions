Extension { #name : #PrioritySlideshow }

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> compileStarterMethods [
	self methods
		detect: [ :aMethod | aMethod selector = #slidePriorities ]
		ifNone: [ | emptyMethod |
			emptyMethod := (PrioritySlideshow >> #slidePriorities) ast.
			self compile: (DemoSlideshow >> #titleSlideFor:) ast formattedCode.
			emptyMethod statements last children first
				contents: {RBLiteralValueNode value: #titleSlideFor:}.
			self compile: emptyMethod formattedCode ]
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> createNewSlideFromTemplate [
	self flag: 'TODO: Currently Static. Refactor into bringing up menu with templates, empty or clone current'.
	^ DemoSlideshow >> #titleSlideFor:
]

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
		slideViewModel: (GtPresenterSlideViewModel new slide: slide)
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> generateSlide: aSelector fromSlideshow: aSlideshow [
	^ (aSlideshow perform: aSelector with: GtLiveSlide new) asElement
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> generateSlideAndCoder: aSelector fromSlideshow: aSlideshow [
	| element |
	element := BrVerticalPane new.
	element
		constraintsDo: [ :c | 
			c vertical matchParent.
			c horizontal matchParent ];
		flag: 'TODO: Start with focus dynamically calculated with slide in first postion of array in `slidePriorities` method.';
		addChild: (self generateSlide: aSelector fromSlideshow: aSlideshow);
		addChild: (self slideCoderElement: self >> aSelector);
		when: BlSlideDefinitionChanged
			do: [ :anEvent | 
				anEvent consumed: true.
				element
					replaceChild: (element childAt: 1)
					with: (self generateSlide: aSelector fromSlideshow: aSlideshow) ].
	^ element
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> getSlideSelectors [
	^ (self >> #slidePriorities) ast statements last children first contents
		collect: #value
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> gtCreateSlidesFor: aView [
	"true = false ifFalse: [ ^ aView empty ]."

	<gtClassView>
	self = PrioritySlideshow ifTrue: [ ^ aView empty ].
	self compileStarterMethods.
	^ aView explicit
		title: 'Create Slides';
		tooltip: 'Create, modify & reorder slides.';
		priority: 0;
		stencil: [ | aSlideshow pane sidebar slides |
			aSlideshow := self new.
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
				do: [ :anEvent | 
					| slideCollection |
					anEvent consumed: true.
					slideCollection := sidebar children
							collect: [ :each | each children first ].
					self recompileMethodIfOrderChanged: slideCollection ].
			slides := self getSlideSelectors collect: [ :each | self >> each ].
			slides
				do: [ :aSlideMethod | 
					sidebar
						addChild: (self slidePreviewAndControlsElement: aSlideMethod withSlideshow: aSlideshow) ].
			pane
				addChild: (sidebar asScrollableElement
						constraintsDo: [ :c | 
							c horizontal fitContent.
							c vertical matchParent ]).
			pane
				addChild: (self generateSlideAndCoder: #titleSlideFor: fromSlideshow: aSlideshow).
			pane ]
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
					element := (self
							generatePreviewElement: aSlideMethod
							withSlideshowInstance: slideshow)
							addEventHandler: GTSlideReorderingHandler new.
					container addChild: element ].
			container
				when: BlChildOrderingPotentiallyChangedEvent
				do: [ :anEvent | 
					anEvent consumed: true.
					self recompileMethodIfOrderChanged: container children ].
			container asScrollableElement ]
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> gtSpotterActDefaultFrom: aSpotterElement [
	^ (GtPager
		openWrappedOn: self slideCompositeTool asElement
		title: self printString
		from: aSpotterElement) maximized
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
PrioritySlideshow class >> recompileMethodIfOrderChanged: aBlElementCollection [
	| currentOrder guiOrder |
	currentOrder := self getSlideSelectors.
	guiOrder := aBlElementCollection collect: [ :each | each id identifier ].
	currentOrder asArray = guiOrder asArray
		ifFalse: [ self recompileMethod: guiOrder ]
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> slideCoderElement: aMethod [
	| aModel aViewModel anElement |
	aModel := GtPharoMethodCoder forMethod: aMethod.
	aViewModel := aModel asCoderViewModel.
	anElement := GtExpandableMethodCoderElement new
			coderViewModel: aViewModel;
			collapse.
	aModel
		when: GtCoderMethodModified
		do: [ anElement fireEvent: (BlSlideDefinitionChanged new viewModel: aViewModel) ].
	anElement
		background: Color white;
		margin: (BlInsets
				top: 3
				right: 10
				bottom: 10
				left: 10);
		addAptitude: BrShadowAptitude new + BrGlamorousWithVerticalResizerAptitude new beBottom.
	^ anElement
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> slideCompositeTool [
	^ GtPhlowCompositeTool new
		addTool: (GtPhlowValuableTool new
				name: 'Slide Editor';
				valuable: (MessageSend
						receiver: self
						selector: #gtCreateSlidesFor:
						argument: GtPhlowProtoView new));
		addTool: (GtClassCoderTool new observedClass: self);
		yourself
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> slideControlElements: aSlideshow [
	^ BrVerticalPane new
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical fitContent ];
		alignCenter;
		addChildren: {BrButton new
					beSmallSize;
					aptitude: BrGlamorousButtonWithIconAptitude;
					icon: (BrGlamorousVectorIcons upwards asElement background: Color lightGray);
					label: 'Add slide above';
					action: [ :aBrButton :aBrButtonModel :anEvent | 
						aBrButton parent parent parent
							addChild: (BrHorizontalPane new
									fitContent;
									alignCenter;
									addChildren: {PrioritySlideshow
												generatePreviewElement: self createNewSlideFromTemplate
												withSlideshowInstance: aSlideshow.
											self slideControlElements: aSlideshow})
							before: aBrButton parent parent.
						aBrButton fireEvent: BlChildOrderingPotentiallyChangedEvent new ].
				BrGlamorousVectorIcons add asElement background: Color lightGray.
				BrButton new
					beSmallSize;
					aptitude: BrGlamorousButtonWithIconAptitude;
					icon: (BrGlamorousVectorIcons downwards asElement background: Color lightGray);
					label: 'Add slide below';
					action: [ :aBrButton :aBrButtonModel :anEvent | 
						aBrButton parent parent parent
							addChild: (BrHorizontalPane new
									fitContent;
									alignCenter;
									addChildren: {PrioritySlideshow
												generatePreviewElement: self createNewSlideFromTemplate
												withSlideshowInstance: aSlideshow.
											self slideControlElements: aSlideshow})
							after: aBrButton parent parent.
						aBrButton fireEvent: BlChildOrderingPotentiallyChangedEvent new ]}
]

{ #category : #'*GtSlideshowExtenstions' }
PrioritySlideshow class >> slidePreviewAndControlsElement: aSlideMethod withSlideshow: aSlideshow [
	^ BrHorizontalPane new
		background: Color white;
		fitContent;
		alignCenter;
		addChildren: {self generatePreviewElement: aSlideMethod withSlideshowInstance: aSlideshow.
				self slideControlElements: aSlideshow};
		addEventHandler: GTSlideReorderingHandler new
]
