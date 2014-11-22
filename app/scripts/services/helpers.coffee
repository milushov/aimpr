###*
 # @ngdoc service
 # @name aimprApp.helpers
 # @description
 # # helpers
 # Factory in the aimprApp.
###
angular.module('aimprApp')
  .factory 'ViewHelpers', ['$routeParams', ($routeParams) ->

    # Public API here
    {
      isTrackView: ->
        !!$routeParams.trackId
    }
  ]
