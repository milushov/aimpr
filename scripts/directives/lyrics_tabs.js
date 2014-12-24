
/**
  * @ngdoc directive
  * @name aimprApp.directive:lyricsTabs
  * @description
  * # lyricsTabs
 */
angular.module('aimprApp').directive('lyricsTabs', [
  '$rootScope', 'TrackService', 'ViewHelpers', function(rootScope, TrackService, ViewHelpers) {
    return {
      templateUrl: 'views/shared/tabs.html',
      restrict: 'E',
      scope: {
        track: '='
      },
      link: function(scope, element, attrs) {
        $('.tab ul.tabs').addClass('active').find('> li:eq(0)').addClass('current');
        return $('.tab ul.tabs').on('click', 'li a', function(g) {
          var index, tab;
          tab = $(this).closest('.tab');
          index = $(this).closest('li').index();
          tab.find('ul.tabs > li').removeClass('current');
          $(this).closest('li').addClass('current');
          tab.find('.tab_content').find('div.tabs_item').not('div.tabs_item:eq(' + index + ')').slideUp();
          tab.find('.tab_content').find('div.tabs_item:eq(' + index + ')').slideDown();
          return g.preventDefault();
        });
      },
      controller: function($scope, $rootScope, TrackService) {
        var setSelectedSite;
        $scope.updateText = function(text) {
          return $scope.track.lyrics[$scope.selected_site] = text;
        };
        setSelectedSite = function() {
          $scope.selected_site = $scope.track.best_lyrics_from;
          return ViewHelpers.resizeIFrame();
        };
        setSelectedSite();
        $rootScope.$on('setSelectedSite', setSelectedSite);
        $scope.save = function(track) {
          track.best_lyrics_from = $scope.selected_site;
          return TrackService.save(track, function() {
            track.state = 'improved';
            return $scope.$parent.$apply();
          });
        };
        $scope.select = function(site) {
          return $scope.selected_site = site;
        };
        return $scope.isAnyText = function() {
          return Object.keys($scope.track.lyrics).length > 0;
        };
      }
    };
  }
]);
