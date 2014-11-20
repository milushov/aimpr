# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp', [])
  .controller 'trackList', ['$scope', 'API', 'Q', ($scope, API, Q) ->
    API.getTracks().then (tracks) ->
      $scope.tracks = tracks
      $scope.$digest()
      console.log($scope.tracks, 'yoooooooo')
  ]
