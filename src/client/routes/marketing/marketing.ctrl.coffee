'use strict'

angular.module 'vs-agency'
.controller 'MarketingCtrl', ($scope, env, $http) ->
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
    if $scope.marketingEmail.$valid
      $http.post '/api/properties/send-marketing-email',
        marketing: $scope.marketing
      .then ->
        $scope.emailSent = true