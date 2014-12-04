###*
 # @ngdoc service
 # @name aimprApp.info
 # @description
 # # info
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'Info', ['$location', ($location) ->

    params = $location.search()

    api_result  = JSON.parse(params.api_result)
    @audio_count = api_result.response.audio_count
    @viewer_id = params.viewer_id
  ]
