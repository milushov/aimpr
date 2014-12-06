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
      $scope.is_playing = yes

    $rootScope.$on 'stop', (track) ->
      debugger
      $scope.is_playing = no
  ]
