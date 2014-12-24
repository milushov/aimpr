/*! aimpr 0.0.0 Wed Dec 24 2014 14:26:01 GMT+0300 (MSK) */
angular.module('aimprApp', ['ngAnimate', 'monospaced.elastic', 'ngRoute', 'truncate', 'ngStorage', 'cgNotify']).config([
  '$locationProvider', function($locationProvider) {
    return $locationProvider.html5Mode({
      enabled: true,
      requireBase: false
    });
  }
]);


/**
  * @ngdoc function
  * @name aimprApp.controller:BestLyricsCtrl
  * @description
  * # BestLyricsCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('BestLyricsCtrl', [
  '$scope', 'LyricsProcessor', 'ViewHelpers', 'TrackService', function($scope, LyricsProcessor, ViewHelpers, TrackService) {
    $scope.helpers = ViewHelpers;
    console.info('BestLyricsCtrl');
    $scope.cur_track = TrackService.cur_track;
    if ($scope.cur_track.lyrics == null) {
      $scope.cur_track.is_loading = true;
      return LyricsProcessor.improveOne($scope.cur_track, function(track) {
        $scope.$emit('setSelectedSite');
        if (!Object.keys(track.lyrics).length) {
          track.state = 'failed';
        }
        return $scope.$apply();
      });
    }
  }
]);


/**
  * @ngdoc function
  * @name aimprApp.controller:FriendsCtrl
  * @description
  * # FriendsCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('FriendsCtrl', [
  '$scope', '$interval', 'API', 'Info', function($scope, $interval, API, Info) {
    var cur_page, cur_part, friends_count, getFriends, isAlmostLastPage, is_all_friends_loaded, per_page, per_part, renderPage, searchFriendsByName, search_name;
    console.info('FriendsCtrl');
    friends_count = 0;
    per_page = 7;
    cur_page = 1;
    per_part = 15;
    cur_part = 1;
    $scope.getPerPage = function() {
      return cur_page;
    };
    $scope.search = {
      name: ''
    };
    $scope.is_loading = false;
    is_all_friends_loaded = false;
    $scope.user_id = Info.user_id;
    $scope.viewer_id = Info.viewer_id;
    $scope.$watch((function() {
      return Info.user_id;
    }), function(new_val) {
      return $scope.user_id = new_val;
    });
    $scope.$watch((function() {
      return Info.viewer_id;
    }), function(new_val) {
      return $scope.viewer_id = new_val;
    });
    renderPage = function(dir) {
      var end, max_page, start;
      max_page = Math.ceil(friends_count / per_page);
      if (dir === 'next') {
        if (cur_page < max_page) {
          cur_page += 1;
        } else {
          cur_page = 1;
        }
      }
      start = per_page * (cur_page - 1);
      end = start + per_page - 1;
      return $scope.rendered_friends = $scope.friends.slice(start, +end + 1 || 9e9);
    };
    getFriends = function() {
      var prms;
      prms = {
        count: per_part,
        offset: per_part * (cur_part - 1)
      };
      return API.getFriends(788157, prms).then(function(friends) {
        friends_count = friends_count || friends.count;
        $scope.friends = ($scope.friends || []).concat(friends.items);
        renderPage('cur');
        cur_part += 1;
        return $scope.$apply();
      });
    };
    getFriends();
    $scope.showPart = function(direction) {
      renderPage(direction);
      if (isAlmostLastPage() && !is_all_friends_loaded) {
        return getFriends();
      }
    };
    isAlmostLastPage = function() {
      var last_page;
      last_page = Math.ceil($scope.friends.length / per_page) - 1;
      return cur_page === last_page;
    };
    searchFriendsByName = function(name) {
      var filter, regexp;
      regexp = new RegExp(name, 'gim');
      filter = function(friend) {
        return regexp.test(friend.first_name) || regexp.test(friend.last_name);
      };
      return $scope.friends.filter(filter).slice(0, 10);
    };
    search_name = '';
    $scope.getFriendsByName = function(name) {
      var request_count, stop_time;
      search_name = name;
      if ($scope.is_loading) {
        return console.info('loading friends for searching..');
      }
      if (name.length > 0) {
        if ($scope.friends.length < friends_count) {
          $scope.rendered_friends = searchFriendsByName(name);
          $scope.is_loading = true;
          $scope.friends = $scope.friends.slice(0, +(per_part - 1) + 1 || 9e9);
          request_count = Math.ceil(friends_count / per_part) - 1;
          cur_part = 2;
          return stop_time = $interval(function() {
            var prms;
            if (request_count === 0) {
              $interval.cancel(stop_time);
              $scope.rendered_friends = searchFriendsByName(search_name);
              $scope.is_loading = false;
              is_all_friends_loaded = true;
              return;
            }
            prms = {
              count: per_part,
              offset: per_part * (cur_part - 1)
            };
            return API.getFriends(788157, prms).then(function(friends) {
              $scope.friends = $scope.friends.concat(friends.items);
              cur_part += 1;
              return request_count -= 1;
            });
          }, 333);
        } else {
          return $scope.rendered_friends = searchFriendsByName(name);
        }
      } else {
        return renderPage('cur');
      }
    };
    $scope.showUserTracks = function(id) {
      return $scope.$emit('showUserTracks', id);
    };
  }
]);

'use strict';

/**
  * @ngdoc function
  * @name aimprApp.controller:InfoCtrl
  * @description
  * # InfoCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('InfoCtrl', [
  '$scope', 'Stat', 'API', 'Info', 'Ladda', function($scope, Stat, API, Info, ladda) {
    var improve;
    console.info('InfoCtrl');
    $scope.stat = Stat;
    improve = function() {
      $scope.$emit('improveList');
      return ladda.start();
    };
    $scope.improveList = function() {
      if (Info.viewer_id === Info.user_id) {
        return improve();
      } else {
        return $scope.$emit('showUserTracks', Info.viewer_id, function() {
          return improve();
        });
      }
    };
    return API.getAudioCountAndLyricsIds(Info.viewer_id).then(function(data) {
      $scope.stat.all_count.all = data.audio_count;
      $scope.stat.without_lyrics_count.all = (data.without_lyrics.filter(function(el) {
        return !el;
      })).length;
      return Info.without_lyrics_count = $scope.stat.without_lyrics_count.all;
    });
  }
]);

'use strict';

/**
  * @ngdoc function
  * @name aimprApp.controller:PlayerCtrl
  * @description
  * # PlayerCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('PlayerCtrl', [
  '$scope', '$rootScope', '$interval', 'audio', function($scope, $rootScope, $interval, audio) {
    var pause, play, setCurPlaying, stopTick, stop_time, tick, transform;
    console.info('PlayerCtrl');
    $scope.cur_time = 0;
    $scope.cur_playing = null;
    $scope.position = {
      cur: 0,
      max: 1000
    };
    stop_time = null;
    audio.setEndHandler(function() {
      return $scope.$emit('getNextTrack', $scope.cur_playing.id);
    });
    transform = function(val, dir) {
      if (dir === 'time_to_position') {
        return $scope.cur_time * $scope.position.max / $scope.cur_playing.duration;
      } else {
        return $scope.cur_playing.duration * $scope.position.cur / $scope.position.max;
      }
    };
    stopTick = function() {
      $interval.cancel(stop_time);
      return stop_time = null;
    };
    tick = function() {
      if (audio.el.currentTime < $scope.cur_playing.duration) {
        $scope.cur_time = audio.el.currentTime;
      }
      return $scope.position.cur = transform($scope.cur_time, 'time_to_position');
    };
    $scope.$watch('position.cur', function(val) {
      if (!$scope.cur_playing) {
        return;
      }
      audio.el.currentTime = transform(val, 'position_to_time');
      return tick();
    });
    play = function(track) {
      if (track.id !== $scope.cur_playing.id) {
        setCurPlaying(track);
        $scope.position.cur = 0;
        $scope.cur_time = 0;
        stopTick();
      }
      if (!stop_time) {
        stop_time = $interval((function() {
          return tick();
        }), 1000);
      }
      if ($scope.cur_time === 0) {
        audio.play(track.url);
      } else {
        audio.play();
      }
      return tick();
    };
    pause = function(track) {
      stopTick();
      return audio.pause();
    };
    $scope.playOrPause = function() {
      $scope.cur_playing.is_playing = !$scope.cur_playing.is_playing;
      if ($scope.cur_playing.is_playing) {
        return play($scope.cur_playing);
      } else {
        return pause($scope.cur_playing);
      }
    };
    $rootScope.$on('setFirstTrack', function(e, track) {
      return setCurPlaying(track);
    });
    $rootScope.$on('play', function(e, track) {
      return play(track);
    });
    $rootScope.$on('pause', function(e, track) {
      return pause(track);
    });
    return setCurPlaying = function(track) {
      if (($scope.cur_playing == null) || $scope.cur_playing.id !== track.id) {
        return $scope.cur_playing = track;
      }
    };
  }
]);

angular.module('aimprApp').controller('TracksCtrl', [
  '$scope', '$rootScope', '$interval', '$routeParams', 'Info', 'TrackService', 'API', 'LyricsProcessor', 'Q', 'ViewHelpers', '$timeout', 'initScroll', '$window', 'Stat', 'Ladda', function($scope, $rootScope, $interval, $routeParams, Info, TrackService, API, LyricsProcessor, Q, ViewHelpers, $timeout, initScroll, $window, Stat, ladda) {
    var audio_count, changeTracksScope, cur_selected_track, getTracks, getTracksWithoutLyrics, isAllTrackRendered, isAlmostLastPart, isMyList, loadMore, magic_offset, renderPage, user_id;
    console.info('TracksCtrl');
    cur_selected_track = null;
    $scope.viewer_id = Info.viewer_id;
    user_id = Info.user_id;
    magic_offset = null;
    audio_count = null;
    angular.extend($scope, {
      per_page: 25,
      cur_page: 1,
      per_part: 100,
      cur_part: 1,
      is_loading: true
    });
    $scope.$watch(function() {
      return Stat.is_all_tracks;
    }, function(new_val, old_value) {
      if (new_val !== old_value) {
        return changeTracksScope(new_val);
      }
    });
    changeTracksScope = function(is_all_tracks) {
      $scope.reload = true;
      $scope.tracks = $scope.rendered_tracks = null;
      $scope.cur_part = $scope.cur_page = 1;
      magic_offset = null;
      if (is_all_tracks) {
        return getTracks(function() {
          return $scope.reload = false;
        });
      } else {
        return getTracksWithoutLyrics(function() {
          return $scope.reload = false;
        });
      }
    };
    renderPage = function() {
      var end, new_tracks, start;
      start = $scope.per_page * ($scope.cur_page - 1);
      end = start + $scope.per_page - 1;
      new_tracks = $scope.tracks.slice(start, +end + 1 || 9e9);
      $scope.rendered_tracks = ($scope.rendered_tracks || []).concat(new_tracks);
      return $scope.cur_page += 1;
    };
    getTracks = function(callback) {
      var prms;
      prms = {
        count: $scope.per_part,
        offset: $scope.per_part * ($scope.cur_part - 1)
      };
      return API.getTracks(user_id, prms).then(function(tracks) {
        $scope.tracks = ($scope.tracks || []).concat(tracks.items);
        audio_count = tracks.count;
        renderPage();
        $scope.is_loading = false;
        $scope.cur_part += 1;
        $scope.$apply();
        ViewHelpers.resizeIFrame();
        if (callback) {
          return callback();
        }
      });
    };
    getTracksWithoutLyrics = function(callback) {
      var prms;
      prms = {
        count: $scope.per_part,
        offset: magic_offset || $scope.per_part * ($scope.cur_part - 1)
      };
      return API.getTracksWithoutLyrics(user_id, prms).then(function(tracks) {
        magic_offset = tracks.magic_offset;
        $scope.tracks = ($scope.tracks || []).concat(tracks.items);
        audio_count = Info.without_lyrics_count;
        renderPage();
        $scope.is_loading = false;
        $scope.cur_part += 1;
        $scope.$apply();
        ViewHelpers.resizeIFrame();
        if (callback) {
          return callback();
        }
      });
    };
    if (Stat.is_all_tracks) {
      getTracks(function() {
        var _ref;
        if ((_ref = $scope.tracks) != null ? _ref.length : void 0) {
          $scope.$emit('setFirstTrack', $scope.tracks[0]);
          return ViewHelpers.resizeIFrame();
        }
      });
    } else {
      getTracksWithoutLyrics(function() {
        var _ref;
        if ((_ref = $scope.tracks) != null ? _ref.length : void 0) {
          $scope.$emit('setFirstTrack', $scope.tracks[0]);
          return ViewHelpers.resizeIFrame();
        }
      });
    }
    $rootScope.$on('improveList', function() {
      var tracklist_scope, tracks_count;
      tracklist_scope = Stat.is_all_tracks ? 'all_count' : 'without_lyrics_count';
      tracks_count = Stat[tracklist_scope].all;
      return LyricsProcessor.improveList($scope.tracks, function(track) {
        var completed_tracks_count;
        completed_tracks_count = Stat[tracklist_scope].improved + Stat[tracklist_scope].failed;
        ladda.progress(completed_tracks_count, tracks_count);
        if (Object.keys(track.lyrics).length) {
          return TrackService.save(track, function() {
            Stat[tracklist_scope].improved += 1;
            track.state = 'improved';
            return $scope.$parent.$apply();
          });
        } else {
          Stat[tracklist_scope].failed += 1;
          return track.state = 'failed';
        }
      }, function() {
        return lada.stop();
      });
    });
    loadMore = function() {
      $scope.is_loading = true;
      renderPage();
      $scope.$apply();
      $timeout((function() {
        return $scope.is_loading = false;
      }), 500);
      ViewHelpers.resizeIFrame();
      if (isAlmostLastPart()) {
        if (Stat.is_all_tracks || !isMyList()) {
          return getTracks();
        } else {
          return getTracksWithoutLyrics();
        }
      }
    };
    isMyList = function() {
      return $scope.viewer_id === user_id;
    };
    isAlmostLastPart = function() {
      var all_tacks_count, last_page;
      all_tacks_count = $scope.tracks.length;
      last_page = Math.floor(all_tacks_count / $scope.per_page);
      return $scope.cur_page === last_page;
    };
    isAllTrackRendered = function() {
      var _ref, _ref1;
      if (Stat.is_all_tracks || !isMyList()) {
        return ((_ref = $scope.rendered_tracks) != null ? _ref.length : void 0) >= audio_count;
      } else {
        return ((_ref1 = $scope.rendered_tracks) != null ? _ref1.length : void 0) >= Stat.without_lyrics_count.all;
      }
    };
    initScroll(function(scroll, height) {
      var is_min_heigth;
      is_min_heigth = ($window.innerHeight - (scroll + height)) < 500;
      if (is_min_heigth && !$scope.is_loading && !isAllTrackRendered()) {
        return loadMore();
      }
    });
    $scope.playOrPause = function(track) {
      $scope.tracks.map(function(t) {
        if (t.id !== track.id) {
          t.is_playing = false;
        }
        return t;
      });
      if (TrackService.cur_playing) {
        if (TrackService.cur_playing.id === track.id) {
          if (track.is_playing) {
            track.is_playing = false;
            $scope.$emit('pause', track);
          } else {
            track.is_playing = true;
            $scope.$emit('play', track);
          }
        } else {
          track.is_playing = true;
          $scope.$emit('play', track);
        }
      } else {
        track.is_playing = true;
        $scope.$emit('play', track);
      }
      return TrackService.cur_playing = angular.copy(track);
    };
    $scope.addOrRemove = function(track, opts) {
      if (opts == null) {
        opts = {};
      }
      if (opts.my_list != null) {
        if (track.deleted != null) {
          if (track.deleted === true) {
            return TrackService.restore(track, function() {
              return $scope.$apply(function() {
                return track.deleted = null;
              });
            });
          } else {
            return TrackService.add(track);
          }
        } else {
          return TrackService["delete"](track, function() {
            return $scope.$apply(function() {
              return track.deleted = true;
            });
          });
        }
      } else {
        if (track.deleted != null) {
          if (track.deleted === true) {
            return TrackService.restore(track, function() {
              return $scope.$apply(function() {
                return track.deleted = false;
              });
            });
          } else {
            return TrackService["delete"](track, function() {
              return $scope.$apply(function() {
                return track.deleted = true;
              });
            });
          }
        } else {
          return TrackService.add(track, function(id) {
            track.new_id = id;
            track.new_owner_id = $scope.viewer_id.toString();
            return $scope.$apply(function() {
              return track.deleted = false;
            });
          });
        }
      }
    };
    $scope.showTrack = function(id) {
      TrackService.cur_track = ($scope.tracks.filter(function(t) {
        return t.id === id;
      }))[0];
      if (cur_selected_track === id) {
        ViewHelpers.resizeIFrame();
        return cur_selected_track = null;
      } else {
        return cur_selected_track = id;
      }
    };
    $scope.isTrackSelected = function(aid) {
      return cur_selected_track === aid;
    };
    $rootScope.$on('showUserTracks', function(e, id, callback) {
      if (user_id === id) {
        return;
      }
      Info.user_id = user_id = id;
      $scope.tracks = $scope.rendered_tracks = null;
      $scope.cur_part = $scope.cur_page = 1;
      $scope.reload = true;
      return getTracks(function() {
        $scope.reload = false;
        if (callback) {
          return callback();
        }
      });
    });
    $rootScope.$on('getNextTrack', function(e, track_id) {
      var ind, next_id;
      ind = $scope.tracks.map(function(el) {
        return el.id;
      }).indexOf(track_id);
      next_id = ind === $scope.tracks.length - 1 ? 0 : ind + 1;
      return $scope.playOrPause($scope.tracks[next_id]);
    });
  }
]);


/**
  * @ngdoc directive
  * @name aimprApp.directive:lyricsTabs
  * @description
  * # lyricsTabs
 */
angular.module('aimprApp').directive('lyricsTabs', [
  '$rootScope', 'TrackService', 'ViewHelpers', function(rootScope, TrackService, ViewHelpers) {
    return {
      templateUrl: 'views/shared/tabs.html',
      restrict: 'E',
      scope: {
        track: '='
      },
      link: function(scope, element, attrs) {
        $('.tab ul.tabs').addClass('active').find('> li:eq(0)').addClass('current');
        return $('.tab ul.tabs').on('click', 'li a', function(g) {
          var index, tab;
          tab = $(this).closest('.tab');
          index = $(this).closest('li').index();
          tab.find('ul.tabs > li').removeClass('current');
          $(this).closest('li').addClass('current');
          tab.find('.tab_content').find('div.tabs_item').not('div.tabs_item:eq(' + index + ')').slideUp();
          tab.find('.tab_content').find('div.tabs_item:eq(' + index + ')').slideDown();
          return g.preventDefault();
        });
      },
      controller: function($scope, $rootScope, TrackService) {
        var setSelectedSite;
        $scope.updateText = function(text) {
          return $scope.track.lyrics[$scope.selected_site] = text;
        };
        setSelectedSite = function() {
          $scope.selected_site = $scope.track.best_lyrics_from;
          return ViewHelpers.resizeIFrame();
        };
        setSelectedSite();
        $rootScope.$on('setSelectedSite', setSelectedSite);
        $scope.save = function(track) {
          track.best_lyrics_from = $scope.selected_site;
          return TrackService.save(track, function() {
            track.state = 'improved';
            return $scope.$parent.$apply();
          });
        };
        $scope.select = function(site) {
          return $scope.selected_site = site;
        };
        return $scope.isAnyText = function() {
          return Object.keys($scope.track.lyrics).length > 0;
        };
      }
    };
  }
]);

'use strict';

/**
  * @ngdoc directive
  * @name aimprApp.directive:postRender
  * @description
  * # postRender
 */
angular.module('aimprApp').directive('postRender', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return scope.$emit(attrs.postRender);
    }
  };
});

'use strict';

/**
  * @ngdoc directive
  * @name aimprApp.directive:wtf
  * @description
  * # wtf
 */
angular.module('aimprApp').directive('wtf', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      if (!localStorage['wtf_read']) {
        return element.click();
      }
    }
  };
});


/**
  * @ngdoc filter
  * @name aimprApp.filter:duration
  * @function
  * @description
  * # duration
  * Filter in the aimprApp.
 */
angular.module('aimprApp').filter('duration', function() {
  return function(input, minutes_with_zerro) {
    var hours, minutes, seconds;
    hours = Math.floor(input / 3600);
    minutes = Math.floor((input - (hours * 3600)) / 60);
    seconds = Math.floor(input - (hours * 3600) - (minutes * 60));
    if (minutes_with_zerro && minutes < 10) {
      minutes = "0" + minutes;
    }
    if (seconds < 10) {
      seconds = "0" + seconds;
    }
    return [hours, "" + minutes + ":" + seconds].filter(function(el) {
      return el;
    }).join(':');
  };
});


/**
  * @ngdoc filter
  * @name aimprApp.filter:trackName
  * @function
  * @description
  * # trackName
  * Filter in the aimprApp.
 */
angular.module('aimprApp').filter('trackName', [
  '$filter', function($filter) {
    return function(track, characters_count, truncate_word) {
      if (characters_count == null) {
        characters_count = 42;
      }
      if (truncate_word == null) {
        truncate_word = false;
      }
      if (!track) {
        return;
      }
      return $filter('characters')("" + track.artist + " - " + track.title, characters_count, truncate_word);
    };
  }
]);

'use strict';

/**
  * @ngdoc service
  * @name aimprApp.API
  * @description
  * # API
  * Service in the aimprApp.
 */
angular.module('aimprApp').factory('API', [
  '$http', '$timeout', 'VK', 'notify', function($http, $timeout, VK, notify) {
    var getApiUrl, is_server_died, processResponse, processServerError, _processServerError;
    is_server_died = false;
    getApiUrl = function(q) {
      var domain;
      domain = /localhost/.test(location.hostname) ? 'https://localhost:2053' : 'https://aimpr.milushov.ru:2053';
      return "" + domain + "/search/" + q;
    };
    processResponse = function(data, deferred) {
      var error_msg, resp;
      if ((resp = data.response) != null) {
        return deferred.resolve(resp);
      } else {
        error_msg = data.error.error_msg || data.error;
        if (typeof data.error === 'object') {
          notify({
            message: error_msg,
            classes: 'my-alert-danger'
          });
        }
        return deferred.reject(new Error(error_msg));
      }
    };
    _processServerError = function(data, status, deferred) {
      var error_msg;
      error_msg = 'server is died :( please try again later';
      if (!is_server_died) {
        notify({
          message: error_msg,
          classes: 'my-alert-danger'
        });
        $timeout((function() {
          return is_server_died = false;
        }), 10000);
      }
      is_server_died = true;
      return deferred.reject(new Error(error_msg));
    };
    processServerError = function(data, status, deferred) {
      var error_msg;
      error_msg = 'server is died or thinking more than 3 seconds :( please try again later';
      return deferred.reject(new Error(error_msg));
    };
    return {
      getTracks: function(uid, prms) {
        var d;
        if (prms == null) {
          prms = {};
        }
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('audio.get', {
            count: prms.count || 100,
            offset: prms.offset,
            owner_id: uid
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      getTracksWithoutLyrics: function(uid, prms) {
        var d;
        if (prms == null) {
          prms = {};
        }
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('execute', {
            code: "var count = " + prms.count + ",\n    over_count = count*2,\n    offset = " + prms.offset + ",\n    i = 0,\n    magic_offset = null,\n    audio_ids = \"\";\n\nvar a = API.audio.get({\n  owner_id: " + uid + ",\n  offset: offset,\n  count: over_count\n}).items;\n\nvar x = 0;\n\nwhile (i <= a.length) {\n  if(!a[i].lyrics_id && !magic_offset) {\n    x = x + 1;\n    audio_ids = audio_ids + \",\" + a[i].id;\n  }\n\n  i = i + 1;\n  if(x == count) {\n    magic_offset = offset + i;\n    i = 100500;\n  }\n}\n\nvar audio_without_lyrics = null;\n\nif(audio_ids != \",\") {\n  audio_without_lyrics = API.audio.get({\n    owner_id: " + uid + ",\n    audio_ids: audio_ids\n  }).items;\n} else {\n  audio_without_lyrics = [];\n}\n\nif(!magic_offset) magic_offset = offset + over_count;\n\nreturn {\n  items: audio_without_lyrics,\n  magic_offset: magic_offset\n};"
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      searchTrack: function(q, own) {
        var d, lyrics;
        if (own == null) {
          own = 0;
        }
        lyrics = own != null ? 0 : 1;
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('audio.search', {
            q: q,
            auto_complete: 1,
            lyrics: lyrics,
            sort: 0,
            search_own: own,
            count: 5
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      searchTracksWithLyrics: function(track) {
        var d, q;
        d = Q.defer();
        q = "" + track.artist + " " + track.title;
        VK.then(function(vk) {
          return vk.api('execute', {
            code: "var lids = API.audio.search({\n  \"q\":\"" + q + "\",\n  \"auto_complete\": 1,\n  \"lyrics\": 1,\n  \"sort\": 2,\n  \"count\": 7\n}).items@.lyrics_id;\n\nvar texts = [], i = 0;\n\nwhile(i != lids.length) {\n  texts.push(API.audio.getLyrics({\n    \"lyrics_id\": lids[i]\n  }).text);\n  i = i + 1;\n}\n\nreturn {count: texts.length, items: texts, vk: true};"
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      getAudioCountAndLyricsIds: function(id) {
        var d;
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('execute', {
            code: "var a = API.audio.getCount({\"owner_id\": " + id + "});\nif (a > 6000) a = 6000;\nvar b = API.audio.get({\"owner_id\": " + id + "}).items@.lyrics_id;\nreturn { audio_count: a, without_lyrics: b };"
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      getLyrics: function(lid) {
        var d;
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('audio.getLyrics', {
            lyrics_id: lid
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      saveTrack: function(oid, track) {
        var d;
        d = Q.defer();
        if (track.need_to_save) {
          VK.then(function(vk) {
            return vk.api('audio.edit', {
              owner_id: oid,
              audio_id: track.id,
              text: track.lyrics[track.best_lyrics_from]
            }, function(data) {
              return processResponse(data, d);
            });
          });
        } else {
          processResponse({
            response: track.id
          }, d);
        }
        return d.promise;
      },
      addTrack: function(track) {
        var d;
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('audio.add', {
            audio_id: track.id,
            owner_id: track.owner_id
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      deleteTrack: function(track) {
        var d;
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('audio.delete', {
            audio_id: track.new_id || track.id,
            owner_id: track.new_owner_id || track.owner_id
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      restoreTrack: function(track) {
        var d;
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('audio.restore', {
            audio_id: track.new_id || track.id,
            owner_id: track.new_owner_id || track.owner_id
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      getFriends: function(uid, prms) {
        var d;
        if (prms == null) {
          prms = {};
        }
        d = Q.defer();
        VK.then(function(vk) {
          return vk.api('friends.get', {
            user_id: uid,
            order: 'name',
            fields: 'nickname,domain,photo_50',
            count: prms.count,
            offset: prms.offset
          }, function(data) {
            return processResponse(data, d);
          });
        });
        return d.promise;
      },
      getLyricsFromApi: function(track) {
        var d, q;
        q = "" + track.artist + " " + track.title;
        d = Q.defer();
        $http.get(getApiUrl(q), {
          timeout: 3000
        }).success(function(data) {
          return processResponse(data, d);
        }).error(function(data, status, headers, config) {
          return processServerError(data, status, d);
        });
        return d.promise;
      }
    };
  }
]);


/**
  * @ngdoc service
  * @name aimprApp.audio
  * @description
  * # audio
  * Service in the aimprApp.
 */
angular.module('aimprApp').factory('audio', [
  '$document', function($document) {
    var el;
    el = $document[0].createElement('audio');
    return {
      el: el,
      play: function(url) {
        if (url) {
          el.src = url;
        }
        return el.play();
      },
      pause: function() {
        return el.pause();
      },
      setEndHandler: function(callback) {
        return el.onended = callback;
      }
    };
  }
]);


/**
  * @ngdoc service
  * @name aimprApp.helpers
  * @description
  * # helpers
  * Factory in the aimprApp.
 */
angular.module('aimprApp').service('ViewHelpers', [
  '$document', 'VK', '$timeout', function($document, VK, $timeout) {
    this.resizeIFrame = function() {
      var TIMEOUT, body, diff, rect;
      body = $document[0].querySelector('body');
      rect = body.getBoundingClientRect();
      diff = 15;
      TIMEOUT = 200;
      return $timeout(function() {
        return VK.then(function(vk) {
          return vk.callMethod('resizeWindow', rect.width, rect.height + diff);
        });
      }, TIMEOUT);
    };
  }
]);


/**
  * @ngdoc service
  * @name aimprApp.info
  * @description
  * # info
  * Service in the aimprApp.
 */
angular.module('aimprApp').service('Info', [
  '$location', function($location) {
    var params;
    params = $location.search();
    this.viewer_id = parseInt(params.viewer_id);
    return this.user_id = parseInt(params.user_id === '0' ? params.viewer_id : params.user_id);
  }
]);


/**
  * @ngdoc service
  * @name aimprApp.ladda
  * @description
  * # ladda
  * Service in the aimprApp.
 */
angular.module('aimprApp').factory('Ladda', [
  '$document', '$rootScope', function($document, $rootScope) {
    var l;
    l = null;
    $rootScope.$on('ladda-init', function() {
      return l = Ladda.create($document[0].querySelector('.ladda-button'));
    });
    return {
      start: function() {
        return l.start();
      },
      stop: function() {
        return l.stop();
      },
      progress: function(a, b) {
        var p;
        p = Math.round(a / b * 100) / 100;
        return l.setProgress(p);
      }
    };
  }
]);


/**
  * @ngdoc service
  * @name aimprApp.lyricsProcessor
  * @description
  * # lyricsProcessor
  * Service in the aimprApp.
 */
angular.module('aimprApp').service('LyricsProcessor', [
  '$interval', '$rootScope', 'API', 'TrackService', 'notify', function($interval, $rootScope, API, TrackService, notify) {
    var INTERVAL_TIME, determineBestLyrics, determineBestLyricsFromVK, is_processing;
    INTERVAL_TIME = 2000;
    determineBestLyrics = function(texts) {
      var best_site, site, text;
      best_site = Object.keys(texts)[0];
      for (site in texts) {
        text = texts[site];
        if (text.length > texts[best_site].length) {
          best_site = site;
        }
      }
      return best_site;
    };
    determineBestLyricsFromVK = function(texts) {
      var best_text, text, _i, _len;
      best_text = texts[0];
      for (_i = 0, _len = texts.length; _i < _len; _i++) {
        text = texts[_i];
        if (text.length > best_text.length) {
          best_text = text;
        }
      }
      return best_text;
    };
    this.improveList = function(tracks, callback, finish_callback) {
      return this.prepareList(tracks, callback, finish_callback);
    };
    this.improveOne = function(track, callback, finish_callback) {
      return this.prepareList([track], callback, finish_callback);
    };
    is_processing = false;
    this.prepareList = function(tracks, callback) {
      var checkQueue, fail, queue, setBestLyricsfrom, stop_time, success, tick;
      queue = Object.keys(tracks);
      tracks.map(function(t) {
        return t.lyrics = {};
      });
      if (is_processing) {
        return notify({
          message: 'processing already started',
          classes: 'my-alert-danger'
        });
      }
      is_processing = true;
      success = function(data, track, req_number) {
        var new_items;
        track.lyrics = track.lyrics || {};
        if (data.count > 0) {
          new_items = data.vk ? {
            vk: determineBestLyricsFromVK(data.items)
          } : data.items;
          angular.extend(track.lyrics, new_items);
        }
        if (req_number === 0) {
          track.is_loading = false;
          is_processing = false;
          setBestLyricsfrom(track);
          return callback(track);
        }
      };
      fail = function(error, track, req_number) {
        console.error(error.message != null ? error.message : void 0);
        if (req_number === 0) {
          track.is_loading = false;
          is_processing = false;
          setBestLyricsfrom(track);
          return callback(track);
        }
      };
      setBestLyricsfrom = function(track) {
        var determined, from_storage;
        from_storage = TrackService.getChoiceFromLocalStorage(track);
        determined = determineBestLyrics(track.lyrics);
        return track.best_lyrics_from = from_storage || determined;
      };
      checkQueue = function() {
        console.info('queue.length', queue.length);
        if (queue.length === 0) {
          $interval.cancel(stop_time);
          return finish_callback();
        }
      };
      tick = function(track) {
        var req_number;
        req_number = 2;
        API.getLyricsFromApi(track).then(function(data) {
          success(data, track, (req_number -= 1));
          return checkQueue();
        }, function(error) {
          fail(error, track, (req_number -= 1));
          return checkQueue();
        });
        return API.searchTracksWithLyrics(track).then(function(data) {
          success(data, track, (req_number -= 1));
          return checkQueue();
        }, function(error) {
          fail(error, track, (req_number -= 1));
          return checkQueue();
        });
      };
      tick(tracks[queue.shift()]);
      if (queue.length) {
        return stop_time = $interval(function() {
          var track;
          track = tracks[queue.shift()];
          track.is_loading = true;
          return tick(track);
        }, INTERVAL_TIME);
      }
    };
  }
]);

'use strict';

/**
  * @ngdoc service
  * @name aimprApp.stat
  * @description
  * # stat
  * Service in the aimprApp.
 */
angular.module('aimprApp').service('Stat', function() {
  this.is_all_tracks = false;
  this.all_count = {
    all: 0,
    improved: 0,
    failed: 0
  };
  this.without_lyrics_count = {
    all: 0,
    improved: 0,
    failed: 0
  };
});


/**
  * @ngdoc service
  * @name aimprApp.trackService
  * @description
  * # trackService
  * Service in the aimprApp.
 */
angular.module('aimprApp').service('TrackService', [
  '$localStorage', 'API', 'Info', function($ls, API, Info) {
    if ($ls.sites == null) {
      $ls.sites = [];
    }
    if ($ls.tracks == null) {
      $ls.tracks = {};
    }
    this.save = (function(_this) {
      return function(track, callback) {
        track.need_to_save = false;
        return API.saveTrack(Info.viewer_id, track).then(function(data) {
          _this.saveChoiceToLocalStorage(track);
          if (callback) {
            return callback();
          }
        });
      };
    })(this);
    this.saveChoiceToLocalStorage = function(track) {
      var index, site;
      site = track.best_lyrics_from;
      if (!~(index = $ls.sites.indexOf(site))) {
        index = $ls.sites.push(site) - 1;
      }
      return $ls.tracks[track.id] = index + 1;
    };
    this.getChoiceFromLocalStorage = function(track) {
      var index;
      if (index = $ls.tracks[track.id]) {
        return $ls.sites[index - 1];
      }
    };
    this.add = function(track, callback) {
      return API.addTrack(track).then(function(data) {
        console.info('added');
        return callback(data);
      });
    };
    this["delete"] = function(track, callback) {
      return API.deleteTrack(track).then(function(data) {
        console.info('deleted');
        return callback(data);
      });
    };
    this.restore = function(track, callback) {
      return API.restoreTrack(track).then(function(data) {
        console.info('restored');
        return callback(data);
      });
    };
  }
]);

'use strict';

/**
  * @ngdoc service
  * @name aimprApp.utils
  * @description
  * # utils
  * Service in the aimprApp.
 */
angular.module('aimprApp').value('Q', Q).factory('VK', [
  'Q', function(Q) {
    var deferred;
    deferred = Q.defer();
    VK.init(function() {
      return deferred.resolve(VK);
    }, function() {
      return console.error('error with VK init');
    }, '5.27');
    return deferred.promise;
  }
]).factory('initScroll', [
  'VK', function(VK) {
    return function(callback) {
      return VK.then(function(vk) {
        vk.callMethod('scrollSubscribe', true);
        return vk.addCallback('onScroll', function(scroll, height) {
          return callback(scroll, height);
        });
      });
    };
  }
]);

$(function(){
  var modules = {
    $window: $(window),
    $html: $('html'),
    $body: $('body'),
    $container: $('.aimpr'),

    init: function () {
      $(function () {
        modules.modals.init();
      });
    }

    ,modals: {
      trigger: $('.yo-modal-trigger'),
      trigger_class: '.yo-modal-trigger',
      modal: $('.yo-modal'),
      scrollTopPosition: null,

      init: function () {
        var self = this;
        modules.$body.append('<div class="yo-modal-overlay"></div>');
        self.triggers();
      },

      triggers: function () {
        var self = this;

        modules.$body.on('click', self.trigger_class, function(e) {
          e.preventDefault();
          var $trigger = $(this);
          self.openModal($trigger, $trigger.data('modalId'));
        });

        $('.yo-modal-overlay').on('click', function (e) {
          e.preventDefault();
          self.closeModal();
        });

        modules.$body.on('keydown', function(e){
          if (e.keyCode === 27) {
            self.closeModal();
          }
        });

        $('.yo-modal-close').on('click', function(e) {
          e.preventDefault();
          self.closeModal();
          localStorage['wtf_read'] = true;
        });
      },

      openModal: function (_trigger, _modalId) {
        var self = this,
            scrollTopPosition = modules.$window.scrollTop(),
            $targetModal = $('#' + _modalId);

        self.scrollTopPosition = scrollTopPosition;

        modules.$html
          .addClass('yo-modal-show')
          .attr('data-modal-effect', $targetModal.data('modal-effect'));

        $targetModal.addClass('yo-modal-show');

        modules.$container.scrollTop(scrollTopPosition);
      },

      closeModal: function () {
        var self = this;

        $('.yo-modal-show').removeClass('yo-modal-show');
        modules.$html
          .removeClass('yo-modal-show')
          .removeAttr('data-modal-effect');

        modules.$window.scrollTop(self.scrollTopPosition);
      }
    }
  }

  modules.init();
})
