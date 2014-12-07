# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp')
  .controller 'TracksCtrl', [
    '$scope', '$rootScope', '$interval', '$routeParams', 'Info', 'TrackService', 'API', 'LyricsProcessor', 'Q', 'ViewHelpers', '$timeout', 'initScroll', '$window', 'Stat'
    ($scope, $rootScope, $interval, $routeParams, Info, TrackService, API, LyricsProcessor, Q, ViewHelpers, $timeout, initScroll, $window, Stat) ->

      #$scope.stat = Stat
      console.info('TracksCtrl')
      audio_count = Info.audio_count
      cur_selected_track = null
      $scope.viewer_id = Info.viewer_id
      user_id = Info.user_id


      angular.extend $scope,
        per_page:   30
        cur_page:   1
        per_part:   100
        cur_part:   1
        is_loading: yes


      renderPage = ->
        start = $scope.per_page * ($scope.cur_page - 1)
        end = start + $scope.per_page - 1
        new_tracks = $scope.tracks[start..end]
        $scope.rendered_tracks = ($scope.rendered_tracks || []).concat(new_tracks)


      getTracks = (callback) ->
        prms = {
          count:  $scope.per_part
          offset: $scope.per_part * ($scope.cur_part - 1)
        }

        API.getTracks(user_id, prms).then (tracks) ->
          $scope.tracks = ($scope.tracks || []).concat(tracks.items)

          renderPage()
          $scope.is_loading = no
          $scope.cur_part += 1
          $scope.$apply()

          # http://goo.gl/xxfBVq
          $timeout (-> ViewHelpers.resizeIFrame()), 100
          #$scope.$on('$viewContentLoaded', ViewHelpers.resizeIFrame()))
          #$scope.$on('$includeContentLoaded', ViewHelpers.resizeIFrame()))
          callback() if callback


      getTracks ->
        if $scope.tracks?.length
          $scope.$emit 'setFirstTrack', $scope.tracks[0]


      $rootScope.$on 'improveList', ->
        LyricsProcessor.improveList($scope.tracks)


      loadMore = ->
        return if $scope.is_loading or isAllTrackRendered()
        console.info('load more')

        $scope.is_loading = yes

        renderPage()
        $scope.cur_page += 1
        $scope.$apply()

        $timeout (-> $scope.is_loading = false), 1000, false
        $timeout (-> ViewHelpers.resizeIFrame()), 100, false

        getTracks() if isAlmostLastPart()


      isAlmostLastPart = ->
        all_tacks_count = $scope.tracks.length
        last_page = Math.floor(all_tacks_count / $scope.per_page)
        $scope.cur_page is last_page


      isAllTrackRendered = ->
        $scope.rendered_tracks.length >= audio_count


      initScroll (scroll, height) ->
        loadMore() if ($window.innerHeight - (scroll + height)) < 200


      $scope.playOrStop = (track) ->
        $scope.tracks.map (t) ->
          t.is_playing = no if t.id isnt track.id
          t

        if TrackService.cur_playing
          if TrackService.cur_playing.id is track.id
            if track.is_playing
              track.is_playing = no
              $scope.$emit('pause', track)
            else
              track.is_playing = yes
              $scope.$emit('play', track)
          else
            track.is_playing = yes
            $scope.$emit('play', track)
        else
          track.is_playing = yes
          $scope.$emit('play', track)

        TrackService.cur_playing = angular.copy(track)






      $scope.addOrRemove = (track, opts = {}) ->
        # some crazy logic here
        if opts.my_list?
          if track.deleted?
            if track.deleted is yes
              TrackService.restore track, ->
                $scope.$apply -> track.deleted = null
            else
              TrackService.add(track)
          else
            TrackService.delete track, ->
              $scope.$apply -> track.deleted = yes

        else
          if track.deleted?
            if track.deleted is yes
              TrackService.restore track, ->
                $scope.$apply -> track.deleted = no
            else
              TrackService.delete track, ->
                $scope.$apply -> track.deleted = yes
          else
            TrackService.add track, (id) ->
              track.new_id = id
              track.new_owner_id = $scope.viewer_id.toString()
              $scope.$apply -> track.deleted = no


      $scope.showTrack = (id) ->
        TrackService.cur_track = ($scope.tracks.filter (t) -> t.id is id)[0]

        if cur_selected_track is id
          return cur_selected_track = null
        else
          cur_selected_track = id

        $timeout (-> ViewHelpers.resizeIFrame()), 100, false


      $scope.isTrackSelected = (aid) ->
        cur_selected_track is aid


      $rootScope.$on 'showUserTracks', (e, id) ->
        user_id = id
        $scope.tracks = $scope.rendered_tracks = []
        $scope.cur_part = $scope.cur_page = 1
        getTracks()


      return
    ]