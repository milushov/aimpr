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
