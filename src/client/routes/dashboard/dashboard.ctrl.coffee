'use strict'

angular.module 'vs-lettings'
.controller 'DashboardCtrl', ($scope, env) ->
  $scope.page = 1
  $scope.limit = 15
  $scope.pageChange = ->
    $('html, body').animate
      scrollTop: 0
    , 200
  $scope.nodeleted = 0
  $scope.propsOpts = 
    where:
      RoleStatus: 'OfferAccepted'
      RoleType: 'Letting'
      IncludeStc: true
    transform:
      items: 'Collection'
      total: 'TotalCount'
  $scope.properties = $scope.list
    route: "#{env.PROPERTY_URL}/search"
  , $scope.propsOpts