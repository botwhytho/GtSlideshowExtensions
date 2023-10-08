Extension { #name : #Symbol }

{ #category : #'*GtSlideshowExtenstions' }
Symbol >> asKeywordMessage [
	^ self isKeyword ifTrue: [ self ] ifFalse: [ self , ':' ]
]
