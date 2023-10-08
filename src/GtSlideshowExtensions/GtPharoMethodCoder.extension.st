Extension { #name : #GtPharoMethodCoder }

{ #category : #'*GtSlideshowExtensions' }
GtPharoMethodCoder >> slideshowAddOnFor: anAST into: coderAddOns [
	<gtAstCoderAddOns: 10>
	(self behavior inheritsFrom: PrioritySlideshow) ifFalse: [ ^ self ].

	coderAddOns addStyler: GtCoderExpandableSlideshowStyler new
]
