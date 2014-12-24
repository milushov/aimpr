angular.module('aimprApp', ['ngAnimate', 'monospaced.elastic', 'ngRoute', 'truncate', 'ngStorage', 'cgNotify']).config([
  '$locationProvider', function($locationProvider) {
    return $locationProvider.html5Mode({
      enabled: true,
      requireBase: false
    });
  }
]);
