'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'available',
    url: '/available'
    templateUrl: 'routes/available/available.html'
    controller: 'AvailableCtrl'
    data:
      title: 'Vitalspace Lettings - Available'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])