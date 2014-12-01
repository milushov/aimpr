'use strict'

###*
 # @ngdoc function
 # @name aimprApp.controller:InfoCtrl
 # @description
 # # InfoCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'InfoCtrl', ['$scope', 'Stat', ($scope, Stat) ->
    $scope.stat = Stat
    $scope.improveList = ->
      $scope.$emit('improveList')
  ]
