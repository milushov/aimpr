class window.App
  user: {}
  my_audio: []
  without_lyrics: []
  progress: null
  sleep: 1000

  constructor: (settings = null) ->
    console.info 'app initialize'

    ar = $.url().param 'api_result'
    ar = decodeURIComponent ar
    ar = JSON.parse ar

    @user = ar.response[0]

    @progress = $('#progress_improving')

  start: (uid = '') ->
    console.info 'app start'

    VK.api 'audio.get', uid: uid, (data) ->
      return alert err data if data.error

      app.my_audio = data.response
      console.info "у пользователя #{app.my_audio.length} треков"

      for track, i in app.my_audio
        unless track.lyrics_id?
          app.without_lyrics.push track

      console.info "#{app.without_lyrics.length} треков без текста 
      (#{app.my_audio.length} всего)"

  improve: ->
    @count ||= @without_lyrics.length
    @ready ||= 0

    @cur_track = @without_lyrics[@ready]

    @searchTracks @cur_track, (data) =>
      return alert err data if data.error

      if data.response[0] >= 1
        id = app.cur_track.aid
        searshed_tracks = data.response[1..-1]
        lyrics_ids = [] # try to delete
        lyrics_ids.push track.lyrics_id for track in searshed_tracks

        @getLyrics lyrics_ids, (data) =>
          return alert err data if data.error
          lyrics = {}
          for key, text of data.response
            id = key.split('_')[1]
            lyrics[id] = text.text

          lyr_id = @selectCorrectLyrics lyrics
          text = lyrics[lyr_id]

          @updateMyTrack @cur_track, text, (data) =>
            return alert err data if data.error

            if data.response
              @ready += 1
              @updateProgress()
              if @ready is @count
                alert "Обновлены #{ @count } трека."
              else
                @improve()
      else
        console.info "По треку #{ @cur_track.aid } ничего не найдено.."
        @ready += 1
        @updateProgress()
        @improve()

  searchTracks: (track, count..., callback) ->
    console.info "Поиск трека.. #{ track.aid }"
    params = 
      q: "#{app.cur_track.artist} #{app.cur_track.title}"
      auto_complete: 1
      sort: 1
      lyrics: 1
      count: if count.length then count[0] else 10
    setTimeout (VK.api 'audio.search', params, callback), @sleep

  getLyrics: (ids, callback) ->
    return false unless ids or not callback
    
    lyrics = {}
    ids = ids.unique()
    code = ''
    code_addition = []

    for id in ids
      code += "var l_#{id} = API.audio.getLyrics({lyrics_id: #{id}}); "
      code_addition.push "l_#{id}: l_#{id}"

    code += "return { #{ code_addition.join ',' } };"

    setTimeout (VK.api 'execute', code: code, callback), @sleep

  selectCorrectLyrics: (lyrics) ->
    for max of lyrics then break # getting the first property of hash
    for key, text of lyrics
      if lyrics[max].length < text.length
        max = key

  updateMyTrack: (track, text, callback) ->
    console.info "Обновляем трек.. #{ track.aid }"
    params = 
      aid: track.aid
      oid: track.owner_id
      artist: track.artist
      title: track.title
      text: text

    setTimeout (VK.api 'audio.edit', params, callback), @sleep

  updateProgress: ->
    perc = "#{ (@.ready * 100 / @.count).toFixed() }%"
    app.progress.width perc

$ ->
  VK.init ->
    console.info 'vk is loaded'
    window.app = new App()
    app.start()
    console.log app.user.first_name


window.l = () ->
  window.console.log arguments
window.e = () ->
  window.console.error arguments

window.err = (data) ->
  "#{data.error.error_code} #{data.error.error_msg}"