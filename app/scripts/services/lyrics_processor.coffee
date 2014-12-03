###*
 # @ngdoc service
 # @name aimprApp.lyricsProcessor
 # @description
 # # lyricsProcessor
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'LyricsProcessor', ['$interval', '$rootScope', 'API', ($interval, $rootScope, API) ->

    determineBestLyrics = (texts) ->
      best_site = Object.keys(texts)[0] # longer is better 👍
      for site, text of texts
        best_site = site if text.length > texts[best_site].length
      best_site


    @improveList = (tracks) ->
      @prepareList(tracks)

    @prepareOne = (track) ->
      @prepareList([track])

    @prepareList = (tracks) ->
      #@is_processing = no

      #return alert('processing already started') if @is_processing

      #@is_processing = yes
      queue = Object.keys(tracks)

      stop_time = $interval ->
        track = tracks[queue.shift()]

        track.is_loading = yes

        API.getLyricsFromApi(track)
          .then (data) ->
            track.is_loading = no

            if data.count > 0
              track.lyrics = data.items
              track.best_lyrics_from = determineBestLyrics(data.items)
              console.info(track.best_lyrics_from)

              track.state = 'text_finded'
              track.need_to_save = yes # just for dev
              track.lyrics_vk = texts.items
              #track.lyrics_text =

            else
              track.state = 'text_not_finded'
              console.info('text_not_finded')

            $interval.cancel(stop_time) if queue.length is 0

          , (error) ->
            track.is_loading = no
            $interval.cancel(stop_time) if queue.length is 0
            console.info(error)

      , 333
    return
  ]
