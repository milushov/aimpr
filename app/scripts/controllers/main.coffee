# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp')
  .controller 'trackList', ['$scope', '$routeParams', 'API', 'Q', '$location', ($scope, $routeParams, API, Q, $location) ->
    api_result = JSON.parse $location.search().api_result
    $scope.audio_count = api_result.response.audio_count
    API.getTracks().then (tracks) ->
      $scope.tracks = tracks
      $scope.$digest()
      console.log($scope.tracks, 'yoooooooo')
  ]
