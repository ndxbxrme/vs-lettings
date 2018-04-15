'use strict'

angular.module 'vs-lettings'
.controller 'InvitedCtrl', ($scope, $state, $stateParams, $http) ->
  code = $stateParams.code
  $scope.acceptInvite = ->
    if $scope.repeatPassword is $scope.newUser.local.password
      $http.post '/invite/accept', 
        code: decodeURIComponent code
        user: $scope.newUser
      .then (response) ->
        if response.data is 'OK'
          $scope.auth.logOut()
          .then ->
            $state.go 'dashboard'
          , (err) ->
            false
      , (err) ->
        false
    else
      $scope.error = 'Passwords must match'