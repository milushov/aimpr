'use strict';

/**
  * @ngdoc service
  * @name aimprApp.utils
  * @description
  * # utils
  * Service in the aimprApp.
 */
angular.module('aimprApp').value('Q', Q).factory('VK', [
  'Q', function(Q) {
    var deferred;
    deferred = Q.defer();
    VK.init(function() {
      return deferred.resolve(VK);
    }, function() {
      return console.error('error with VK init');
    }, '5.27');
    return deferred.promise;
  }
]).factory('initScroll', [
  'VK', function(VK) {
    return function(callback) {
      return VK.then(function(vk) {
        vk.callMethod('scrollSubscribe', true);
        return vk.addCallback('onScroll', function(scroll, height) {
          return callback(scroll, height);
        });
      });
    };
  }
]);
