###*
 # @ngdoc filter
 # @name aimprApp.filter:duration
 # @function
 # @description
 # # duration
 # Filter in the aimprApp.
###
angular.module('aimprApp')
  .filter 'duration', ->
    (input) ->
      hours = Math.floor(input / 3600) || ''
      minutes = Math.floor((input - (hours * 3600)) / 60)
      seconds = input - (hours * 3600) - (minutes * 60)
      [hours, minutes, seconds].filter((el) -> el).join(':')
