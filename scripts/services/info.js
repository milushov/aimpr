
/**
  * @ngdoc service
  * @name aimprApp.info
  * @description
  * # info
  * Service in the aimprApp.
 */
angular.module('aimprApp').service('Info', [
  '$location', function($location) {
    var params;
    params = $location.search();
    this.viewer_id = parseInt(params.viewer_id);
    return this.user_id = parseInt(params.user_id === '0' ? params.viewer_id : params.user_id);
  }
]);
