'use strict'

###*
 # @ngdoc service
 # @name aimprApp.VK
 # @description
 # # VK
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .value('Q', Q)
  .factory 'VK', ['Q', (Q) ->
    deferred = Q.defer()
    VK.init -> deferred.resolve VK
    deferred.promise
  ]
