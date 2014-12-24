'use strict'

###*
 # @ngdoc service
 # @name aimprApp.API
 # @description
 # # API
 # Service in the aimprApp.
###

angular.module('aimprApp')
  .factory 'API', ['$http', '$timeout', 'VK', 'notify', ($http, $timeout, VK, notify) ->
    is_server_died = no

    getApiUrl = (q) ->
      domain = if /localhost/.test(location.hostname)
        'https://localhost:2053'
      else 'https://aimpr.milushov.ru:2053'
      "#{domain}/search/#{q}"


    processResponse = (data, deferred) ->
      if (resp = data.response)?
        deferred.resolve(resp)
      else
        error_msg = data.error.error_msg || data.error
        # show error through notify only from VK
        notify(
          message: error_msg
          classes: 'my-alert-danger'
        ) if typeof data.error is 'object'
        deferred.reject(new Error(error_msg))


    _processServerError = (data, status, deferred) ->
      error_msg = 'server is died :( please try again later'
      unless is_server_died
        notify(
          message: error_msg
          classes: 'my-alert-danger'
        )

        $timeout (-> is_server_died = no), 10000

      is_server_died = yes
      deferred.reject(new Error(error_msg))


    processServerError = (data, status, deferred) ->
      error_msg = 'server is died or thinking more than 3 seconds :( please try again later'
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

      getTracksWithoutLyrics: (uid, prms = {}) ->
        # optimal count is 100
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'execute',
            code: """
              var count = #{prms.count},
                  over_count = count*2,
                  offset = #{prms.offset},
                  i = 0,
                  magic_offset = null,
                  audio_ids = "";

              var a = API.audio.get({
                owner_id: #{uid},
                offset: offset,
                count: over_count
              }).items;

              var x = 0;

              while (i <= a.length) {
                if(!a[i].lyrics_id && !magic_offset) {
                  x = x + 1;
                  audio_ids = audio_ids + "," + a[i].id;
                }

                i = i + 1;
                if(x == count) {
                  magic_offset = offset + i;
                  i = 100500;
                }
              }

              var audio_without_lyrics = null;

              if(audio_ids != ",") {
                audio_without_lyrics = API.audio.get({
                  owner_id: #{uid},
                  audio_ids: audio_ids
                }).items;
              } else {
                audio_without_lyrics = [];
              }

              if(!magic_offset) magic_offset = offset + over_count;

              return {
                items: audio_without_lyrics,
                magic_offset: magic_offset
              };
            """
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

      getAudioCountAndLyricsIds: (id) ->
        d = Q.defer()
        VK.then (vk) ->
          vk.api 'execute',
            code: """
              var a = API.audio.getCount({"owner_id": #{id}});
              if (a > 6000) a = 6000;
              var b = API.audio.get({"owner_id": #{id}}).items@.lyrics_id;
              return { audio_count: a, without_lyrics: b };
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

      saveTrack: (oid, track)->
        d = Q.defer()

        if track.need_to_save
          VK.then (vk) ->
            vk.api 'audio.edit',
              owner_id: oid
              audio_id: track.id
              text:     track.lyrics[track.best_lyrics_from]
              (data) -> processResponse(data, d)
        else
          processResponse(response: track.id, d)

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
        $http.get(getApiUrl(q), timeout: 3000).success (data) ->
          processResponse(data, d)
        .error (data, status, headers, config) ->
          processServerError(data, status, d)
        d.promise
    }
  ]
