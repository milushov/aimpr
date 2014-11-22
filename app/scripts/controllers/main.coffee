# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp')
  .controller 'trackList', ['$scope', '$routeParams', 'API', 'Q', '$location', ($scope, $routeParams, API, Q, $location) ->
    $scope.stat = {
      audio_count: 0
      improved_count: 0
      bad_count: 0
    }

    init_params = $location.search()
    api_result  = JSON.parse init_params.api_result
    viewer_id   = init_params.viewer_id
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