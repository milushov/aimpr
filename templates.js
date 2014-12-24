angular.module("templates", []).run(["$templateCache", function($templateCache) {$templateCache.put("views/friends.html","\n<div class=\"friends\">\n  <div ng-if=\"friends.length &gt; getPerPage()\" class=\"row friends-search-box\">\n    <div ng-class=\"{&quot;yo-hide&quot;: user_id == viewer_id}\" class=\"my-list-btn yo-hide\"><span ng-click=\"showUserTracks(viewer_id)\" class=\"glyphicon glyphicon-chevron-left\"></span></div>\n    <div ng-class=\"{&quot;with-btn&quot;: user_id != viewer_id}\" class=\"search-wrapper\">\n      <input placeholder=\"поиск..\" ng-model=\"search.name\" ng-change=\"getFriendsByName(search.name)\" class=\"form-control\"/>\n      <div ng-if=\"is_loading\" class=\"loading-bar-spinner\">\n        <div class=\"spinner-icon\"></div>\n      </div>\n    </div>\n  </div>\n  <div class=\"friends-list\">\n    <div ng-repeat=\"friend in rendered_friends track by $index\" ng-click=\"showUserTracks(friend.id)\" ng-class=\"{active: friend.id == user_id}\" class=\"row friend-item\"><img src=\"{{friend.photo_50}}\" class=\"img-circle friend-photo\"/><span class=\"friend-name\">{{friend.first_name | limitTo:10}}</span></div>\n  </div>\n  <!-- big thanks to http://stackoverflow.com/a/22570031/1171144-->\n  <div ng-if=\"(friends.length &gt; getPerPage() &amp;&amp; !search.name.length)\" class=\"row\"><a ng-click=\"showPart(&quot;next&quot;)\" class=\"btn btn-success show-more\">Еще</a></div>\n</div>");
$templateCache.put("views/info.html","\n<div class=\"toggle slide2\">\n  <input id=\"d\" type=\"checkbox\" ng-model=\"stat.is_all_tracks\"/>\n  <label for=\"d\">\n    <div class=\"card\"></div>\n  </label>\n</div>\n<div class=\"info\">\n  <div>\n    <div class=\"row\">всего</div>\n    <div class=\"row\"><b>{{stat[ stat.is_all_tracks ? \'all_count\' : \'without_lyrics_count\' ].all}}</b></div>\n  </div>\n  <div>\n    <div class=\"row\">улучшено</div>\n    <div class=\"row\"><b>{{stat[ stat.is_all_tracks ? \'all_count\' : \'without_lyrics_count\' ].improved}}</b></div>\n  </div>\n  <div>\n    <div class=\"row\">зафейлено</div>\n    <div class=\"row\"><b>{{stat[ stat.is_all_tracks ? \'all_count\' : \'without_lyrics_count\' ].failed}}</b></div>\n  </div>\n</div>\n<div class=\"improve-button\">\n  <button post-render=\"ladda-init\" ng-click=\"improveList()\" data-style=\"expand-right\" data-color=\"aimpr\" data-size=\"s\" data-spinner-color=\"AliceBlue\" class=\"ladda-button\"><span class=\"ladda-label\">Улучшить</span></button>\n</div><span wtf=\"wtf\" data-modal-id=\"wtf\" class=\"glyphicon glyphicon-info-sign yo-modal-trigger wtf\"></span>");
$templateCache.put("views/player.html","\n<div class=\"row player-wrapper\">\n  <div class=\"col-xs-2 player-play-or-stop-wrapper\"><span ng-click=\"playOrPause()\" ng-class=\"{&quot;glyphicon-play&quot;: !cur_playing.is_playing, &quot;glyphicon-pause&quot;: cur_playing.is_playing}\" class=\"glyphicon player-play-or-stop\"></span></div>\n  <div class=\"col-xs-10 player-body\">\n    <div class=\"row player-track-name\">\n      <div class=\"col-xs-10\">{{cur_playing | trackName:33 :true}}</div>\n      <div class=\"col-xs-2 player-track-duration\">{{cur_playing.duration - cur_time | duration}}</div>\n    </div>\n    <div class=\"row player-slider\">\n      <input ng-model=\"position.cur\" type=\"range\" min=\"0\" max=\"{{::position.max}}\"/>\n    </div>\n  </div>\n</div>");
$templateCache.put("views/tracks.html","\n<player ng-controller=\"PlayerCtrl\" ng-include=\"&quot;views/player.html&quot;\"></player>\n<div ng-class=\"{reload: reload}\" class=\"tracklist\">\n  <div ng-repeat=\"track in rendered_tracks track by $index\" id=\"track-{{track.id}}\" class=\"row track\">\n    <div ng-include=\"&quot;views/shared/track.html&quot;\"></div>\n  </div>\n</div>");
$templateCache.put("views/wtf.html","\n<div id=\"wtf\" data-modal-effect=\"fadescale\" class=\"yo-modal\">\n  <div class=\"yo-modal-content\">\n    <div class=\"yo-modal-content-header\"><span>Что это и зачем?</span></div>\n    <p>&nbsp;&nbsp;&nbsp;&nbsp;Слушая музыку ВК частенько хочется посмотрть текст песни, но некоторые люди вместо текста песни пихают туда <b>спам</b> или текста вообще нет.</p>\n    <p><img src=\"images/screenshot-1.png\" class=\"yo-screenshot\"/></p>\n    <p>&nbsp;&nbsp;&nbsp;&nbsp;И приходится искать текст песни вручную. С помощью этого аппа, <b>нажав одну кнопочку</b>, можно обновить все тексты песен в вашем списке аудиозаписей (если они, конечно, найдутся в сети).</p><a href=\"#\" class=\"btn btn-success yo-modal-close\">оке</a>\n  </div>\n</div>");
$templateCache.put("views/shared/tabs.html","\n<div class=\"tab\">\n  <ul class=\"tabs\">\n    <div ng-if=\"isAnyText()\">\n      <li ng-repeat=\"(site, _) in track.lyrics track by $index\" ng-class=\"{&quot;current&quot;: site == selected_site}\"><a ng-click=\"select(site)\">{{site}}</a></li>&#x9;&#x9;\n      <button ng-click=\"save(track)\" class=\"btn btn-success btn-sm save-lyrics\">Сохранить</button>\n    </div>\n    <div ng-if=\"!isAnyText() &amp;&amp; !track.is_loading\"><span class=\"lyrics-not-found\">ни одного текста не найдено :(</span></div>\n  </ul>\n  <div class=\"tab_content\">\n    <div ng-repeat=\"(_, text) in track.lyrics track by $index\" class=\"tabs_item\">\n      <textarea ng-model=\"text\" ng-change=\"updateText(text)\" rows=\"3\" class=\"form-control msd-elastic track-text\">{{text}}</textarea>\n    </div>\n  </div>\n</div>");
$templateCache.put("views/shared/track.html","\n<div ng-click=\"playOrPause(track)\" ng-class=\"{&quot;deleted&quot;: track.deleted == true, &quot;active&quot;: track.is_playing, &quot;improved&quot;: track.state == &quot;improved&quot;, &quot;failed&quot;: track.state == &quot;failed&quot; }\" class=\"row track-body\">\n  <div class=\"col-xs-1\">\n    <div ng-if=\"track.is_loading\" class=\"loading-bar-spinner\">\n      <div class=\"spinner-icon\"></div>\n    </div>\n  </div>\n  <div class=\"col-xs-1\"><span ng-class=\"{&quot;glyphicon-play&quot;: !track.is_playing, &quot;glyphicon-pause&quot;: track.is_playing}\" class=\"glyphicon\"></span></div>\n  <div class=\"col-xs-8\"><a ng-click=\"showTrack(track.id); $event.stopPropagation();\" class=\"track-name\">{{track | trackName:37 :true}}</a></div>\n  <div class=\"col-xs-2 duration-or-btn\"><span class=\"track-duration\">{{track.duration | duration}}</span><span class=\"add-remove-btn\">\n      <div ng-if=\"track.owner_id == viewer_id\" ng-class=\"{active: !track.deleted }\" ng-click=\"addOrRemove(track, {my_list: true}); $event.stopPropagation();\" class=\"square-toggle square\"></div>\n      <div ng-if=\"track.owner_id != viewer_id\" ng-class=\"{active: (track.deleted === false)}\" ng-click=\"addOrRemove(track); $event.stopPropagation();\" class=\"square-toggle square\"></div></span></div>\n</div>\n<div ng-if=\"isTrackSelected(track.id)\" class=\"row\">\n  <div class=\"col-xs-12\">\n    <div ng-controller=\"BestLyricsCtrl\">\n      <lyrics-tabs track=\"cur_track\"></lyrics-tabs>\n    </div>\n  </div>\n</div>");}]);