'use strict'

###*
 # @ngdoc function
 # @name aimprApp.controller:InfoCtrl
 # @description
 # # InfoCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'InfoCtrl',
    ['$scope', 'Stat', 'API', 'Info', 'Ladda'
    ($scope, Stat, API, Info, ladda) ->
      console.info('InfoCtrl')

      $scope.stat = Stat

      improve = ->
        $scope.$emit 'improveList'
        ladda.start()

      # emit to TracksCtrl
      $scope.improveList = ->
        if Info.viewer_id is Info.user_id
          improve()
        else
          $scope.$emit 'showUserTracks', Info.viewer_id, ->
            improve()

      API.getAudioCountAndLyricsIds(Info.viewer_id).then (data) ->
        $scope.stat.all_count.all = data.audio_count
        $scope.stat.without_lyrics_count.all = (data.without_lyrics.filter (el) -> !el).length
        Info.without_lyrics_count = $scope.stat.without_lyrics_count.all
    ]
