'use strict'

###*
 # @ngdoc function
 # @name aimprApp.controller:InfoCtrl
 # @description
 # # InfoCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'InfoCtrl', ['$scope', 'Stat', 'API', 'Info', ($scope, Stat, API, Info) ->
    $scope.audio_count = null
    $scope.without_lyrics_count = null
    #$scope.mode = 'all'
    $scope.mode = 'without_lyrics'

    $scope.improveList = ->
      $scope.$emit('improveList')

    API.getAudioCountAndLyricsIds(Info.viewer_id).then (data) ->
      $scope.audio_count = data.audio_count
      $scope.without_lyrics_count = (data.without_lyrics.filter (el) -> !el).length
  ]
