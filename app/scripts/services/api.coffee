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

    return \
      getTracks: ->
        deferred = Q.defer()
        VK.then (vk) ->
          vk.api 'audio.get', count: 10,
            (data) ->
              deferred.resolve(data.response)

        deferred.promise

      searchTrack: ->
        console.log('yo')
  ]
