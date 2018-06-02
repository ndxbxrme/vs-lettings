'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'cases',
    url: '/cases'
    templateUrl: 'routes/cases/cases.html'
    controller: 'CasesCtrl'
    data:
      title: 'Vitalspace Lettings - Cases'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])