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

    $rootScope.$on 'play', (track) ->
      console.info('play')
      $scope.is_playing = yes

    $rootScope.$on 'pause', (track) ->
      console.info('pause')
      $scope.is_playing = no
  ]
