Class {
	#name : #BlChildOrderingPotentiallyChangedEvent,
	#superclass : #BlEvent,
	#instVars : [
		'parent',
		'selector'
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

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent >> selector [
	^ selector
]

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent >> selector: anObject [
	selector := anObject
]
