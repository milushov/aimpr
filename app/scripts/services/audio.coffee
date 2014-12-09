###*
 # @ngdoc service
 # @name aimprApp.audio
 # @description
 # # audio
 # Service in the aimprApp.
###

angular.module('aimprApp')
  .factory 'audio', ['$document', ($document) ->
    el = $document[0].createElement('audio')

    el: el
    play: (url) ->
      el.src = url if url
      el.play()
    pause: ->
      el.pause()
    setEndHandler: (callback) ->
      el.onended = callback

  ]
