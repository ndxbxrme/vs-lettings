'use strict'

angular.module 'vs-lettings'
.config ($stateProvider) ->
  $stateProvider.state 'forgot',
    url: '/forgot'
    templateUrl: 'routes/forgot/forgot.html'
    controller: 'ForgotCtrl' 
  $stateProvider.state 'forgotResponse',
    url: '/forgot/:token'
    templateUrl: 'routes/forgot/forgot.html'
    controller: 'ForgotCtrl'  