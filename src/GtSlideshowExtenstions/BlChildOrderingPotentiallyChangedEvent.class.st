Class {
	#name : #BlChildOrderingPotentiallyChangedEvent,
	#superclass : #BlEvent,
	#instVars : [
		'parent'
	],
	#category : #'GtSlideshowExtenstions-Drag & Drop'
}

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent class >> parent: aParentElement [
	^ self new parent: aParentElement ; yourself
]

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent >> parent [
	^ parent
]

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent >> parent: aParentElement [
	parent := aParentElement
]
