'use strict'

###*
 # @ngdoc service
 # @name aimprApp.API
 # @description
 # # API
 # Service in the aimprApp.
###

angular.module('aimprApp')
  .factory 'API', ['$http', 'VK', 'notify', ($http, VK, notify) ->

    getApiUrl = (sitename, artist, title) ->
      domain = unless /localhost/.test(location.hostname)
        'http://localhost:5000'
      else 'https://aimpr.milushov.ru'
      [domain, sitename, artist, title].join('/')


    processResponse = (data, deferred) ->
      if (resp = data.response)?
        deferred.resolve(resp)
      else
        notify(
          message: data.error.error_msg
          classes: 'alert-danger'
        )


    return {
      getTracks: (uid, prms = {}) ->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.get',
            count: prms.count || 100
            offset: prms.offset
            #owner_id: '-35193970',
            owner_id: uid
            (data) -> processResponse(data, d)
        d.promise

      searchTrack: (q, own = 0) ->
        lyrics = if own? then 0 else 1
        d = Q.defer()

        VK.then (vk) ->
          vk.api 'audio.search',
            q: q
            auto_complete: 1
            lyrics: lyrics
            sort: 0
            search_own: own
            count: 5
            (data) -> processResponse(data, d)
        d.promise

      searchTracksWithLyrics: (q) ->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'execute',
            code: """
              var lids = API.audio.search({
                "q":"{q}",
                "auto_complete": 1,
                "lyrics": 1,
                "sort": 2,
                "count": 7
              }).items@.lyrics_id;

              var texts = [], i = 0;

              while(i != lids.length) {
                texts.push(API.audio.getLyrics({
                  "lyrics_id": lids[i]
                }).text);
                i = i + 1;
              }

              return {count: texts.length, items: texts};
            """
            (data) -> processResponse(data, d)
        d.promise


      getLyrics: (lid) ->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.getLyrics',
            lyrics_id: lid
            (data) -> processResponse(data, d)
        d.promise

      saveTrack: (oid, aid, text)->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.edit',
            owner_id: oid
            audio_id: aid
            text:     text
            (data) -> processResponse(data, d)
        d.promise

      getFriends: (uid, prms = {})->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'friends.get',
            user_id: uid
            order:   'name'
            fields:  'nickname,domain,photo_50'
            count:   prms.count
            offset:  prms.offset
            (data) -> processResponse(data, d)
        d.promise

      getLyricsFromApi: (sitename, artist, title) ->
        d = Q.defer()
        url = getApiUrl(sitename, artist, title)
        $http.get(url).success (data) ->
          processResponse(data, d)
        .error (data) ->
          console.info(data)
        d.promise
    }
  ]
