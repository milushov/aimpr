# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp')
  .controller 'TracksCtrl', [
    '$scope', '$rootScope', '$interval', '$routeParams', 'API', 'Q', '$location', 'ViewHelpers', '$sessionStorage', '$timeout', 'initScroll', '$window', 'Stat'
    ($scope, $rootScope, $interval, $routeParams, API, Q, $location, ViewHelpers, $sessionStorage, $timeout, initScroll, $window, Stat) ->

      #$scope.stat = Stat

      console.info('MainCtrl')
      $scope.helpers = ViewHelpers

      params = $location.search()

      #api_result  = JSON.parse params.api_result
      #$scope.stat.audio_count = api_result.response.audio_count

      cur_selected_track = null
      cur_user = params.viewer_id

      angular.extend $scope,
        per_page:   30
        cur_page:   1
        per_part:   100
        cur_part:   1
        is_loading: true


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

        API.getTracks(cur_user, prms).then (tracks) ->
          $scope.tracks = ($scope.tracks || []).concat(tracks.items)

          renderPage()
          $scope.is_loading = no
          $scope.cur_part += 1
          $scope.$apply()

          # http://goo.gl/xxfBVq
          $timeout (-> $scope.helpers.resizeIFrame()), 100, false
          #$scope.$on('$viewContentLoaded', $scope.helpers.resizeIFrame()))
          #$scope.$on('$includeContentLoaded', $scope.helpers.resizeIFrame()))


      getTracks()


      determineBestText = (texts) ->
        texts[0]


      is_processing = no
      $rootScope.$on 'improveList', ->
        return alert('processing already started') if is_processing
        is_processing = yes
        queue = Object.keys($scope.tracks)[0..2]

        stop_time = $interval ->
          track = $scope.tracks[queue.shift()]
          track.is_loading = yes
          q = "#{track.artist} #{track.title}"

          API.searchTracksWithLyrics(q).then (texts) ->
            track.is_loading = no

            if texts.count?
              track.state = 'text_finded'
              track.need_to_save = yes # just for dev
              track.lyrics_vk = texts.items
              track.lyrics_text = determineBestText(texts.items)
              console.info(track)
            else
              track.state = 'text_not_finded'
              console.info('text_not_finded')

            $interval.cancel(stop_time) if queue.length is 0

        , 333


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

        if cur_selected_track is aid
          return cur_selected_track = null
        else
          cur_selected_track = aid

        if (lid = track.lyrics_id)? and !track.lyrics_text
          track.is_loading = yes
          API.getLyrics(lid).then (resp) ->
            track.is_loading = no
            if resp.text?
              $scope.$apply ->
                track.lyrics_text = resp.text
            else
              console.error(resp)

        else
          # render partial for selecting proper text

        $timeout (-> $scope.helpers.resizeIFrame()), 100, false


      $scope.isTrackSelected = (aid) ->
        cur_selected_track is aid


      $rootScope.$on 'showUserTracks', (e, id) ->
        cur_user = id
        $scope.tracks = $scope.rendered_tracks = []
        $scope.cur_part = $scope.cur_page = 1
        getTracks()


      return
    ]