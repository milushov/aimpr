#
# @ngdoc overview
# @name aimprApp
# @description
# aimprApp
#
# Main module of the application.
#/

angular.module('aimprApp', [
  #'ngAnimate',
  #'ngCookies'
  'ngRoute'
]).config ($routeProvider, $locationProvider) ->
  # for proper working $location.search()
  $locationProvider.html5Mode(enabled: true, requireBase: false)
  $routeProvider.otherwise(controller: 'MainCtrl')
