'use strict';

/**
  * @ngdoc function
  * @name aimprApp.controller:InfoCtrl
  * @description
  * # InfoCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('InfoCtrl', [
  '$scope', 'Stat', 'API', 'Info', 'Ladda', function($scope, Stat, API, Info, ladda) {
    var improve;
    console.info('InfoCtrl');
    $scope.stat = Stat;
    improve = function() {
      $scope.$emit('improveList');
      return ladda.start();
    };
    $scope.improveList = function() {
      if (Info.viewer_id === Info.user_id) {
        return improve();
      } else {
        return $scope.$emit('showUserTracks', Info.viewer_id, function() {
          return improve();
        });
      }
    };
    return API.getAudioCountAndLyricsIds(Info.viewer_id).then(function(data) {
      $scope.stat.all_count.all = data.audio_count;
      $scope.stat.without_lyrics_count.all = (data.without_lyrics.filter(function(el) {
        return !el;
      })).length;
      return Info.without_lyrics_count = $scope.stat.without_lyrics_count.all;
    });
  }
]);
