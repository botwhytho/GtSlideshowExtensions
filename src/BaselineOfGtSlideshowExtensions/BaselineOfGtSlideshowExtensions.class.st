Class {
	#name : #BaselineOfGtSlideshowExtensions,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtSlideshowExtensions
}

{ #category : #baseline }
BaselineOfGtSlideshowExtensions >> baseline: spec [
	<baseline>
	^ spec for: #common do: [ spec package: 'GtSlideshowExtensions' ]
]
