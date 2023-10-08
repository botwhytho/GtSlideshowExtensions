Class {
	#name : #BaselineOfGtSlideshowExtensions,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtSlideshowExtensions
}

{ #category : #baseline }
BaselineOfGtSlideshowExtensions >> baseline: spec [
	<baseline>
	^ spec
		for: #common
		do: [ spec
				baseline: 'DrawingTool'
				with: [ spec repository: 'github://botwhytho/GToolkitExperiments:master/src' ].
			spec package: 'GtSlideshowExtensions' ]
]
