'use strict'

angular.module 'vs-lettings'
.controller 'ForgotCtrl', ($scope, $http, $state, $stateParams) ->
  $scope.token = $stateParams.token
  $scope.newUser = {}
  $scope.forgotUser = {}
  $scope.myForm = {}
  $scope.repeatPassword = ''
  $scope.submitEmail = ->
    $scope.submitted = true
    if $scope.myForm.$valid
      $http.post '/get-forgot-code',
        email: $scope.forgotUser.item.email
      .then (response) ->
        $scope.codeRequested = true
  $scope.submitPass = ->
    console.log 'submit', $scope.repeatPassword, $scope.newUser.local.password, $scope.myForm.$valid
    $scope.submitted = true
    if $scope.myForm.$valid
      console.log 'valid'
      if $scope.repeatPassword is $scope.newUser.local.password
        console.log 'passwords match'
        $http.post "/forgot-update/#{$scope.token}",
          password: $scope.newUser.local.password
        .then (response) ->
          if response.data is 'OK'
            $state.go 'dashboard'
        , (err) ->
          false
      else
        $scope.error = 'Passwords must match'