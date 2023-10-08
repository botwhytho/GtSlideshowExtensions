Extension { #name : #GtClassCoderTool }

{ #category : #'*GtSlideshowExtensions' }
GtClassCoderTool class >> observedClass: aClass [
	^ (aClass inheritsFrom: PrioritySlideshow)
		ifTrue: [ aClass slideCompositeTool ]
		ifFalse: [ self new observedClass: aClass ]
]
