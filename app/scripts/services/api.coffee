'use strict'

###*
 # @ngdoc service
 # @name aimprApp.API
 # @description
 # # API
 # Service in the aimprApp.
###

angular.module('aimprApp')
  .factory 'API', ['VK', (VK) ->
    # AngularJS will instantiate a singleton by calling "new" on this function

    return {
      getTracks: (uid) ->
        deferred = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.get',
            count: 100,
            #owner_id: '-35193970',
            owner_id: uid,
            (data) ->
              deferred.resolve(data.response)

        deferred.promise

      searchTrack: (q) ->
        deferred = Q.defer()

        VK.then (vk) ->
          vk.api 'audio.search',
            q: q
            auto_complete: 1
            lyrics: 1
            sort: 2
            search_own: 0
            count: 5
            (data) ->
              deferred.resolve(data.response)

        deferred.promise

      saveTrack: (oid, aid, text)->
        deferred = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.edit',
            owner_id: oid
            audio_id: aid
            text:     text
            (data) ->
              deferred.resolve(data.response)

        deferred.promise
    }
  ]
