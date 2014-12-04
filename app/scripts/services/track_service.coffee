###*
 # @ngdoc service
 # @name aimprApp.trackService
 # @description
 # # trackService
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'TrackService', ['API', 'Info', (API, Info) ->
    @save = (track) ->
      text = track.lyrics[track.best_lyrics_from]
      API.saveTrack(Info.viewer_id, track.id, text).then (data) ->
        debugger

    return
  ]
