Class {
	#name : #BaselineOfGtSlideshowExtenstions,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtSlideshowExtenstions
}

{ #category : #baseline }
BaselineOfGtSlideshowExtenstions >> baseline: spec [
	<baseline>
	^ spec
		for: #common
		do: [ spec
				baseline: 'DrawingTool'
				with: [ spec repository: 'github://botwhytho/GToolkitExperiments:master/src' ].
			spec package: 'GtSlideshowExtenstions' ]
]
