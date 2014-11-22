'use strict'

###*
 # @ngdoc function
 # @name aimprApp.controller:TrackCtrl
 # @description
 # # TrackCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'TrackCtrl', ['$scope', '$routeParams', 'ViewHelpers', ($scope, $routeParams, ViewHelpers) ->
    console.info($routeParams.trackId)
    $scope.track = artist: 'ololo'
    $scope.helpers = ViewHelpers
  ]
