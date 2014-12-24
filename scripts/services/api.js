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
