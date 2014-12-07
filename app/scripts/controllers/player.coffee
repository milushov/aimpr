'use strict'

###*
 # @ngdoc function
 # @name aimprApp.controller:PlayerCtrl
 # @description
 # # PlayerCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'PlayerCtrl',
    ['$scope', '$rootScope', '$interval', 'audio'
    ($scope, $rootScope, $interval, audio) ->
      console.info('PlayerCtrl')
      $scope.cur_time = 0
      $scope.cur_playing = null
      $scope.position = { cur: 0, max: 1000 }

      transform = (val, dir) ->
        if dir is 'time_to_position'
          $scope.cur_time * $scope.position.max / $scope.cur_playing.duration
        else
          $scope.cur_playing.duration * $scope.position.cur / $scope.position.max

      stop_time = $interval ->
        tick()
      , 1000

      tick = ->
        $scope.cur_time = audio.el.currentTime
        $scope.position.cur = transform($scope.cur_time, 'time_to_position')

      $scope.$watch 'position.cur', (val) ->
        audio.el.currentTime = transform(val, 'position_to_time')
        tick()

      play = (track) ->
        audio.play(track.url)

      pause = (track) ->
        audio.pause()

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
