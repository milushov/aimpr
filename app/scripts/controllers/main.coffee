# @ngdoc function
# @name aimprApp.controller:MainCtrl
# @description
# MainCtrl
# Controller of the aimprApp

angular.module('aimprApp', [])
  .controller 'trackList', ['$scope', 'VK', 'Q', ($scope, VK, Q) ->
    deferred = Q.defer()

    VK.then (vk) ->
      vk.api 'friends.get',
        fields: 'uid,first_name,last_name,photo'
        user_id: 788157
        count: 5
        (data) ->
          console.log(data)
          deferred.resolve(data.response)

    #deferred.promise
  ]

#angular.module('aimprApp')
  #.controller('MainCtrl', function ($scope) {
    #$scope.awesomeThings = [
      #'HTML5 Boilerplate',
      #'AngularJS',
      #'Karma'
    #];
  #});
