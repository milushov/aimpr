app = angular.module('aimpr', [])

app
  .value('Q', Q)
  .factory 'VK', ['Q', (Q) ->
    deferred = Q.defer()
    VK.init -> deferred.resolve VK
    deferred.promise
  ]

app.controller 'trackList', ['$scope', 'VK', 'Q', ($scope, VK, Q) ->
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

