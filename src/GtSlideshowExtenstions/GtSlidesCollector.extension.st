Extension { #name : #GtSlidesCollector }

{ #category : #'*GtSlideshowExtensions' }
GtSlidesCollector >> collect [
	<return: #Array of: #GtLiveSlide>
	<gtCollector>
	^ (self object class inheritsFrom: PrioritySlideshow)
		ifTrue: [ self prioritySlideshowCollect ]
		ifFalse: [ self defaultCollect ]
]

{ #category : #'*GtSlideshowExtensions' }
GtSlidesCollector >> defaultCollect [
	<return: #Array of: #GtLiveSlide>
	| theViews |
	theViews := self collectPragmas
			collect: [ :eachPragma | 
				| aSlide |
				[ aSlide := thisContext
						object: self object
						perform: eachPragma methodSelector
						withArguments: {GtEmptySlide new}
						inClass: self object class ]
					on: Error
					do: [ :anException | 
						aSlide := GtLiveSlideWithError new
								definingMethod: (self object class >> eachPragma methodSelector) asRingDefinition;
								error: anException ].
				aSlide ].
	self sortByPriority: theViews.
	^ theViews
]

{ #category : #'*GtSlideshowExtensions' }
GtSlidesCollector >> prioritySlideshowCollect [
	<return: #Array of: #GtLiveSlide>
	^ self object slidePriorities
		collect: [ :aSelector | 
			| aSlide |
			[ aSlide := thisContext
					object: self object
					perform: aSelector
					withArguments: {GtEmptySlide new}
					inClass: self object class ]
				on: Error
				do: [ :anException | 
					aSlide := GtLiveSlideWithError new
							definingMethod: (self object class >> aSelector) asRingDefinition;
							error: anException ].
			aSlide ]
]
