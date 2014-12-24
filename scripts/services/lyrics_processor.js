
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
