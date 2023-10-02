Extension { #name : #GtClassCoderTool }

{ #category : #'*GtSlideshowExtenstions' }
GtClassCoderTool class >> observedClass: aClass [
	^ (aClass inheritsFrom: PrioritySlideshow)
		ifTrue: [ aClass slideCompositeTool ]
		ifFalse: [ self new observedClass: aClass ]
]
