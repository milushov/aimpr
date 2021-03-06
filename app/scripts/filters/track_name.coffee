###*
 # @ngdoc filter
 # @name aimprApp.filter:trackName
 # @function
 # @description
 # # trackName
 # Filter in the aimprApp.
###
angular.module('aimprApp')
  .filter 'trackName', ['$filter', ($filter) ->
    (track, characters_count = 42, truncate_word = false) ->
      return unless track
      $filter('characters')("#{track.artist} - #{track.title}", characters_count, truncate_word)
  ]
