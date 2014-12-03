###*
 # @ngdoc service
 # @name aimprApp.lyricsProcessor
 # @description
 # # lyricsProcessor
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'LyricsProcessor', ['$interval', '$rootScope', 'API', 'notify', ($interval, $rootScope, API, notify) ->
    INTERVAL_TIME = 333

    determineBestLyrics = (texts) ->
      best_site = Object.keys(texts)[0] # longer is better 👍
      for site, text of texts
        best_site = site if text.length > texts[best_site].length
      best_site


    @improveList = (tracks, callback) ->
      @prepareList(tracks, callback)


    @prepareOne = (track, callback) ->
      @prepareList([track], callback)


    is_processing = no
    @prepareList = (tracks, callback) ->
      queue = Object.keys(tracks)[..5]
      return notify(
        message: 'processing already started'
        classes: 'alert-danger'
      ) if is_processing
      is_processing = yes

      success = (data, track) ->
        track.is_loading = no
        is_processing = no

        if data.count > 0
          track.lyrics = data.items
          track.best_lyrics_from = determineBestLyrics(data.items)
          console.info(track.best_lyrics_from)

          track.state = 'text_finded'
          track.need_to_save = yes # just for dev

        else
          track.state = 'text_not_finded'
          console.info('text_not_finded')

        callback()

      fail = (error, track) ->
        track.is_loading = no
        is_processing = no
        console.error(error.message)
        callback()

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

      tick(tracks[queue.shift()])

      if queue.length
        stop_time = $interval ->
          track = tracks[queue.shift()]
          track.is_loading = yes
          tick(track)

        , INTERVAL_TIME
    return
  ]
