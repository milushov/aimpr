'use strict';

/**
 * @ngdoc overview
 * @name aimprApp
 * @description
 * # aimprApp
 *
 * Main module of the application.
 */
angular
  .module('aimprApp', [
    'ngAnimate',
    'ngCookies',
    'ngRoute'
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  });
