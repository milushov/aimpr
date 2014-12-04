###*
 # @ngdoc directive
 # @name aimprApp.directive:lyricsTabs
 # @description
 # # lyricsTabs
###
angular.module('aimprApp')
  .directive 'lyricsTabs', ['$rootScope', 'TrackService', (rootScope, TrackService) ->
    templateUrl: '/views/shared/_tabs.html'
    restrict: 'E'
    scope: {
      texts: '=' #http://jsfiddle.net/joshdmiller/FHVD9/
    }
    link: (scope, element, attrs) ->
      $(".tab ul.tabs").addClass("active").find("> li:eq(0)").addClass "current"
      $(".tab ul.tabs").on  'click', "li a", (g) ->
        tab = $(this).closest(".tab")
        index = $(this).closest("li").index()
        tab.find("ul.tabs > li").removeClass "current"
        $(this).closest("li").addClass "current"
        tab.find(".tab_content").find("div.tabs_item").not("div.tabs_item:eq(" + index + ")").slideUp()
        tab.find(".tab_content").find("div.tabs_item:eq(" + index + ")").slideDown()
        g.preventDefault()

    controller: ($scope, $rootScope, TrackService) ->
      # todo read value from localStorage
      setSelectedSite = ->
        # is's kind of shitty, i know
        track = $rootScope.getCurTrack()
        $scope.selected_site = track.best_lyrics_from

      setSelectedSite()

      $rootScope.$on 'reInitLyricsTabs', setSelectedSite

      $scope.save = (site) ->
        console.info('save', $scope.selected_site)
        track = $rootScope.getCurTrack()
        track.best_lyrics_from = site
        TrackService.save(track)


      $scope.select = (site) ->
        $scope.selected_site = site

  ]
