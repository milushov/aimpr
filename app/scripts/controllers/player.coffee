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
    $scope.is_playing = no
    $scope.cur_playing = null

    $rootScope.$on 'setFirstTrack', (e, track) ->
      setCurPlaying(track)
      $scope.is_playing = no

    $rootScope.$on 'play', (e, track) ->
      console.info('play')
      $scope.is_playing = yes
      setCurPlaying(track)

    $rootScope.$on 'pause', (e, track) ->
      console.info('pause')
      $scope.is_playing = no
      setCurPlaying(track)

    setCurPlaying = (track) ->
      if !$scope.cur_playing? || $scope.cur_playing.id isnt track.id
        $scope.cur_playing = track
  ]
