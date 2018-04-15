'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'case',
    url: '/case/:roleId'
    templateUrl: 'routes/case/case.html'
    controller: 'CaseCtrl'
    data:
      title: 'Vitalspace Conveyancing - Case'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])