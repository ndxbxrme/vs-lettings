'use strict'

angular.module 'vs-lettings'
.controller 'DashboardCtrl', ($scope, $filter, $timeout, env) ->
  $scope.propsOpts = 
    where:
      delisted: false
  $scope.properties = $scope.list 'properties', 
    where:
      Status: 'OfferAccepted'
      delisted: false
  , (properties) ->
    i = properties.items.length
    while i-- > 0
      property = properties.items[i]
      if property.override and property.override.deleted
        properties.items.splice i, 1
        continue
      completeBeforeDelisted = false
      if property.progressions and property.progressions.length
        progression = property.progressions[0]
        milestone = progression.milestones[progression.milestones.length-1]
        completeBeforeDelisted = (not milestone[0].completed && property.delisted) || not property.delisted
      property.completeBeforeDelisted = completeBeforeDelisted
  $scope.availableOpts = 
    where:
      RoleStatus: 'InstructionToLet'
      RoleType: 'Letting'
      IncludeStc: true
    transform:
      items: 'Collection'
      total: 'TotalCount'
  $scope.available= $scope.list
    route: "#{env.PROPERTY_URL}/search"
  , $scope.availableOpts
  $scope.dashboard = $scope.list 'dashboard',
    sort: 'i'
  $scope.buyerProgression = null
  $scope.progressions = $scope.list 'progressions', null, (progressions) ->
    for progression in progressions.items
      if progression.side is 'Tenant'
        $scope.buyerProgression = progression
  $scope.count = (di, list) ->
    output = []
    count = 0
    minIndex = 0
    maxIndex = 100
    if $scope.properties and $scope.properties.items and $scope.progressions and $scope.progressions.items
      for progression in $scope.progressions.items
        if progression._id is di.progression
          for branch, b in progression.milestones
            for milestone in branch
              if milestone._id is di.minms
                minIndex = b
              if milestone._id is di.maxms
                maxIndex = b
                break
      for property in $scope.properties.items
        if property and property.milestoneIndex and angular.isDefined(property.milestoneIndex[di.progression])
          if property.override?.deleted
            continue
          if minIndex <= property.milestoneIndex[di.progression] <= maxIndex
            propertyGood = true
            if di.min and di.max
              propertyGood = false
              for progression in property.progressions
                if progression._id is di.progression
                  for branch in progression.milestones
                    for milestone in branch
                      if milestone._id is di.minms or milestone._id is di.maxms
                        if di.min <= milestone.estCompletedTime <= di.max
                          propertyGood = true
            if propertyGood
              if list
                output.push property
              count++
    if list
      output
    else
      count
  $scope.total = (items) ->
    total = 0
    if items
      for item in items
        total += $scope.count item
    total
  $scope.income = (di, month, list) ->
    count = 0
    output = []
    if $scope.properties and $scope.properties.items
      for property in $scope.properties.items
        if property.override?.deleted
          continue
        if property and property.progressions and property.completeBeforeDelisted
          for progression in property.progressions
            if progression._id is di.progression
              for branch in progression.milestones
                for milestone in branch
                  if milestone._id is di.minms
                    if month.start <= milestone.estCompletedTime <= month.end
                      value = 0
                      if di.status is 'Due'
                        if not milestone.completed
                          value += property.role.Commission
                      if di.status is 'Completed'
                        if milestone.completed
                          value += property.role.Commission
                      if di.status is 'Started'
                        if milestone.started and not milestone.completed
                          value += property.role.Commission
                      if di.sumtype is 'Income'
                        count += value
                      else
                        if value
                          count++
                      if value and list
                        output.push property
                      break
              break
    if list
      output
    else if di.sumtype is 'Income'
      $filter('currency')(count, '£', 2)
    else
      count
  $scope.showInfo = (type, di, month) ->
    list = null
    if type is 'count'
      list = $scope.count di, true
    else
      list = $scope.income di, month, true
    if list.length
      $scope.modal
        template: 'dashboard-income'
        controller: 'DashboardIncomeCtrl'
        data:
          di: di
          month: month
          list: list
      .then ->
        true
      , ->
        false
  monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  $scope.months = []
  now = new Date()
  bmonth = new Date now.getFullYear(), now.getMonth() - 1
  $scope.allmonths =
    start: bmonth.valueOf()
    end: 0
  i = 0
  while i++ < 5
    month = {
      name: monthNames[bmonth.getMonth()]
      start: bmonth.valueOf()
      end: 0
    }
    bmonth.setMonth(bmonth.getMonth() + 1)
    month.end = bmonth.valueOf() - 1
    $scope.months.push month
  $scope.allmonths.end = bmonth.valueOf()