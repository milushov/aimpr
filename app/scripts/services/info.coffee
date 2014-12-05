###*
 # @ngdoc service
 # @name aimprApp.info
 # @description
 # # info
 # Service in the aimprApp.
###
angular.module('aimprApp')
  .service 'Info', ['$location', ($location) ->
    params       = $location.search()
    @viewer_id   = parseInt(params.viewer_id)
    @user_id     = parseInt(if params.user_id is '0' then params.viewer_id else params.user_id)
    @audio_count = JSON.parse(params.api_result).response.audio_count
  ]
