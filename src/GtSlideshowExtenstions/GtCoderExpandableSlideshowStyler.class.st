Class {
	#name : #GtCoderExpandableSlideshowStyler,
	#superclass : #GtGenericPharoStyler,
	#category : #'GtSlideshowExtenstions-Slideshows'
}

{ #category : #visiting }
GtCoderExpandableSlideshowStyler >> calculateTemplates: aSymbolLiteralNode [
	^ MessageSend
		receiver: self
		selector: #createSlideFromTemplates:
		arguments: {aSymbolLiteralNode}
]

{ #category : #visiting }
GtCoderExpandableSlideshowStyler >> createSlideFromTemplates: aSymbolLiteralNode [
	^ GtCreateSlideFixItAction defaultSlideTemplates
		collect: [ :each | 
			(GtCreateSlideFixItAction
				inClass: self coderViewModel behavior
				withName: aSymbolLiteralNode value value asSymbol
				withTemplate: each) node: aSymbolLiteralNode ]
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
		flag: 'TODO: there seems to be an issue with autocompletion overwriting over 1 more character, only an issue when there is on extra space between the last element in the `slidePriorities` array and the closing parenthesis.'.
	self
		attribute: (GtCompletionStrategyAttribute new
				strategy: (GtSlideshowCompletionStrategy withSlideshowClass: self coderViewModel behavior))
		from: aSymbolLiteralNode value startPosition
		to: aSymbolLiteralNode value stopPosition.

	self coderViewModel behavior methods
		detect: [ :each | each selector = aSymbolLiteralNode asSymbol ]
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
GtCoderExpandableSlideshowStyler >> visitSymbolLiteral: aSymbolLiteralNode [
	super visitSymbolLiteral: aSymbolLiteralNode.

	self coderViewModel selector = #slidePriorities ifFalse: [ ^ self ].
	(self isNonEmptyLiteralStringNode: aSymbolLiteralNode) ifFalse: [ ^ self ].
	self styleSlideMethods: aSymbolLiteralNode
]
