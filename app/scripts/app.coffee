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
  'truncate'
  'ngStorage'
]).config ($routeProvider, $locationProvider) ->

  # for proper working $location.search()
  $locationProvider.html5Mode(enabled: true, requireBase: false)

  $routeProvider
    .when('/',
      templateUrl: '/views/tracks.html'
      controller: 'MainCtrl'
    )

    .when('/tracks/:trackId',
      templateUrl: '/views/track.html'
      controller: 'TrackCtrl'
    )

    .otherwise redirectTo: '/'
