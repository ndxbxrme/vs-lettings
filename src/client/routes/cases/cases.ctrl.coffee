'use strict'

angular.module 'vs-agency'
.controller 'CasesCtrl', ($scope, env) ->
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
  , (properties) ->
    for property in properties.items
      property.$case = $scope.single 'properties', property.RoleId + '_' + new Date(property.AvailableDate).valueOf(), (item) ->
        console.log item
        item.$parent.search = "#{item.item.displayAddress}||#{item.item.TenantName}||#{item.item.LandlordName}"
        item.$parent.milestoneStatus = item.item.milestoneStatus
        if item.item.progressions and item.item.progressions.length
          item.$parent.estCompletedTime = item.item.progressions[0].milestones[item.item.progressions[0].milestones.length-1][0].estCompletedTime
        if item.$parent.estCompletedTime < new Date().valueOf()
          item.$parent.needsDate = true
        item.$parent.deleted = item.item.override?.deleted or false
        if item.$parent.deleted
          $scope.nodeleted++
      property.$case.$parent = property
  $scope.hasRequest = (property) ->
    if $scope.auth.checkRoles(['superadmin', 'admin']) and property.$case.item and property.$case.item.advanceRequests and property.$case.item.advanceRequests.length
      for request in property.$case.item.advanceRequests
        if not request.dismissed and not request.applied
          return true
    return false