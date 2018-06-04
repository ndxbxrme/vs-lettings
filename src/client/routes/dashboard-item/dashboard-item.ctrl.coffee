'use strict'

angular.module 'vs-agency'
.controller 'DashboardItemCtrl', ($scope, $stateParams, $window, alert) ->
  $scope.type = $stateParams.type
  $scope.dashboardItem = $scope.single 'dashboard', $stateParams.id, (item) ->
    if item
      $scope.dashboardItem.locked = true
  $scope.progressions = $scope.list 'progressions',
    sort: 'i'
  $scope.getMilestones = ->
    if $scope.progressions and $scope.progressions.items and $scope.dashboardItem and $scope.dashboardItem.item
      for progression in $scope.progressions.items
        if progression._id is $scope.dashboardItem.item.progression
          output = []
          for branch in progression.milestones
            output.push branch[0]
          return output
  $scope.save = ->
    $scope.dashboardItem.item.type = $scope.type
    $scope.dashboardItem.save()
    alert.log 'Dashboard item saved'
    $window.history.go -1
  $scope.cancel = ->
    $window.history.go -1