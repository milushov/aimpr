'use strict';

/**
  * @ngdoc function
  * @name aimprApp.controller:PlayerCtrl
  * @description
  * # PlayerCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('PlayerCtrl', [
  '$scope', '$rootScope', '$interval', 'audio', function($scope, $rootScope, $interval, audio) {
    var pause, play, setCurPlaying, stopTick, stop_time, tick, transform;
    console.info('PlayerCtrl');
    $scope.cur_time = 0;
    $scope.cur_playing = null;
    $scope.position = {
      cur: 0,
      max: 1000
    };
    stop_time = null;
    audio.setEndHandler(function() {
      return $scope.$emit('getNextTrack', $scope.cur_playing.id);
    });
    transform = function(val, dir) {
      if (dir === 'time_to_position') {
        return $scope.cur_time * $scope.position.max / $scope.cur_playing.duration;
      } else {
        return $scope.cur_playing.duration * $scope.position.cur / $scope.position.max;
      }
    };
    stopTick = function() {
      $interval.cancel(stop_time);
      return stop_time = null;
    };
    tick = function() {
      if (audio.el.currentTime < $scope.cur_playing.duration) {
        $scope.cur_time = audio.el.currentTime;
      }
      return $scope.position.cur = transform($scope.cur_time, 'time_to_position');
    };
    $scope.$watch('position.cur', function(val) {
      if (!$scope.cur_playing) {
        return;
      }
      audio.el.currentTime = transform(val, 'position_to_time');
      return tick();
    });
    play = function(track) {
      if (track.id !== $scope.cur_playing.id) {
        setCurPlaying(track);
        $scope.position.cur = 0;
        $scope.cur_time = 0;
        stopTick();
      }
      if (!stop_time) {
        stop_time = $interval((function() {
          return tick();
        }), 1000);
      }
      if ($scope.cur_time === 0) {
        audio.play(track.url);
      } else {
        audio.play();
      }
      return tick();
    };
    pause = function(track) {
      stopTick();
      return audio.pause();
    };
    $scope.playOrPause = function() {
      $scope.cur_playing.is_playing = !$scope.cur_playing.is_playing;
      if ($scope.cur_playing.is_playing) {
        return play($scope.cur_playing);
      } else {
        return pause($scope.cur_playing);
      }
    };
    $rootScope.$on('setFirstTrack', function(e, track) {
      return setCurPlaying(track);
    });
    $rootScope.$on('play', function(e, track) {
      return play(track);
    });
    $rootScope.$on('pause', function(e, track) {
      return pause(track);
    });
    return setCurPlaying = function(track) {
      if (($scope.cur_playing == null) || $scope.cur_playing.id !== track.id) {
        return $scope.cur_playing = track;
      }
    };
  }
]);
