Extension { #name : #PrioritySlideshow }

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> addSlide: aSlideshow inDirection: aDirection [
	| aButton anIcon |
	anIcon := [ | aVectorIcon |
		aVectorIcon := (BrGlamorousVectorIcons
				perform: (aDirection = 'before' ifTrue: [ #upwards ] ifFalse: [ #downwards ]))
				asElement.
		aVectorIcon background: Color lightGray ].
	aButton := BrButton new id: #add , aDirection capitalized.
	^ aButton
		beSmallSize;
		aptitude: BrGlamorousButtonWithIconAptitude
				+ (self
						slideTemplateDropdownAptitude: {anIcon value.
								aButton.
								aDirection});
		icon: anIcon value;
		label: 'Add slide ' , aDirection
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> compileStarterMethods [
	self methods
		detect: [ :aMethod | aMethod selector = #slidePriorities ]
		ifNone: [ | emptyMethod |
			self >> (self compile: (DemoSlideshow >> #titleSlideFor:) ast formattedCode)
				protocol: 'slides'.
			emptyMethod := (PrioritySlideshow >> #slidePriorities) ast
					copyInContext: Dictionary new.
			emptyMethod statements last children first
				contents: {RBLiteralValueNode value: #titleSlideFor:}.
			self >> (self compile: emptyMethod formattedCode) protocol: 'slides' ]
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> defaultFixItActions [
	^ GtCreateSlideFixItAction defaultSlideTemplates
		collect: [ :each | 
			(GtCreateSlideFixItAction
				inClass: self
				withName: each selector
				withTemplate: each) node: (RBLiteralNode value: each selector) ]
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> generatePreviewElement: aSlideMethod withSlideshowInstance: aSlideshow [
	| element slide |
	slide := GtPresenterSlide new
			stencil: (aSlideshow perform: aSlideMethod selector with: GtLiveSlide new).
	element := GtPresenterSlidePreviewElement new.
	element
		id: aSlideMethod selector;
		exact: 384 @ 216;
		aptitude: BrShadowAptitude new;
		margin: (BlInsets all: 6);
		background: Color white;
		slideViewModel: (GtPresenterSlideViewModel new slide: slide).
	self
		flag: 'TODO: Below logic is because handling the click event is only relevant in one of the views, while this code is being shared by two views. Fix?'.
	thisContext sender method selector = #gtReorderSlidesFor:
		ifFalse: [ element
				when: BlClickEvent
				do: [ :anEvent | 
					| pane |
					anEvent consumed: true.
					pane := element parent parent parent parent.
					pane
						replaceChild: (pane childAt: 2)
						with: (self generateSlideAndCoder: element id identifier fromSlideshow: aSlideshow) ] ].
	^ element
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> generateSlide: aSelector fromSlideshow: aSlideshow [
	^ (aSlideshow perform: aSelector with: GtLiveSlide new) asElement
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> generateSlideAndCoder: aSelector fromSlideshow: aSlideshow [
	^ BrVerticalPane new
		id: #slideAndCoder;
		constraintsDo: [ :c | 
			c vertical matchParent.
			c horizontal matchParent ];
		addChild: (self generateSlide: aSelector fromSlideshow: aSlideshow);
		addChild: (self slideCoderElement: self >> aSelector);
		when: BlSlideDefinitionChanged
			do: [ :anEvent | 
				| element |
				element := anEvent currentTarget.
				element
					enqueueTask: [ | previewElements |
						previewElements := (element space root childNamed: #slidePreviews)
								children
								select: [ :each | each children second id identifier = aSelector ].
						element
							replaceChild: (element childAt: 1)
							with: (self generateSlide: aSelector fromSlideshow: aSlideshow).
						previewElements
							do: [ :aPreviewElement | 
								aPreviewElement parent
									replaceChild: (aPreviewElement parent
											childAt: (aPreviewElement parent children indexOf: aPreviewElement))
									with: (self
											slidePreviewAndControlsElement: self >> aSelector
											withSlideshow: aSlideshow) ] ] asBlTask ]
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> getSlideSelectors [
	^ (self >> #slidePriorities) ast statements last children first contents
		collect: #value
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> gtCreateSlidesFor: aView [
	<gtView>
	<gtClassView>
	self = PrioritySlideshow ifTrue: [ ^ aView empty ].
	self
		flag: 'TODO: the below is probably not necessary. Added when I saw issues with method compilation, but then realized some refactorings weren''t really running because they would fail if overriding a super method so switched back to `self compile: aMethodSourceCode`.'.
	(MessageSend receiver: self selector: #compileStarterMethods) asAsyncFuture
		await.
	^ aView explicit
		title: 'Create Slides';
		tooltip: 'Create, modify & reorder slides.';
		priority: 0;
		stencil: [ | aBrFrame aSlideshow button pane sidebar slides |
			aSlideshow := self new.
			aBrFrame := BrFrame new
					constraintsDo: [ :c | 
						c vertical matchParent.
						c horizontal matchParent ].
			button := BrButton new
					zIndex: 1000;
					aptitude: BrGlamorousButtonWithIconAptitude;
					margin: (BlInsets all: 20);
					constraintsDo: [ :c | 
						c frame horizontal alignRight.
						c frame vertical alignTop ];
					label: 'Play slideshow in new window';
					icon: BrGlamorousVectorIcons play;
					action: [ :aButton | GtPresenterSlideShow openInSpace: self ].
			pane := BrHorizontalPane new
					constraintsDo: [ :c | 
						c vertical matchParent.
						c horizontal matchParent ].
			sidebar := BrVerticalPane new
					id: #slidePreviews;
					background: Color white;
					margin: (BlInsets all: 10);
					addAptitude: BrShadowAptitude new;
					fitContent.
			sidebar
				when: BlChildOrderingPotentiallyChangedEvent
				do: [ :anEvent | 
					| slideCollection |
					anEvent consumed: true.
					slideCollection := sidebar children
							collect: [ :each | 
								each children first text: (each parent childIndexOf: each).
								each children second ].
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
				addChild: (self
						generateSlideAndCoder: self getSlideSelectors first
						fromSlideshow: aSlideshow).
			aBrFrame
				addChildren: {pane.
						button} ]
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> gtReorderSlidesFor: aView [
	<gtView>
	<gtClassView>
	| lastStatement |
	lastStatement := (self allMethods
			detect: [ :each | each selector = #slidePriorities ]) ast statements last.
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

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> gtSpotterActDefaultFrom: aSpotterElement [
	^ self = PrioritySlideshow
		ifTrue: [ super gtSpotterActDefaultFrom: aSpotterElement ]
		ifFalse: [ (GtPager
				openWrappedOn: self slideCompositeTool asElement
				title: self printString
				from: aSpotterElement) maximized ]
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow >> priorityFor: aSlideMethodSelector [
	^ self slidePriorities indexOf: aSlideMethodSelector ifAbsent: [ 0 ]
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> recompileMethod: guiOrder [
	| method |
	method := self >> #slidePriorities.
	method ast statements last children first
		contents: (guiOrder collect: [ :aSymbol | RBLiteralValueNode value: aSymbol ]).
	self compile: method ast formattedCode
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> recompileMethodIfOrderChanged: aBlElementCollection [
	| currentOrder guiOrder |
	currentOrder := self getSlideSelectors.
	guiOrder := aBlElementCollection collect: [ :each | each id identifier ].
	currentOrder asArray = guiOrder asArray
		ifFalse: [ self recompileMethod: guiOrder ]
]

{ #category : #'*GtSlideshowExtensions' }
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

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> slideCompositeTool [
	^ GtPhlowCompositeTool new
		addTool: (GtPhlowExplicitTool new
				name: 'Slide Editor';
				stencil: [ BrFrame new
						matchParent;
						addChild: (self gtCreateSlidesFor: GtPhlowView empty) asElement ]);
		addTool: (GtClassCoderTool new observedClass: self);
		yourself
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> slideControlElements: aSlideshow [
	| pane |
	pane := BrVerticalPane new.
	^ pane
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical fitContent ];
		alignCenter;
		addChildren: {self addSlide: aSlideshow inDirection: 'before'.
				BrGlamorousVectorIcons add asElement background: Color lightGray.
				self addSlide: aSlideshow inDirection: 'after'};
		when: BlChildOrderingPotentiallyChangedEvent
			do: [ :anEvent | 
				anEvent consumed: false.
				pane parent parent
					perform: #addChild: , anEvent order asSymbol asKeywordMessage
					withArguments: {self
								slidePreviewAndControlsElement: self >> anEvent selector
								withSlideshow: aSlideshow.
							pane parent} ]
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> slidePreviewAndControlsElement: aSlideMethod withSlideshow: aSlideshow [
	| anElement aLabel |
	anElement := BrHorizontalPane new.
	aLabel := BrLabel new.
	aLabel
		aptitude: BrGlamorousLabelAptitude new glamorousRegularFontAndSize;
		alignCenter;
		enqueueTask: (BlDelayedTaskAction new
				delay: 0 milliSeconds;
				action: [ aLabel text: (anElement parent childIndexOf: anElement) ]).
	^ anElement
		background: Color white;
		fitContent;
		alignCenter;
		addChildren: {aLabel.
				self generatePreviewElement: aSlideMethod withSlideshowInstance: aSlideshow.
				self slideControlElements: aSlideshow};
		addEventHandler: GTSlideReorderingHandler new
]

{ #category : #'*GtSlideshowExtensions' }
PrioritySlideshow class >> slideTemplateDropdownAptitude: anIconAndElement [
	| aValuable |
	aValuable := [ | actions addSlide cancelButton controls miscElement pane selectorName selectorMenu simpleList |
		actions := self defaultFixItActions.
		pane := BrHorizontalPane new matchParent.
		selectorName := BrEditableLabel new
				aptitude: BrGlamorousEditableLabelAptitude new glamorousRegularFontAndSize.

		simpleList := BrSimpleList new
				fitContent;
				itemStencil: [ BrLabel new
						aptitude: BrGlamorousListLabelAptitude + BrGlamorousListItemAptitude;
						padding: (BlInsets all: 5) ];
				itemDataBinder: [ :eachElement :aFixItAction :anIndex | 
					eachElement
						when: BlClickEvent
						do: [ :anEvent | 
							anEvent consumed: true.
							selectorName text: (BlRunRopedText string: aFixItAction slideName).
							pane userData at: #selectedTemplate put: anIndex ].
					eachElement text: aFixItAction description ];
				items: actions.


		controls := BrHorizontalPane new matchParent.
		miscElement := BlElement new.
		addSlide := BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude new;
				label: 'Create Slide';
				margin: (BlInsets all: 2);
				action: [ :aButton | 
					| aFixItAction aSelector |
					aSelector := selectorName text asString asSymbol asKeywordMessage.
					aFixItAction := actions at: (pane userData at: #selectedTemplate).
					aFixItAction slideName: aSelector.
					self methods
						detect: [ :aMethod | aMethod selector = aSelector ]
						ifFound: [ self
								inform: aSelector asString , ' already exists. Added a duplicate of that slide.' ]
						ifNone: [ aFixItAction executeOn: miscElement ].
					anIconAndElement second
						fireEvent: (BlChildOrderingPotentiallyChangedEvent new
								selector: aSelector;
								order: anIconAndElement third).
					aButton fireEvent: BrDropdownHideWish new ].
		cancelButton := BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude new;
				icon: BrGlamorousVectorIcons cancel;
				margin: (BlInsets all: 2);
				action: [ :aButton | aButton fireEvent: BrDropdownHideWish new ].
		selectorMenu := BrVerticalPane new
				alignCenter;
				matchParent;
				addChildren: {selectorName.
						BrHorizontalPane new
							fitContent;
							alignCenter;
							addChildren: {addSlide.
									cancelButton}}.
		pane
			addChildren: {simpleList.
					selectorMenu} ].
	^ BrGlamorousWithDropdownAptitude
		handle: [ BrButton new
				beSmallSize;
				aptitude: BrGlamorousButtonWithIconAptitude;
				icon: anIconAndElement first;
				label: 'Add slide ' , anIconAndElement third ]
		content: [ aValuable value ]
]
