'use strict'

angular.module 'vs-agency'
.controller 'ProfileCtrl', ($scope, Auth) ->
  $scope.profile = $scope.single 'users', Auth.getUser()._id