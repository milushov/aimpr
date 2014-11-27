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
    'initScroll'
    '$window'
    ($scope, $routeParams, API, Q, $location, ViewHelpers, $sessionStorage, $timeout, initScroll, $window) ->

      $scope.$storage = $sessionStorage

      $scope.stat = {
        audio_count: 0
        improved_count: 0
        bad_count: 0
      }

      console.info('MainCtrl')
      $scope.helpers = ViewHelpers

      $scope.per_page = 20
      $scope.cur_page = 0
      $scope.is_loading = true
      $scope.per_part = 100
      $scope.cur_part = 0

      params = $location.search()
      $scope.$storage.init_params = if params.access_token? then  params
      else $scope.$storage.init_params

      api_result  = JSON.parse $scope.$storage.init_params.api_result
      viewer_id   = $scope.$storage.init_params.viewer_id
      $scope.stat.audio_count = api_result.response.audio_count

      tracks = []
      $scope.$storage.tracks = []
      $scope.tracks = []

      getTracks = () ->
        offset = $scope.per_part * $scope.cur_part

        API.getTracks(788157, offset).then (tracks) ->
          tracks = tracks.slice(1)

          start = ($scope.cur_page) * $scope.per_page
          end = start + $scope.per_page - 1
          rendered_tracks = tracks[start..end]
          $scope.stat.bad_count = (tracks.filter (el) -> !el.lyrics_id?).length

          $scope.$storage.tracks = $scope.$storage.tracks.concat(tracks)
          $scope.tracks = $scope.tracks.concat(rendered_tracks)
          $scope.$apply()

          # http://goo.gl/xxfBVq
          $timeout (-> $scope.helpers.resizeIFrame()), 100, false
          #$scope.$on('$viewContentLoaded', $scope.helpers.resizeIFrame()))
          #$scope.$on('$includeContentLoaded', $scope.helpers.resizeIFrame()))
          $scope.is_loading = false
          $scope.cur_page += 1
          $scope.cur_part += 1


      getTracks() if !$scope.$storage.tracks? || !$scope.$storage.tracks.length

      $scope.improve = ->
        for track in tracks
          q = "#{track.artist} #{track.title}"
          API.searchTrack(q).then (searched_tracks) ->
            console.info(searched_tracks.slice(1))
          return

      loadMore = ->
        return if $scope.is_loading
        console.info('load more')

        $scope.is_loading = true

        start = ($scope.cur_page) * $scope.per_page
        end = start + $scope.per_page - 1
        rendered_tracks = $scope.$storage.tracks[start..end]

        rendered_tracks.forEach (track) -> track.page = $scope.cur_page
        console.info(start, end)

        $scope.tracks = $scope.tracks.concat(rendered_tracks)
        $scope.cur_page += 1
        $scope.$apply()
        $timeout (-> $scope.is_loading = false), 1000, false
        $timeout (-> $scope.helpers.resizeIFrame()), 100, false

        if isAlmostLastPart()
          getTracks()
          console.info('almost last part')

      isAlmostLastPart = ->
        all_tacks_count = $scope.$storage.tracks.length
        last_page = Math.floor(all_tacks_count / $scope.per_page)
        $scope.cur_page is last_page

      initScroll (scroll, height) ->
        loadMore() if ($window.innerHeight - (scroll + height)) < 200

      return
    ]