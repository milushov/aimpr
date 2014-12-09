###*
 # @ngdoc service
 # @name aimprApp.ladda
 # @description
 # # ladda
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .factory 'Ladda', ['$document', '$rootScope', ($document, $rootScope) ->
    l = null

    $rootScope.$on 'ladda-init', ->
      l = Ladda.create($document[0].querySelector('.ladda-button'))

    start: -> l.start()
    stop: -> l.stop()
    progress: (a, b) ->
      p = Math.round(a/b*100)/100
      l.setProgress(p)
  ]
