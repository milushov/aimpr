'use strict'

###*
 # @ngdoc directive
 # @name aimprApp.directive:wtf
 # @description
 # # wtf
###
angular.module('aimprApp')
  .directive 'wtf', ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.click() unless localStorage['wtf_read']
