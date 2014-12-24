
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
