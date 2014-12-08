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
      user_id = 788157


      angular.extend $scope,
        per_page:   30
        cur_page:   1
        per_part:   100
        cur_part:   1
        is_loading: yes

      $scope.$watch ->
        Stat.is_all_tracks
      , (new_val) ->
        changeTracksScope(new_val)

      changeTracksScope = (is_all_tracks) ->
        console.info(is_all_tracks)

        $scope.tracks = $scope.rendered_tracks = []
        $scope.cur_part = $scope.cur_page = 1

        if is_all_tracks
          getTracks()
        else
          getTracksWithoutLyrics()


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


      magic_offset = null

      getTracksWithoutLyrics = (callback) ->
        prms = {
          count:  $scope.per_part
          offset: magic_offset || $scope.per_part * ($scope.cur_part - 1)
        }

        API.getTracksWithoutLyrics(user_id, prms).then (tracks) ->
          magic_offset = tracks.magic_offset

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


      if Stat.is_all_tracks
        getTracks ->
          if $scope.tracks?.length
            $scope.$emit 'setFirstTrack', $scope.tracks[0]
      else
        getTracksWithoutLyrics ->
          if $scope.tracks?.length
            $scope.$emit 'setFirstTrack', $scope.tracks[0]


      $rootScope.$on 'improveList', ->
        tracklist_scope = if Stat.is_all_tracks
          'all_count'
        else 'without_lyrics_count'

        LyricsProcessor.improveList $scope.tracks, (track) ->
          if track.state is 'TEXT_FOUND'
            Stat[tracklist_scope].improved += 1
          else if track.state is 'TEXT_NOT_FOUND'
            Stat[tracklist_scope].failed += 1


      loadMore = ->
        return if $scope.is_loading or isAllTrackRendered()

        $scope.is_loading = yes

        renderPage()
        $scope.cur_page += 1
        $scope.$apply()

        $timeout (-> $scope.is_loading = false), 1000, false
        $timeout (-> ViewHelpers.resizeIFrame()), 100, false

        if Stat.is_all_tracks
          getTracks() if isAlmostLastPart()
        else
          getTracksWithoutLyrics() if isAlmostLastPart()



      isAlmostLastPart = ->
        all_tacks_count = $scope.tracks.length
        last_page = Math.floor(all_tacks_count / $scope.per_page)
        $scope.cur_page is last_page


      isAllTrackRendered = ->
        if Stat.is_all_tracks
          $scope.rendered_tracks.length >= audio_count
        else
          $scope.rendered_tracks.length >= Stat.without_lyrics_count.all


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
        return TrackService.add track
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