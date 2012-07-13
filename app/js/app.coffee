class window.App
  user: {}
  my_audio: []
  without_lyrics: []
  progress: null
  sleep: 400
  updated_traks: 0
  failed_tracks: 0

  constructor: (settings = null) ->
    console.info 'app initialize'

    ar = $.url().param 'api_result'
    ar = decodeURIComponent ar
    ar = JSON.parse ar

    @user = ar.response[0]

    @progress = $('#progress_improving')
    window.qbaka.user = "#{@user.id} #{@user.last_name} #{@user.first_name}"

  start: (uid = '') ->
    console.info 'app start'

    VK.api 'audio.get', uid: uid, (data) =>
      return alert err data if data.error

      app.my_audio = data.response
      console.info "у пользователя #{app.my_audio.length} треков"

      for track, i in app.my_audio
        unless track.lyrics_id?
          app.without_lyrics.push track

      console.info "#{@without_lyrics.length} треков без текста 
      (#{@my_audio.length} всего)"

      tracks_block = $('#tracks')

      for track in @without_lyrics
        track_block = $("<div class='track' id='track_#{track.aid}'>
          <div class='name fl_l'>#{ track.artist } – #{ track.title }</div>
          <div class='duration fl_r'>#{ @_makeDuration track.duration }</div>
        </div>")
        tracks_block.append track_block

      tracks_block.lionbars()
      VK.callMethod 'resizeWindow', 626, $('body').height() + 10

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
              @updateProgress 'ok'
              @updated_traks += 1
              if @ready is @count
                @showReport()
              else
                @improve()
      else
        console.info "По треку #{ @cur_track.artist[0..15] } - 
          #{ @cur_track.title[0..15] } ничего не найдено.."
        @ready += 1
        @updateProgress 'fail'
        @failed_tracks += 1
        if @ready is @count
          @showReport()
        else
          @improve()

  searchTracks: (track, count..., callback) ->
    console.info "Поиск трека #{ @cur_track.artist[0..15] } - 
          #{ @cur_track.title[0..15] }.."
    params = 
      q: "#{app.cur_track.artist} #{app.cur_track.title}"
      auto_complete: 1
      sort: 1
      lyrics: 1
      count: if count.length then count[0] else 15
    setTimeout (-> VK.api 'audio.search', params, callback), @sleep

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

    setTimeout (-> VK.api 'execute', code: code, callback), @sleep

  selectCorrectLyrics: (lyrics) ->
    for max of lyrics then break # getting the first property of hash
    for key, text of lyrics
      if lyrics[max].length < text.length
        max = key
    max

  updateMyTrack: (track, text, callback) ->
    console.info "Обновляем трек.. #{ track.aid }"
    params = 
      aid: track.aid
      oid: track.owner_id
      artist: track.artist
      title: track.title
      text: text

    setTimeout (-> VK.api 'audio.edit', params, callback), @sleep

  updateProgress: (state) ->
    perc = "#{ (@.ready * 100 / @.count).toFixed() }%"
    app.progress.width perc

    track_block = $("#track_#{@cur_track.aid}")

    x = if @ready > 5 then @ready * 40 else 0

    if state is 'ok'
      track_block.css(
        'background', '-webkit-gradient(linear, left top, 
        left bottom, from(#F8F8F8), to(#DBFCD8))'
      )
      $('#tracks').animate scrollTop: x, 'fast'
      $('#tracks .lb-wrap').animate scrollTop: x, 'fast'
    else
      track_block.css(
        'background', '-webkit-gradient(linear, left top,
        left bottom, from(#F8F8F8), to(#FFC6D2))'
      )
      $('#tracks .lb-wrap').animate scrollTop: x, 'fast'
      
  showReport: ->
    VK.callMethod 'scrollWindow', 0, 30
    $('#report .modal-body').html "
      Было обновлено <b>#{@updated_traks}</b>  аудиозаписей.
      Остальные <b>#{@failed_tracks}</b> записи обновить не удалоь.
    "
    $('#report').modal 'show'
    @ready = @updated_traks = @failed_tracks = 0

  _makeDuration: (dur) ->
    min = (dur/60).toFixed(0)
    sec = "#{dur%60}"
    if sec.length is 1
      sec = '0' + sec
    "#{min}:#{sec}"

  err: (data) ->
    "#{data.error.error_code} #{data.error.error_msg}"

$ ->
  VK.init ->
    console.info 'vk is loaded'
    window.app = new App()
    app.start()
    console.log app.user.first_name

  