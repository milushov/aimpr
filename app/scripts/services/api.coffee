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

    getApiUrl = (q) ->
      domain = if /localhost/.test(location.hostname)
        'https://localhost:5001'
      else 'https://aimpr.milushov.ru'
      "#{domain}/search/#{q}"


    processResponse = (data, deferred) ->
      if (resp = data.response)?
        deferred.resolve(resp)
      else
        error_msg = data.error.error_msg || data.error
        # show error through notify only from VK
        notify(
          message: error_msg
          classes: 'alert-danger'
        ) if typeof data.error is 'object'
        deferred.reject(new Error(error_msg))


    processServerError = (data, status, deferred) ->
      error_msg = 'server is died :( please try again later'
      notify(
        message: error_msg
        classes: 'alert-danger'
      )
      deferred.reject(new Error(error_msg))


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

      searchTracksWithLyrics: (track) ->
        d = Q.defer()
        q = "#{track.artist} #{track.title}"
        VK.then (vk) ->
          vk.api 'execute',
            code: """
              var lids = API.audio.search({
                "q":"#{q}",
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

              return {count: texts.length, items: texts, vk: true};
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

      addTrack: (track)->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.add',
            audio_id: track.id
            owner_id: track.owner_id
            (data) -> processResponse(data, d)
        d.promise

      deleteTrack: (track)->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.delete',
            audio_id: track.new_id || track.id
            owner_id: track.new_owner_id || track.owner_id
            (data) -> processResponse(data, d)
        d.promise

      restoreTrack: (track)->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.restore',
            audio_id: track.new_id || track.id
            owner_id: track.new_owner_id || track.owner_id
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

      getLyricsFromApi: (track) ->
        q = "#{track.artist} #{track.title}"
        d = Q.defer()
        $http.get(getApiUrl(q), timeout: 4000).success (data) ->
          processResponse(data, d)
        .error (data, status, headers, config) ->
          processServerError(data, status, d)
        d.promise
    }
  ]
