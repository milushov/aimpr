###*
 # @ngdoc service
 # @name aimprApp.helpers
 # @description
 # # helpers
 # Factory in the aimprApp.
###
angular.module('aimprApp')
  .service 'ViewHelpers', ['$routeParams', 'VK', ($routeParams, VK) ->

    @isTrackView = ->
      !!$routeParams.trackId

    @resizeIFrame = ->
      body = document.querySelector('body')
      body.style.height = 'auto'
      rect = body.getBoundingClientRect()
      body.style.height = "#{rect.height}px"

      VK.then (vk) ->
        vk.callMethod 'resizeWindow', rect.width, rect.height
        return

      console.info('iframe resized')
      return

    return
  ]
