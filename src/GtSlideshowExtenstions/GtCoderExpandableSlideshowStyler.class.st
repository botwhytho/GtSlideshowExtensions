Class {
	#name : #GtCoderExpandableSlideshowStyler,
	#superclass : #GtGenericPharoStyler,
	#category : #'GtSlideshowExtenstions-Slideshows'
}

{ #category : #visiting }
GtCoderExpandableSlideshowStyler >> calculateTemplates: aStringLiteralNode [
	^ MessageSend
		receiver: self
		selector: #createSlideFromTemplates:
		arguments: {aStringLiteralNode}
]

{ #category : #visiting }
GtCoderExpandableSlideshowStyler >> createSlideFromTemplates: aStringLiteralNode [
	^ GtCreateSlideFixItAction defaultSlideTemplates
		collect: [ :each | 
			(GtCreateSlideFixItAction
				inClass: self coderViewModel behavior
				withName: aStringLiteralNode value value asSymbol
				withTemplate: each) node: aStringLiteralNode ]
]

{ #category : #private }
GtCoderExpandableSlideshowStyler >> isNonEmptyLiteralStringNode: nameNode [
	^ nameNode isLiteral
		and: [ nameNode literalValue isString
			and: [ nameNode literalValue notEmpty ] ]
]

{ #category : #visiting }
GtCoderExpandableSlideshowStyler >> styleSlideMethods: aSymbolLiteralNode [
	| anExpanderAttribute |
	self
		attribute: (GtCompletionStrategyAttribute new
				strategy: (GtSlideshowCompletionStrategy withSlideshowClass: self coderViewModel behavior))
		from: aSymbolLiteralNode value startPosition
		to: aSymbolLiteralNode value stopPosition.

	self coderViewModel behavior methods
		detect: [ :each | each selector = aSymbolLiteralNode value ]
		ifFound: [ :found | 
			anExpanderAttribute := BrGlamorousTriangleExpanderTextAttribute new
					id: GtSourceCoderEmbeddedExpanderToggleId;
					attributesCreatingBlock: [ BrTextAdornmentDynamicAttribute new
							beAppend;
							stencil: [ | aModel aViewModel anElement |
								aModel := GtPharoMethodCoder forMethod: found.
								aViewModel := aModel asCoderViewModel.
								anElement := GtExpandedOnlyCoderElement new coderViewModel: aViewModel.
								anElement
									background: Color white;
									margin: (BlInsets
											top: 3
											right: 10
											bottom: 10
											left: 10);
									addAptitude: BrShadowAptitude new + BrGlamorousWithVerticalResizerAptitude new beBottom.
								anElement ] ] ]
		ifNone: [ anExpanderAttribute := GtFixItAttribute new
					label: 'Slide hasn''t been created';
					description: [ 'Please create the slide from one of the templates below' ];
					placeholderAlignment: #alignMiddle;
					fixItActions: (self calculateTemplates: aSymbolLiteralNode);
					yourself ].


	self
		attribute: anExpanderAttribute
		from: aSymbolLiteralNode value stopPosition
		to: aSymbolLiteralNode value stopPosition
]

{ #category : #visiting }
GtCoderExpandableSlideshowStyler >> visitSymbolLiteral: aStringLiteralNode [
	super visitSymbolLiteral: aStringLiteralNode.

	self coderViewModel selector = #slidePriorities ifFalse: [ ^ self ].
	(self isNonEmptyLiteralStringNode: aStringLiteralNode) ifFalse: [ ^ self ].
	self styleSlideMethods: aStringLiteralNode
]
