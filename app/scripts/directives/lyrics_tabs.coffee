###*
 # @ngdoc directive
 # @name aimprApp.directive:lyricsTabs
 # @description
 # # lyricsTabs
###
angular.module('aimprApp')
  .directive 'lyricsTabs', ['$rootScope', 'TrackService', 'ViewHelpers', (rootScope, TrackService, ViewHelpers) ->
    templateUrl: 'views/shared/tabs.html'
    restrict: 'E'
    scope: {
      track: '=' #http://jsfiddle.net/joshdmiller/FHVD9/
    }
    link: (scope, element, attrs) ->
      $('.tab ul.tabs').addClass('active').find('> li:eq(0)').addClass 'current'
      $('.tab ul.tabs').on  'click', 'li a', (g) ->
        tab = $(this).closest('.tab')
        index = $(this).closest('li').index()
        tab.find('ul.tabs > li').removeClass 'current'
        $(this).closest('li').addClass 'current'
        tab.find('.tab_content').find('div.tabs_item').not('div.tabs_item:eq(' + index + ')').slideUp()
        tab.find('.tab_content').find('div.tabs_item:eq(' + index + ')').slideDown()
        g.preventDefault()

    controller: ($scope, $rootScope, TrackService) ->
      $scope.updateText = (text) ->
        $scope.track.lyrics[$scope.selected_site] = text

      setSelectedSite = ->
        $scope.selected_site = $scope.track.best_lyrics_from
        ViewHelpers.resizeIFrame()

      setSelectedSite()

      $rootScope.$on 'setSelectedSite', setSelectedSite

      $scope.save = (track) ->
        track.best_lyrics_from = $scope.selected_site
        TrackService.save track, ->
          track.state = 'improved'
          $scope.$parent.$apply()

      $scope.select = (site) ->
        $scope.selected_site = site

      $scope.isAnyText = ->
        Object.keys($scope.track.lyrics).length > 0

  ]
