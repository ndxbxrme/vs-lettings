'use strict'

angular.module 'vs-agency'
.controller 'AcceptCtrl', ($scope, env) ->
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