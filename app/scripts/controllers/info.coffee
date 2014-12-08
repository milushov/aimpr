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
    ['$scope', 'Stat', 'API', 'Info'
    ($scope, Stat, API, Info) ->

      $scope.stat = Stat

      $scope.improveList = ->
        $scope.$emit('improveList')

      API.getAudioCountAndLyricsIds(Info.viewer_id).then (data) ->
        $scope.stat.all_count.all = data.audio_count
        $scope.stat.without_lyrics_count.all = (data.without_lyrics.filter (el) -> !el).length
    ]
