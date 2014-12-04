###*
 # @ngdoc function
 # @name aimprApp.controller:BestLyricsCtrl
 # @description
 # # BestLyricsCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'BestLyricsCtrl', ['$scope', '$timeout', 'LyricsProcessor', 'ViewHelpers', ($scope, $timeout, LyricsProcessor, ViewHelpers) ->
    $scope.helpers = ViewHelpers
    console.info('BestLyricsCtrl')

    $scope.cur_track = $scope.getCurTrack()


    #$scope.$on '$viewContentLoaded', $scope.helpers.resizeIFrame()
    #$scope.$on '$includeContentLoaded', $scope.helpers.resizeIFrame()

    if $scope.cur_track.lyrics?
      $scope.$apply()
      $timeout (-> $scope.$emit 'initLyricsTabs' ), 100
    else
      $scope.cur_track.is_loading = yes

      LyricsProcessor.prepareOne $scope.cur_track, ->
        $scope.$emit 'initLyricsTabs'
        $scope.$apply()
        #$timeout (-> $scope.helpers.resizeIFrame()), 100


  ]





