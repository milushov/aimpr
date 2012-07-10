class window.App
  user: {}
  my_audio: []
  without_lyrics: []
  searshed_tracks: {}
  progress: null

  init: (settings = null) ->
    console.info 'app initialize'

    ar = $.url().param 'api_result'
    ar = decodeURIComponent ar
    ar = JSON.parse ar

    @user = ar.response[0]

    @progress = $('#progress_improving')

    this

  start: (uid = '') ->
    console.info 'app start'

    VK.api 'audio.get', uid: uid, (data) ->
      if data.error
        return alert err data

      app.my_audio = data.response
      console.info "у пользователя #{app.my_audio.length} треков"

      for track, i in app.my_audio
        unless track.lyrics_id?
          app.without_lyrics.push track

      console.info "#{app.without_lyrics.length} треков без текста 
      (#{app.my_audio.length} всего)"

  improve2: ->
    console.info 'Поиск треков..'

    @parts = {}

    for track, i in @without_lyrics
      ind = parseInt (i/5).toString().split('.')[0]
      @parts[ind] ||= []
      @parts[ind].push track

    @_count = Object.size @parts
    @_ready = 0

    @_exit = setInterval ->
      code = app._makeCode app.parts[app._ready]

      VK.api 'execute', code: code, (data) ->
        if data.error
          return alert err data

        for key, tracks of data.response
          if tracks.length > 1
            id = key.split('_')[1]
            app.searshed_tracks[id] = tracks[1..-1]

        # console.log app.searshed_tracks
        
        app._ready += 1

        perc = (app._ready * 100 / app._count).toFixed()
        perc = "#{ perc }%"
        app.progress.width perc

        if app._ready is app._count
          clearInterval app._exit
          l = Object.size app.searshed_tracks
          alert "Найдены тексты к #{ l } треку."
    , 700

  improve: ->
    console.info 'Поиск треков..'

    @_count = Object.size @without_lyrics
    @_ready = 0

    @_exit = setInterval ->
      app.cur_track = app.without_lyrics[app._ready]

      params = 
        q: "#{app.cur_track.artist} #{app.cur_track.title}"
        auto_complete: 1
        sort: 1
        lyrics: 1
        count: 10

      VK.api 'audio.search', params, (data) ->
        if data.error
          return alert err data
        
        app._ready += 1

        if data.response[0] >= 1
          id = app.cur_track.aid
          app.searshed_tracks[id] = data.response[1..-1]

          perc = "#{ (app._ready * 100 / app._count).toFixed() }%"
          app.progress.width perc

          if app._ready is app._count
            clearInterval app._exit
            l = Object.size app.searshed_tracks
            alert "Найдены тексты к #{ l } треку."
    , 500

  _makeCode: (part) ->
    code = ''
    code_addition = []

    for track, i in part
      id = track.aid
      query = "#{track.artist} #{track.title}"
      code += "var track_#{id} = API.audio.search({ q: \"#{query}\",
        auto_complete: 1, sort: 1, lyrics: 1, count: 5 });"
      code_addition.push "track_#{id}: track_#{id}" 

    code += "return { #{code_addition.join ',' } };"

  updateMyTracks: (tracks) ->
    


  selectCorrectLyrics: (tracks) ->
    

  getLyrics: (ids) ->
    return false unless ids
    
    @lyrics = {}
    ids = uniq ids
    code = ''
    code_addition = []

    for id in ids
      code += "var l_#{id} = API.audio.getLyrics({lyrics_id: #{id}}); "
      code_addition.push "l_#{id}: l_#{id}"

    code += "return { #{ code_addition.join ',' } };"

    VK.api 'execute', code: code, (data) =>
      if data.error
        return alert err data

      for key, text of data.response
        id = key.split('_')[1]
        @lyrics[id] = text


$ ->
  VK.init ->
    console.info 'vk is loaded'

    window.app = new App
    app
      .init()
      .start()

    console.log app.user.first_name


window.l = () ->
  window.console.log arguments
window.e = () ->
  window.console.error arguments

window.err = (data) ->
  "#{data.error.error_code} #{data.error.error_msg}"