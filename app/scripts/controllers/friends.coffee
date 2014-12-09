###*
 # @ngdoc function
 # @name aimprApp.controller:FriendsCtrl
 # @description
 # # FriendsCtrl
 # Controller of the aimprApp
###
angular.module('aimprApp')
  .controller 'FriendsCtrl', ['$scope', '$interval', 'API', 'Info', ($scope, $interval, API, Info) ->
    console.info('FriendsCtrl')
    friends_count = 0
    per_page = 7
    cur_page = 1
    per_part = 15
    cur_part = 1
    $scope.getPerPage = -> cur_page
    $scope.search = name: ''
    $scope.is_loading = no # for getFriendsByName
    is_all_friends_loaded = no
    $scope.user_id = Info.user_id
    $scope.viewer_id = Info.viewer_id

    $scope.$watch (-> Info.user_id), (new_val) -> $scope.user_id = new_val
    $scope.$watch (-> Info.viewer_id), (new_val) -> $scope.viewer_id = new_val


    renderPage = (dir) ->
      max_page = Math.ceil(friends_count / per_page)

      if dir is 'next'
        if cur_page < max_page
          cur_page += 1
        else
          cur_page = 1

      start = per_page * (cur_page - 1)
      end   = start + per_page - 1
      $scope.rendered_friends = $scope.friends[start..end]


    getFriends = () ->
      prms = {
        count:  per_part
        offset: per_part * (cur_part - 1)
      }

      API.getFriends(788157, prms).then (friends) ->
        friends_count = friends_count || friends.count
        $scope.friends = ($scope.friends || []).concat(friends.items)

        renderPage('cur')
        cur_part += 1
        $scope.$apply()


    getFriends()


    $scope.showPart = (direction) ->
      renderPage(direction)
      getFriends() if isAlmostLastPage() && !is_all_friends_loaded


    isAlmostLastPage = ->
      last_page = Math.ceil($scope.friends.length / per_page) - 1
      cur_page is last_page


    searchFriendsByName = (name) ->
      regexp = new RegExp(name, 'gim')
      filter = (friend) ->
        regexp.test(friend.first_name) || regexp.test(friend.last_name)
      $scope.friends.filter(filter)[..9]


    search_name = ''
    $scope.getFriendsByName = (name) ->
      search_name = name
      return console.info('loading friends for searching..') if $scope.is_loading

      if name.length > 0
        if $scope.friends.length < friends_count
          $scope.rendered_friends = searchFriendsByName(name)

          $scope.is_loading = yes
          $scope.friends = $scope.friends[0..per_part-1]
          request_count = Math.ceil(friends_count/per_part) - 1
          cur_part = 2

          stop_time = $interval ->
            if request_count is 0
              $interval.cancel(stop_time)
              $scope.rendered_friends = searchFriendsByName(search_name)
              $scope.is_loading = no
              is_all_friends_loaded = yes
              return

            prms = {
              count:  per_part
              offset: per_part * (cur_part - 1)
            }

            API.getFriends(788157, prms).then (friends) ->
              $scope.friends = $scope.friends.concat(friends.items)
              cur_part += 1
              request_count -= 1
          , 333
        else
          $scope.rendered_friends = searchFriendsByName(name)

      else
        renderPage('cur')

    $scope.showUserTracks = (id) ->
      $scope.$emit('showUserTracks', id)


    return


  ]
