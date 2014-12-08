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

    #$scope.$on '$viewContentLoaded', $scope.helpers.resizeIFrame()
    #$scope.$on '$includeContentLoaded', $scope.helpers.resizeIFrame()

    unless $scope.cur_track.lyrics?
      $scope.cur_track.is_loading = yes

      LyricsProcessor.improveOne $scope.cur_track, ->
        $scope.$emit 'setSelectedSite'
        $scope.$apply()
        #$timeout (-> $scope.helpers.resizeIFrame()), 100

  ]





