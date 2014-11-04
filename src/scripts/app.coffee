app = angular.module('aimpr', [])

app.factory 'vk', ->
  auth = ->
    console.log('vk.auth')

  getTracks = ->
    [ {
      id: 314585455,
      artist: 'Moby',
      title: 'Extreme ways',
      duration: 251,
    }, {
      id: 314585087,
      artist: 'Дэниел Хойт',
      title: 'Серый фон',
      duration: 2592,
    } ]

  auth: auth
  getTracks: getTracks

app.controller 'trackList', ['$scope', 'vk', ($scope, vk) ->
    $scope.tracks = vk.getTracks()
    vk.auth()
    $scope.makeLulz = ->
      console.log('lulz')
  ]

