###*
 # @ngdoc service
 # @name aimprApp.helpers
 # @description
 # # helpers
 # Factory in the aimprApp.
###
angular.module('aimprApp')
  .service 'ViewHelpers', ['$document', 'VK', ($document, VK) ->

    @resizeIFrame = ->
      body = $document[0].querySelector('body')
      body.style.height = 'auto'
      rect = body.getBoundingClientRect()
      body.style.height = "#{rect.height}px"

      diff = 15

      VK.then (vk) ->
        vk.callMethod 'resizeWindow', rect.width, rect.height + diff

    return
  ]
