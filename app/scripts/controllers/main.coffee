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
    '$timeout'
    ($scope, $routeParams, API, Q, $location, ViewHelpers, $sessionStorage, $timeout) ->

      $scope.$storage = $sessionStorage

      $scope.stat = {
        audio_count: 0
        improved_count: 0
        bad_count: 0
      }

      console.info('MainCtrl')
      $scope.helpers = ViewHelpers

      $scope.per_page = 20
      $scope.cur_page = 1
      $scope.is_loading = true

      params = $location.search()
      $scope.$storage.init_params = if params.access_token? then  params
      else $scope.$storage.init_params

      api_result  = JSON.parse $scope.$storage.init_params.api_result
      viewer_id   = $scope.$storage.init_params.viewer_id
      $scope.stat.audio_count = api_result.response.audio_count

      tracks = []
      if !$scope.$storage.tracks? || !!$scope.$storage.tracks.length
        API.getTracks(788157).then (tracks) ->
          tracks = tracks.slice(1)
          console.info(tracks, 'tracks loaded')

          start = ($scope.cur_page - 1) * $scope.per_page
          end = start + $scope.per_page - 1
          rendered_tracks = tracks[start..end]

          for track in tracks
            $scope.stat.bad_count += 1 unless track.lyrics_id # change to filter or map

          $scope.$storage.tracks = tracks
          $scope.tracks = rendered_tracks
          $scope.$digest()
          # http://goo.gl/xxfBVq
          #$timeout (-> $scope.helpers.resizeIFrame()), 100, false
          $scope.is_loading = false


      $scope.improve = ->
        for track in tracks
          q = "#{track.artist} #{track.title}"
          API.searchTrack(q).then (searched_tracks) ->
            console.info(searched_tracks.slice(1))
          return

      $scope.loadMore = ->
        console.info('load more')
        return if $scope.is_loading

        start = ($scope.cur_page - 1) * $scope.per_page
        end = start + $scope.per_page - 1
        rendered_tracks = $scope.$storage.tracks[start..end]

        $scope.tracks = $scope.tracks.concat(rendered_tracks)
        $scope.cur_page += 1

      return
    ]