###*
 # @ngdoc service
 # @name aimprApp.helpers
 # @description
 # # helpers
 # Factory in the aimprApp.
###
angular.module('aimprApp')
  .service 'ViewHelpers', ['$document', 'VK', '$timeout', ($document, VK, $timeout) ->

    @resizeIFrame = ->
      body = $document[0].querySelector('body')
      rect = body.getBoundingClientRect()
      diff = 15
      TIMEOUT = 200

      $timeout ->
        VK.then (vk) ->
          vk.callMethod('resizeWindow', rect.width, rect.height + diff)
      , TIMEOUT

    return
  ]
