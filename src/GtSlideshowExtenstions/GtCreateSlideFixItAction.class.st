Class {
	#name : #GtCreateSlideFixItAction,
	#superclass : #GtFixItAction,
	#instVars : [
		'slideshowClass',
		'slideTemplate',
		'slideName'
	],
	#category : #'GtSlideshowExtenstions-Slideshows'
}

{ #category : #visiting }
GtCreateSlideFixItAction class >> defaultSlideTemplates [
	^ ((DemoSlideshow methods select: [ :each | each hasPragmaNamed: #gtSlide ])
		asSet , (#gtSlide gtPragmas & #gtExample gtPragmas) contents) asArray
]

{ #category : #accessing }
GtCreateSlideFixItAction class >> inClass: aClass withName: aSelector withTemplate: aTemplate [
	^ self new
		slideName: aSelector;
		slideshowClass: aClass;
		slideTemplate: aTemplate;
		yourself
]

{ #category : #accessing }
GtCreateSlideFixItAction >> attributePosition [
	^ node stopPosition
]

{ #category : #executing }
GtCreateSlideFixItAction >> compileMethod [
	| methodWithNewName refactoring |
	methodWithNewName := slideTemplate ast
			selector: slideName asString;
			formattedCode.
	refactoring := RBAddMethodRefactoring
			addMethod: methodWithNewName
			toClass: slideshowClass
			inProtocols: {#slides}.
	refactoring execute
]

{ #category : #accessing }
GtCreateSlideFixItAction >> description [
	^ 'Create slide ' , slideName asString , ' from template '
		, slideTemplate printString
]

{ #category : #executing }
GtCreateSlideFixItAction >> executeOn: anEditorElement [
	self compileMethod.
	(anEditorElement respondsTo: #editor)
		ifTrue: [ self clearFixItAttributeInEditor: anEditorElement editor.
			anEditorElement dataSource model requestSave ]
]

{ #category : #accessing }
GtCreateSlideFixItAction >> id [
	<return: #BlElementId>

	^ GtCreateSlideFixItActionElementId
]

{ #category : #accessing }
GtCreateSlideFixItAction >> slideName: aSelector [
slideName := aSelector
]

{ #category : #accessing }
GtCreateSlideFixItAction >> slideTemplate: aTemplate [
	slideTemplate := aTemplate
]

{ #category : #accessing }
GtCreateSlideFixItAction >> slideshowClass: aClass [
	slideshowClass := aClass
]
