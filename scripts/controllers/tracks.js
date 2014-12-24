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
