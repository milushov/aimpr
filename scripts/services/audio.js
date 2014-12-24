
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
