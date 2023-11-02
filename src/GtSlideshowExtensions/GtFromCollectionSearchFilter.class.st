Class {
	#name : #GtFromCollectionSearchFilter,
	#superclass : #GtSearchFilter,
	#instVars : [
		'collection'
	],
	#category : #GtSlideshowExtensions
}

{ #category : #initialization }
GtFromCollectionSearchFilter class >> from: aCollection [
	^ self new collection: aCollection
]

{ #category : #accessing }
GtFromCollectionSearchFilter >> collection [
	^ collection
]

{ #category : #accessing }
GtFromCollectionSearchFilter >> collection: anObject [
	collection := anObject
]

{ #category : #accessing }
GtFromCollectionSearchFilter >> defaultFilterScope [
	^ self collection asAsyncStream
]

{ #category : #testing }
GtFromCollectionSearchFilter >> matches: anObject [
	^ true
]

{ #category : #accessing }
GtFromCollectionSearchFilter >> resultType [
	(self collection first isKindOf: CompiledCode)
		ifTrue: [ ^ GtAsyncSearchMethodGroupStream ].
	^ (self collection first isKindOf: RPackage)
		ifTrue: [ ^ GtAsyncSearchPackageGroupStream ]
		ifFalse: [ ^ GtAsyncSearchClassGroupStream ]
]
