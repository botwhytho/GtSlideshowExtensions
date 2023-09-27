Class {
	#name : #BaselineOfGtSlideshowExtenstions,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtSlideshowExtenstions
}

{ #category : #baseline }
BaselineOfGtSlideshowExtenstions >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'GtSlideshowExtenstions'
		]
]
