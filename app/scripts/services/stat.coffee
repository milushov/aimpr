'use strict'

###*
 # @ngdoc service
 # @name aimprApp.stat
 # @description
 # # stat
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'Stat', ->
    @audio_count    = 0
    @improved_count = 0
    @fail_count     = 0
