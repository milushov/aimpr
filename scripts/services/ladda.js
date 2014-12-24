
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
