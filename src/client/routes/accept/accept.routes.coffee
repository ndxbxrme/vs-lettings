'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'accept',
    url: '/accept'
    templateUrl: 'routes/accept/accept.html'
    controller: 'AcceptCtrl'
    data:
      title: 'Vitalspace Lettings - Acceptance'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency', 'admin', 'superadmin'])