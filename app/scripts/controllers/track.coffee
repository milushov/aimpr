'use strict'

###*
 # @ngdoc function
 # @name aimprApp.controller:TrackCtrl
 # @description
 # # TrackCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'TrackCtrl', ['$scope', '$routeParams', 'ViewHelpers', '$sessionStorage', ($scope, $routeParams, ViewHelpers, $sessionStorage) ->
    $scope.$storage = $sessionStorage
    tracks          = $scope.$storage.tracks
    track_id        = parseInt $routeParams.trackId
    console.info($routeParams.trackId)
    $scope.track = (tracks.filter (t) -> t.aid == track_id)[0]
    $scope.helpers = ViewHelpers
  ]
