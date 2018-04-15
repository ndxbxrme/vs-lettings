'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'solicitors',
    url: '/solicitors'
    templateUrl: 'routes/solicitors/solicitors.html'
    controller: 'SolicitorsCtrl'
    data:
      title: 'solicitors'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])