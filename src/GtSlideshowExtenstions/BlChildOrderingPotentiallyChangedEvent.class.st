Class {
	#name : #BlChildOrderingPotentiallyChangedEvent,
	#superclass : #BlEvent,
	#instVars : [
		'parent',
		'selector',
		'order'
	],
	#category : #'GtSlideshowExtenstions-Drag & Drop'
}

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent class >> parent: aParentElement [
	^ self new parent: aParentElement ; yourself
]

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent >> order [
	^ order
]

{ #category : #accessing }
BlChildOrderingPotentiallyChangedEvent >> order: anObject [
	order := anObject
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
