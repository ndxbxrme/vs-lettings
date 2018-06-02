'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'case',
    url: '/case/:roleId'
    templateUrl: 'routes/case/case.html'
    controller: 'CaseCtrl'
    data:
      title: 'Vitalspace Lettings - Case'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])