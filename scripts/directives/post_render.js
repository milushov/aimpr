'use strict';

/**
  * @ngdoc directive
  * @name aimprApp.directive:postRender
  * @description
  * # postRender
 */
angular.module('aimprApp').directive('postRender', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return scope.$emit(attrs.postRender);
    }
  };
});
