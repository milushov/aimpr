###*
 # @ngdoc function
 # @name aimprApp.controller:BestLyricsCtrl
 # @description
 # # BestLyricsCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'BestLyricsCtrl', ['$scope', 'LyricsProcessor', 'ViewHelpers', 'TrackService', ($scope, LyricsProcessor, ViewHelpers, TrackService) ->
    $scope.helpers = ViewHelpers
    console.info('BestLyricsCtrl')

    $scope.cur_track = TrackService.cur_track

    unless $scope.cur_track.lyrics?
      $scope.cur_track.is_loading = yes

      LyricsProcessor.improveOne $scope.cur_track, (track) ->
        $scope.$emit 'setSelectedSite'
        track.state = 'failed' unless Object.keys(track.lyrics).length
        $scope.$apply()
  ]





