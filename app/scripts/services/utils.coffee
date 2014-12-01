'use strict'

###*
 # @ngdoc service
 # @name aimprApp.utils
 # @description
 # # utils
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .value('Q', Q)

  .factory 'VK', ['Q', (Q) ->
    deferred = Q.defer()
    VK.init ->
      deferred.resolve VK
    , ->
      console.error('error with VK init')
    , '5.8'
    deferred.promise
  ]

  .factory 'initScroll', ['VK', (VK) -> (callback)->
    VK.then (vk) ->
      vk.callMethod('scrollSubscribe', true)
      vk.addCallback 'onScroll', (scroll, height) ->
        callback(scroll, height)
  ]
