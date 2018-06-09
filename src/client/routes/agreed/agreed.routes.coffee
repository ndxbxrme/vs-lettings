'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'agreed',
    url: '/agreed'
    templateUrl: 'routes/agreed/agreed.html'
    controller: 'AgreedCtrl'
    data:
      title: 'Vitalspace Lettings - Agreed'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])