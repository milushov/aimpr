###*
 # @ngdoc function
 # @name aimprApp.controller:BestLyricsCtrl
 # @description
 # # BestLyricsCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'BestLyricsCtrl', ['$scope', 'LyricsProcessor', ($scope, LyricsProcessor) ->
    console.info('BestLyricsCtrl')

    $scope.cur_track = $scope.getCurTrack()


    unless $scope.cur_track.texts?
      $scope.cur_track.is_loading = yes

      LyricsProcessor.prepareOne $scope.cur_track, ->
        $scope.$apply()



  ]





