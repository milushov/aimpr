'use strict';

/**
  * @ngdoc directive
  * @name aimprApp.directive:wtf
  * @description
  * # wtf
 */
angular.module('aimprApp').directive('wtf', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      if (!localStorage['wtf_read']) {
        return element.click();
      }
    }
  };
});
