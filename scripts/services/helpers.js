
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
