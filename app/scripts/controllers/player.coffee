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
      stop_time = null

      audio.setEndHandler ->
        $scope.$emit 'getNextTrack', $scope.cur_playing.id

      transform = (val, dir) ->
        if dir is 'time_to_position'
          $scope.cur_time * $scope.position.max / $scope.cur_playing.duration
        else
          $scope.cur_playing.duration * $scope.position.cur / $scope.position.max

      stopTick = ->
        $interval.cancel(stop_time)
        stop_time = null

      tick = ->
        if audio.el.currentTime < $scope.cur_playing.duration
          $scope.cur_time = audio.el.currentTime
        $scope.position.cur = transform($scope.cur_time, 'time_to_position')

      $scope.$watch 'position.cur', (val) ->
        return unless $scope.cur_playing
        audio.el.currentTime = transform(val, 'position_to_time')
        tick()

      play = (track) ->
        if track.id isnt $scope.cur_playing.id
          setCurPlaying(track)
          $scope.position.cur = 0
          # because not enough time to recalculate cur_time from cur position
          $scope.cur_time = 0
          stopTick()

        stop_time = $interval (-> tick()), 1000 unless stop_time
        if $scope.cur_time is 0 then audio.play(track.url) else audio.play()
        tick()

      pause = (track) ->
        stopTick()
        audio.pause()

      $scope.playOrPause = ->
        $scope.cur_playing.is_playing = !$scope.cur_playing.is_playing
        if $scope.cur_playing.is_playing
          play($scope.cur_playing)
        else
          pause($scope.cur_playing)

      $rootScope.$on 'setFirstTrack', (e, track) ->
        setCurPlaying(track)

      $rootScope.$on 'play', (e, track) ->
        play(track)

      $rootScope.$on 'pause', (e, track) ->
        pause(track)

      setCurPlaying = (track) ->
        if !$scope.cur_playing? || $scope.cur_playing.id isnt track.id
          $scope.cur_playing = track
    ]
