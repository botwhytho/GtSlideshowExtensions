Extension { #name : #Symbol }

{ #category : #'*GtSlideshowExtensions' }
Symbol >> asKeywordMessage [
	^ self isKeyword ifTrue: [ self ] ifFalse: [ self , ':' ]
]
