###*
 # @ngdoc service
 # @name aimprApp.lyricsProcessor
 # @description
 # # lyricsProcessor
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'LyricsProcessor', ['$interval', '$rootScope', 'API', 'TrackService', 'notify', ($interval, $rootScope, API, TrackService, notify) ->
    INTERVAL_TIME = 2000

    # return object index
    determineBestLyrics = (texts) ->
      best_site = Object.keys(texts)[0] # longer is better 👍
      for site, text of texts
        best_site = site if text.length > texts[best_site].length
      best_site


    # return text
    determineBestLyricsFromVK = (texts) ->
      best_text = texts[0]
      for text in texts
        best_text = text if text.length > best_text.length
      best_text


    @improveList = (tracks, callback, finish_callback) ->
      @prepareList(tracks, callback, finish_callback)


    @improveOne = (track, callback, finish_callback) ->
      @prepareList([track], callback, finish_callback)


    is_processing = no
    @prepareList = (tracks, callback) ->
      queue = Object.keys(tracks)
      tracks.map (t) -> t.lyrics = {}

      return notify(
        message: 'processing already started'
        classes: 'my-alert-danger'
      ) if is_processing
      is_processing = yes

      success = (data, track, req_number) ->
        track.lyrics = track.lyrics || {}

        if data.count > 0
          new_items = if data.vk
            vk: determineBestLyricsFromVK(data.items)
          else
            data.items

          angular.extend(track.lyrics, new_items)

        # if requst last
        if req_number is 0
          track.is_loading = no
          is_processing = no
          setBestLyricsfrom(track)
          callback(track)


      fail = (error, track, req_number) ->
        console.error(error.message if error.message?)

        if req_number is 0
          track.is_loading = no
          is_processing = no
          setBestLyricsfrom(track)
          callback(track)


      setBestLyricsfrom = (track) ->
        from_storage = TrackService.getChoiceFromLocalStorage(track)
        determined = determineBestLyrics(track.lyrics)
        track.best_lyrics_from = from_storage || determined


      checkQueue = ->
        console.info('queue.length', queue.length)
        if queue.length is 0
          $interval.cancel(stop_time)
          finish_callback()


      tick = (track) ->
        # how much requsts i expect
        # i.e. first request would have number 1
        # and last with nuber 0
        req_number = 2

        API.getLyricsFromApi(track).then (data) ->
          success(data, track, (req_number -= 1))
          checkQueue()
        , (error) ->
          fail(error, track, (req_number -= 1))
          checkQueue()

        # i'm not merge second call to api to first,
        # cause this aproach make interface response more long
        # and as call to VK api performed much faster,
        # we get nice interface response speed
        API.searchTracksWithLyrics(track).then (data) ->
          success(data, track, (req_number -= 1))
          checkQueue()
        , (error) ->
          fail(error, track, (req_number -= 1))
          checkQueue()


      tick(tracks[queue.shift()])


      if queue.length
        stop_time = $interval ->
          track = tracks[queue.shift()]
          track.is_loading = yes
          tick(track)
          #callback(track)

        , INTERVAL_TIME
    return
  ]
