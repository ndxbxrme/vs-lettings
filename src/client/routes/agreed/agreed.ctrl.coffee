'use strict'

angular.module 'vs-agency'
.controller 'AgreedCtrl', ($scope, $filter, $timeout, $http) ->
  $scope.now = new Date().valueOf()
  $scope.years = []
  y = new Date().getFullYear() + 1
  while y-- > 2017
    $scope.years.push y
  updateMonths = ->
    return
    $scope.months = []
    testDate = new Date($scope.startDate['startDate'])
    while testDate < $scope.endDate['startDate']
      month =
        date: testDate
        month: $filter('date')(testDate, 'MMMM')
        properties: []
        target:
          type: 'letAgreed'
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
    res = await $http.post "/api/agreed/search",
      startDate: $scope.startDate.startDate
      endDate: $scope.endDate.startDate
    $timeout ->
      $scope.months = res.data
      $scope.months.forEach (month) ->
        month.month = $filter('date')(month.date, 'MMMM')
  $scope.targets = $scope.list 'targets',
    where:
      type: 'salesAgreed'
  , updateTargets
  $scope.properties = $scope.list 'properties',
    sort: 'proposedMoving'
    sortDir: 'ASC'
    pageSize: 1
  , () ->
    updateProperties()
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