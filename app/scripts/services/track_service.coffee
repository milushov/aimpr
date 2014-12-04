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

    @save = (track) =>
      text = track.lyrics[track.best_lyrics_from]
      API.saveTrack(Info.viewer_id, track.id, text).then (data) =>
        @saveChoiceToLocalStorage(track)

    @saveChoiceToLocalStorage = (track) ->
      site = track.best_lyrics_from
      unless ~(index = $ls.sites.indexOf(site))
        index = $ls.sites.push(site) - 1
      # shift for avoiding 0, cause it sucks in comparison statements
      $ls.tracks[track.id] = index + 1

    @getChoiceFromLocalStorage = (track) ->
      if index = $ls.tracks[track.id]
        $ls.sites[index-1] # back shift

    return
  ]
