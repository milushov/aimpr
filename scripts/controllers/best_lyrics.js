
/**
  * @ngdoc function
  * @name aimprApp.controller:BestLyricsCtrl
  * @description
  * # BestLyricsCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('BestLyricsCtrl', [
  '$scope', 'LyricsProcessor', 'ViewHelpers', 'TrackService', function($scope, LyricsProcessor, ViewHelpers, TrackService) {
    $scope.helpers = ViewHelpers;
    console.info('BestLyricsCtrl');
    $scope.cur_track = TrackService.cur_track;
    if ($scope.cur_track.lyrics == null) {
      $scope.cur_track.is_loading = true;
      return LyricsProcessor.improveOne($scope.cur_track, function(track) {
        $scope.$emit('setSelectedSite');
        if (!Object.keys(track.lyrics).length) {
          track.state = 'failed';
        }
        return $scope.$apply();
      });
    }
  }
]);
