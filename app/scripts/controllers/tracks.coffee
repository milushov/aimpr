# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp')
  .controller 'TracksCtrl', [
    '$scope', '$routeParams', 'API', 'Q', '$location', 'ViewHelpers', '$sessionStorage', '$timeout', 'initScroll', '$window', 'Stat'
    ($scope, $routeParams, API, Q, $location, ViewHelpers, $sessionStorage, $timeout, initScroll, $window, Stat) ->

      #$scope.stat = Stat

      console.info('MainCtrl')
      $scope.helpers = ViewHelpers

      angular.extend $scope,
        per_page:   30
        cur_page:   1
        is_loading: true
        per_part:   100
        cur_part:   1
        cur_selected_track: null


      params = $location.search()

      #api_result  = JSON.parse params.api_result
      viewer_id   = params.viewer_id
      #$scope.stat.audio_count = api_result.response.audio_count


      renderPage = ->
        start = $scope.per_page * ($scope.cur_page - 1)
        end = start + $scope.per_page - 1
        new_tracks = $scope.tracks[start..end]
        $scope.rendered_tracks = ($scope.rendered_tracks || []).concat(new_tracks)


      getTracks = () ->
        prms = {
          count:  $scope.per_part
          offset: $scope.per_part * ($scope.cur_part - 1)
        }

        API.getTracks(788157, prms).then (tracks) ->
          $scope.tracks = ($scope.tracks || []).concat(tracks.items)

          renderPage()
          $scope.is_loading = no
          $scope.cur_part += 1
          $scope.$apply()

          # http://goo.gl/xxfBVq
          $timeout (-> $scope.helpers.resizeIFrame()), 1000, false
          #$scope.$on('$viewContentLoaded', $scope.helpers.resizeIFrame()))
          #$scope.$on('$includeContentLoaded', $scope.helpers.resizeIFrame()))


      getTracks()


      $scope.improve = ->
        for track in tracks
          q = "#{track.artist} #{track.title}"
          API.searchTrack(q).then (searched_tracks) ->
            console.info(searched_tracks.slice(1))
          return


      loadMore = ->
        return if $scope.is_loading
        console.info('load more')

        $scope.is_loading = yes

        renderPage()
        $scope.cur_page += 1
        $scope.$apply()

        $timeout (-> $scope.is_loading = false), 1000, false
        $timeout (-> $scope.helpers.resizeIFrame()), 100, false

        getTracks() if isAlmostLastPart()

      isAlmostLastPart = ->
        all_tacks_count = $scope.tracks.length
        last_page = Math.floor(all_tacks_count / $scope.per_page)
        $scope.cur_page is last_page


      initScroll (scroll, height) ->
        loadMore() if ($window.innerHeight - (scroll + height)) < 200


      $scope.showTrack = (aid) ->
        track = ($scope.tracks.filter (t) -> t.id == aid)[0]
        console.info('show track', track)

        if $scope.cur_selected_track is aid
          return $scope.cur_selected_track = null
        else
          $scope.cur_selected_track = aid

        if (lid = track.lyrics_id)? and !track.lyrics_text
          track.is_loading = yes
          API.getLyrics(lid).then (resp) ->
            track.is_loading = no
            if resp.text?
              $scope.$apply -> track.lyrics_text = resp.text
            else
              console.error(resp)

        else
          # render partial for selecting proper text


      $scope.isTrackSelected = (aid) ->
        $scope.cur_selected_track is aid

      $scope.showUserTracks = (id) =>

      return
    ]