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

    # toggler
    # it's not from statistic stuff, but.. it's more convenient to store here
    @is_all_tracks = no

    @all_count = {
      all:      0
      improved: 0
      failed:   0
    }

    @without_lyrics_count = {
      all:      0
      improved: 0
      failed:   0
    }

    return
