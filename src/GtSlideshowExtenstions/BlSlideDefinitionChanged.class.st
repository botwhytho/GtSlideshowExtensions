Class {
	#name : #BlSlideDefinitionChanged,
	#superclass : #BlEvent,
	#instVars : [
		'viewModel'
	],
	#category : #'GtSlideshowExtenstions-Slideshows'
}

{ #category : #accessing }
BlSlideDefinitionChanged >> viewModel [
	^ viewModel
]

{ #category : #acccessing }
BlSlideDefinitionChanged >> viewModel: aViewModel [
	viewModel := aViewModel
]
