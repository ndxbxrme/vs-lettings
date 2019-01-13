'use strict'

angular.module 'vs-agency'
.controller 'AcceptCtrl', ($scope, env, $http) ->
  $scope.propsOpts = 
    where:
      RoleStatus: 'InstructionToLet'
      RoleType: 'Letting'
      IncludeStc: true
    transform:
      items: 'Collection'
      total: 'TotalCount'
  $scope.properties = $scope.list
    route: "#{env.PROPERTY_URL}/search"
  , $scope.propsOpts
  
  $scope.submit = ->
    $scope.submitted = true
    console.log $scope.property
    return
    if $scope.acceptForm.$valid
      $http.post '/api/properites/send-accept-email',
        property: $scope.property
        applicant: $scope.applicant