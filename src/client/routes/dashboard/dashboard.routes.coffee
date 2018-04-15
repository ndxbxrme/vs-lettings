'use strict'

angular.module 'vs-lettings'
.config ($stateProvider) ->
  $stateProvider
  .state 'dashboard',
    url: '/'
    templateUrl: 'routes/dashboard/dashboard.html'
    controller: 'DashboardCtrl'
    data:
      title: 'Dashboard'