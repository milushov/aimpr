'use strict'

###*
 # @ngdoc directive
 # @name aimprApp.directive:postRender
 # @description
 # # postRender
###
angular.module('aimprApp')
  .directive('postRender', ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.$emit attrs.postRender
  )
