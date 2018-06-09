'use strict'

angular.module 'vs-agency'
.controller 'AgreedCtrl', ($scope, $filter, $timeout, $http) ->
  $scope.now = new Date().valueOf()
  $scope.years = []
  y = new Date().getFullYear() + 1
  while y-- > 2017
    $scope.years.push y
  updateMonths = ->
    $scope.months = []
    testDate = new Date($scope.startDate['startDate'])
    while testDate < $scope.endDate['startDate']
      month =
        date: testDate
        month: $filter('date')(testDate, 'MMMM')
        properties: []
        target:
          type: 'salesAgreed'
          value: 0
          date: testDate
        search: ''
      $scope.months.push month
      testDate = new Date(testDate.getFullYear(), testDate.getMonth() + 1, testDate.getDate())
  $scope.startDate =
    startDate: 0
  $scope.endDate =
    startDate: 0
  $scope.setDateRange = (year) ->
    $scope.currentYear = year
    $timeout ->
      $scope.startDate.startDate = new Date(year, 0, 1).valueOf()
      $scope.endDate.startDate = new Date(year + 1, 0, 1).valueOf()
      updateMonths()
      updateProperties()
  $scope.setDateRange $scope.years[0]
  updateTargets = ->
    if $scope.targets and $scope.targets.items and $scope.targets.items.length
      for target in $scope.targets.items
        for month in $scope.months
          if new Date(target.date).toLocaleString() is month.date.toLocaleString()
            month.target = target
            break
  updateProperties = ->
    for month in $scope.months
      month.properties = []
      month.commission = 0
    if $scope.properties and $scope.properties.items
      for property in $scope.properties.items
        i = $scope.months.length
        while i-- > 0
          month = $scope.months[i]
          if $scope.endDate.startDate > new Date(property.EstimatedStartDate) > month.date
            completeBeforeDelisted = false
            if property.progressions and property.progressions.length
              progression = property.progressions[0]
              milestone = progression.milestones[progression.milestones.length-1]
              completeBeforeDelisted = (not milestone[0].completed && property.delisted) || not property.delisted
            property.override = property.override or {}
            if not property.override.deleted
              month.commission += +property.override.commission or property.Fees.DefaultValue
              month.properties.push
                _id: property._id
                address: property.override.address or ("#{property.offer.Property.Address.Number} #{property.offer.Property.Address.Street}, #{property.offer.Property.Address.Locality}")
                commission: property.override.commission or property.Fees.DefaultValue
                date: property.override.date or property.EstimatedStartDate
                roleId: property.roleId
                delisted: property.delisted
                completeBeforeDelisted: completeBeforeDelisted
            break
  $scope.targets = $scope.list 'targets',
    where:
      type: 'salesAgreed'
  , updateTargets
  $scope.properties = $scope.list 'properties',
    sort: 'EstimatedStartDate'
    sortDir: 'ASC'
  , updateProperties
  console.log $scope.properties.args
  $scope.open = (selectedMonth) ->
    open = selectedMonth.open
    for month in $scope.months
      month.open = false
    selectedMonth.open = not open
  $scope.edit = (property) ->
    if not property.$override
      property.$override =
        address: property.address
        commission: property.commission
        date: property.date
    $timeout ->
      property.$editing = true
  $scope.delete = (property) ->
    $http.post "/api/properties/#{property._id}",
      override:
        deleted: true
  $scope.save = (property) ->
    $http.post "/api/properties/#{property._id}",
      override: property.$override
  $scope.cancel = (property) ->
    property.$editing = false
  $scope.saveTarget = (month) ->
    $http.post "/api/targets/#{month.target._id or ''}", month.target
    month.editing = false