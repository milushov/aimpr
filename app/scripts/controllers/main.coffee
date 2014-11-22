# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp')
  .controller 'MainCtrl', [
    '$scope'
    '$routeParams'
    'API'
    'Q'
    '$location'
    'ViewHelpers'
    '$sessionStorage'
    ($scope, $routeParams, API, Q, $location, ViewHelpers, $sessionStorage) ->

      $scope.$storage = $sessionStorage

      $scope.stat = {
        audio_count: 0
        improved_count: 0
        bad_count: 0
      }

      console.info('MainCtrl')
      $scope.helpers = ViewHelpers

      params = $location.search()
      $scope.$storage.init_params = if params.access_token? then  params
      else $scope.$storage.init_params

      api_result  = JSON.parse $scope.$storage.init_params.api_result
      viewer_id   = $scope.$storage.init_params.viewer_id
      $scope.stat.audio_count = api_result.response.audio_count

      API.getTracks().then (tracks) ->
        # http://binarymuse.github.io/ngInfiniteScroll/demo_basic.html
        #VK.callMethod("resizeWindow", 510, 600);
        $scope.tracks = tracks.slice(1)
        console.log($scope.tracks, 'yoooooooo')

        for track in $scope.tracks
          $scope.stat.bad_count += 1 unless track.lyrics_id

        $scope.$digest()

      $scope.improve = ->
        for track in $scope.tracks
          q = "#{track.artist} #{track.title}"
          API.searchTrack(q).then (searched_tracks) ->
            console.info(searched_tracks.slice(1))
          return

      return
    ]