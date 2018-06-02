'use strict'

angular.module 'vs-agency'
.config ($stateProvider) ->
  $stateProvider.state 'profile',
    url: '/profile'
    templateUrl: 'routes/profile/profile.html'
    controller: 'ProfileCtrl'
    data:
      title: 'Vitalspace Lettings - Profile'
    resolve:
      user: (Auth) ->
        Auth.getPromise(['agency','admin','superadmin'])