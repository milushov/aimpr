###*
 # @ngdoc function
 # @name aimprApp.controller:FriendsCtrl
 # @description
 # # FriendsCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'FriendsCtrl', ['$scope', '$interval', 'API', ($scope, $interval, API) ->
    friends_count = 0

    console.info('FriendsCtrl')

    angular.extend $scope,
      per_page:   10/2
      cur_page:   1
      per_part:   15
      cur_part:   1
      is_loading: false


    renderPage = (dir) ->
      max_page = Math.ceil(friends_count / $scope.per_page)

      if dir is 'next'
        if $scope.cur_page < max_page
          $scope.cur_page += 1
        else
          $scope.cur_page = 1

      else if dir is 'prev'
        if $scope.cur_page > 1
          $scope.cur_page -= 1
        else
          $scope.cur_page = max_page

      start = $scope.per_page * ($scope.cur_page - 1)
      end   = start + $scope.per_page - 1
      $scope.rendered_friends = $scope.friends[start..end]


    getFriends = () ->
      prms = {
        count:  $scope.per_part
        offset: $scope.per_part * ($scope.cur_part - 1)
      }

      API.getFriends(788157, prms).then (friends) ->
        friends_count = friends_count || friends.count
        $scope.friends = ($scope.friends || []).concat(friends.items)

        renderPage('cur')
        $scope.cur_part += 1
        $scope.$apply()


    getFriends()


    $scope.showPart = (direction) ->
      renderPage(direction)
      getFriends() if isAlmostLastPage()


    isAlmostLastPage = ->
      last_page = Math.ceil($scope.friends.length / $scope.per_page) - 1
      $scope.cur_page is last_page


    searchFriendsByName = (name) ->
      regexp = new RegExp(name, 'gim')
      $scope.friends.filter (friend) ->
        regexp.test(friend.first_name) || regexp.test(friend.last_name)


    $scope.getFriendsByName = (name) ->
      if name.length > 1
        if $scope.friends.length <= friends_count
          $scope.friends = $scope.friends[0..$scope.per_part]
          request_count = Math.ceil(friends_count/$scope.per_part) - 1
          cur_part = 1
          stop_time = $interval ->
            prms = {
              count:  $scope.per_part
              offset: $scope.per_part * (cur_part - 1)
            }

            API.getFriends(788157, prms).then (friends) ->
              $scope.friends = $scope.friends.concat(friends.items)

              if request_count is 0
                $interval.cancel(stop_time)
                $scope.rendered_friends = searchFriendsByName(name)
                return

              cur_part += 1
              request_count -= 1
          , 400
        else
          $scope.rendered_friends = searchFriendsByName(name)

      else
        renderPage('cur')

    $scope.showUserTracks = (id) ->
      $scope.$emit('showUserTracks', id)


    return


  ]
