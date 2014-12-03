###*
 # @ngdoc function
 # @name aimprApp.controller:BestLyricsCtrl
 # @description
 # # BestLyricsCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'BestLyricsCtrl', ['$scope', 'LyricsProcessor', 'ViewHelpers', ($scope, LyricsProcessor, ViewHelpers) ->
    $scope.helpers = ViewHelpers
    console.info('BestLyricsCtrl')

    $scope.cur_track = $scope.getCurTrack()


    #$scope.$on '$viewContentLoaded', $scope.helpers.resizeIFrame()
    #$scope.$on '$includeContentLoaded', $scope.helpers.resizeIFrame()

    unless $scope.cur_track.texts?
      $scope.cur_track.is_loading = yes

      LyricsProcessor.prepareOne $scope.cur_track, ->
        $scope.$apply()
        $timeout (-> $scope.helpers.resizeIFrame()), 100


  ]





