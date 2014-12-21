###*
 # @ngdoc service
 # @name aimprApp.trackService
 # @description
 # # trackService
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'TrackService', ['$localStorage', 'API', 'Info', ($ls, API, Info) ->
    $ls.sites = [] unless $ls.sites?
    $ls.tracks = {} unless $ls.tracks?

    @save = (track, callback) =>
      track.need_to_save = no
      API.saveTrack(Info.viewer_id, track).then (data) =>
        @saveChoiceToLocalStorage(track)
        callback() if callback

    @saveChoiceToLocalStorage = (track) ->
      site = track.best_lyrics_from
      unless ~(index = $ls.sites.indexOf(site))
        index = $ls.sites.push(site) - 1
      # shift for avoiding 0, cause it sucks in comparison statements
      $ls.tracks[track.id] = index + 1

    @getChoiceFromLocalStorage = (track) ->
      if index = $ls.tracks[track.id]
        $ls.sites[index-1] # back shift

    @add = (track, callback) ->
      API.addTrack(track).then (data) ->
        console.info('added')
        callback(data)

    @delete = (track, callback) ->
      API.deleteTrack(track).then (data) ->
        console.info('deleted')
        callback(data)

    @restore = (track, callback) ->
      API.restoreTrack(track).then (data) ->
        console.info('restored')
        callback(data)

    return
  ]
