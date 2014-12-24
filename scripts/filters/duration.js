
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
