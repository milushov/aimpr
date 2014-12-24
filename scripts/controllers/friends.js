
/**
  * @ngdoc function
  * @name aimprApp.controller:FriendsCtrl
  * @description
  * # FriendsCtrl
  * Controller of the aimprApp
 */
angular.module('aimprApp').controller('FriendsCtrl', [
  '$scope', '$interval', 'API', 'Info', function($scope, $interval, API, Info) {
    var cur_page, cur_part, friends_count, getFriends, isAlmostLastPage, is_all_friends_loaded, per_page, per_part, renderPage, searchFriendsByName, search_name;
    console.info('FriendsCtrl');
    friends_count = 0;
    per_page = 7;
    cur_page = 1;
    per_part = 15;
    cur_part = 1;
    $scope.getPerPage = function() {
      return cur_page;
    };
    $scope.search = {
      name: ''
    };
    $scope.is_loading = false;
    is_all_friends_loaded = false;
    $scope.user_id = Info.user_id;
    $scope.viewer_id = Info.viewer_id;
    $scope.$watch((function() {
      return Info.user_id;
    }), function(new_val) {
      return $scope.user_id = new_val;
    });
    $scope.$watch((function() {
      return Info.viewer_id;
    }), function(new_val) {
      return $scope.viewer_id = new_val;
    });
    renderPage = function(dir) {
      var end, max_page, start;
      max_page = Math.ceil(friends_count / per_page);
      if (dir === 'next') {
        if (cur_page < max_page) {
          cur_page += 1;
        } else {
          cur_page = 1;
        }
      }
      start = per_page * (cur_page - 1);
      end = start + per_page - 1;
      return $scope.rendered_friends = $scope.friends.slice(start, +end + 1 || 9e9);
    };
    getFriends = function() {
      var prms;
      prms = {
        count: per_part,
        offset: per_part * (cur_part - 1)
      };
      return API.getFriends(788157, prms).then(function(friends) {
        friends_count = friends_count || friends.count;
        $scope.friends = ($scope.friends || []).concat(friends.items);
        renderPage('cur');
        cur_part += 1;
        return $scope.$apply();
      });
    };
    getFriends();
    $scope.showPart = function(direction) {
      renderPage(direction);
      if (isAlmostLastPage() && !is_all_friends_loaded) {
        return getFriends();
      }
    };
    isAlmostLastPage = function() {
      var last_page;
      last_page = Math.ceil($scope.friends.length / per_page) - 1;
      return cur_page === last_page;
    };
    searchFriendsByName = function(name) {
      var filter, regexp;
      regexp = new RegExp(name, 'gim');
      filter = function(friend) {
        return regexp.test(friend.first_name) || regexp.test(friend.last_name);
      };
      return $scope.friends.filter(filter).slice(0, 10);
    };
    search_name = '';
    $scope.getFriendsByName = function(name) {
      var request_count, stop_time;
      search_name = name;
      if ($scope.is_loading) {
        return console.info('loading friends for searching..');
      }
      if (name.length > 0) {
        if ($scope.friends.length < friends_count) {
          $scope.rendered_friends = searchFriendsByName(name);
          $scope.is_loading = true;
          $scope.friends = $scope.friends.slice(0, +(per_part - 1) + 1 || 9e9);
          request_count = Math.ceil(friends_count / per_part) - 1;
          cur_part = 2;
          return stop_time = $interval(function() {
            var prms;
            if (request_count === 0) {
              $interval.cancel(stop_time);
              $scope.rendered_friends = searchFriendsByName(search_name);
              $scope.is_loading = false;
              is_all_friends_loaded = true;
              return;
            }
            prms = {
              count: per_part,
              offset: per_part * (cur_part - 1)
            };
            return API.getFriends(788157, prms).then(function(friends) {
              $scope.friends = $scope.friends.concat(friends.items);
              cur_part += 1;
              return request_count -= 1;
            });
          }, 333);
        } else {
          return $scope.rendered_friends = searchFriendsByName(name);
        }
      } else {
        return renderPage('cur');
      }
    };
    $scope.showUserTracks = function(id) {
      return $scope.$emit('showUserTracks', id);
    };
  }
]);
