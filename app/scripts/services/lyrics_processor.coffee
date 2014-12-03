###*
 # @ngdoc service
 # @name aimprApp.lyricsProcessor
 # @description
 # # lyricsProcessor
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'LyricsProcessor', ['$interval', '$rootScope', 'API', 'notify', ($interval, $rootScope, API, notify) ->

    determineBestLyrics = (texts) ->
      best_site = Object.keys(texts)[0] # longer is better 👍
      for site, text of texts
        best_site = site if text.length > texts[best_site].length
      best_site


    @improveList = (tracks) ->
      @prepareList(tracks)


    @prepareOne = (track) ->
      @prepareList([track])


    is_processing = no
    @prepareList = (tracks) ->
      queue = Object.keys(tracks)[..5]
      return notify(
        message: 'processing already started'
        classes: 'alert-danger'
      ) if is_processing
      is_processing = yes

      success = (data, track) ->
        track.is_loading = no

        if data.count > 0
          track.lyrics = data.items
          track.best_lyrics_from = determineBestLyrics(data.items)
          console.info(track.best_lyrics_from)

          track.state = 'text_finded'
          track.need_to_save = yes # just for dev

        else
          track.state = 'text_not_finded'
          console.info('text_not_finded')

      fail = (error, track) ->
        track.is_loading = no
        console.error(error.message)

      check_interval = ->
        console.info('queue.length', queue.length)
        $interval.cancel(stop_time) if queue.length is 0

      tick = (track) ->
        API.getLyricsFromApi(track).then (data) ->
          success(data, track)
          check_interval()
        , (error) ->
          fail(error, track)
          check_interval()

      stop_time = $interval ->
        track = tracks[queue.shift()]
        track.is_loading = yes

        tick(track)

      , 333
    return
  ]
