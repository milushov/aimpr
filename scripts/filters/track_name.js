
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
