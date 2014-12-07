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
    (input, minutes_with_zerro) ->
      hours = Math.floor(input / 3600)
      minutes = Math.floor((input - (hours * 3600)) / 60)
      seconds = Math.floor(input - (hours * 3600) - (minutes * 60))
      minutes = "0#{minutes}" if minutes_with_zerro && minutes < 10
      seconds = "0#{seconds}" if seconds < 10
      [hours, "#{minutes}:#{seconds}"].filter((el) -> el).join(':')
