'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'dashboardItem',
    url: '/dashboard-item/:id/:type'
    templateUrl: 'routes/dashboard-item/dashboard-item.html'
    controller: 'DashboardItemCtrl'
    data:
      title: 'Vitalspace Conveyancing - Dashboard Item'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['admin','superadmin'])