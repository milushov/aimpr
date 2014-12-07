'use strict'

###*
 # @ngdoc function
 # @name aimprApp.controller:PlayerCtrl
 # @description
 # # PlayerCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'PlayerCtrl', ['$scope', '$rootScope', ($scope, $rootScope) ->
    console.info('PlayerCtrl')
    $scope.cur_playing = null

    play = (track) ->

    pause = (track) ->

    $scope.playOrPause = ->
      $scope.cur_playing.is_playing = !$scope.cur_playing.is_playing
      if $scope.is_playing
        play($scope.cur_playing)
      else
        stop($scope.cur_playing)

    $rootScope.$on 'setFirstTrack', (e, track) ->
      setCurPlaying(track)

    $rootScope.$on 'play', (e, track) ->
      console.info('play')
      setCurPlaying(track)
      play($scope.cur_playing)

    $rootScope.$on 'pause', (e, track) ->
      console.info('pause')
      setCurPlaying(track)
      pause($scope.cur_playing)

    setCurPlaying = (track) ->
      if !$scope.cur_playing? || $scope.cur_playing.id isnt track.id
        $scope.cur_playing = track
  ]
