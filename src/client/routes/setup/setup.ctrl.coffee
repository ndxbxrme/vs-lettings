'use strict'

angular.module 'vs-agency'
.controller 'SetupCtrl', ($scope, $http, $filter, $timeout, progressionPopup, alert) ->
  $scope.editor = true
  $scope.newUser =
    role: 'agency'
  $scope.progressions = $scope.list 'progressions', 
    sort: 'i'
  , (progressions) ->
    progressionPopup.setProgressions progressions.items
  $scope.users = $scope.list 'users'
  $scope.emailTemplates = $scope.list 'emailtemplates'
  $scope.smsTemplates = $scope.list 'smstemplates'
  $scope.dashboard = $scope.list 'dashboard'
  $scope.getProperty = ->
    Address:
      Number: 123
      Street: 'My Street'
      Locality: 'My Locality'
      Town: 'My Town'
  $scope.addUser = ->
    $scope.newUser.roles = {}
    $scope.newUser.roles[$scope.newUser.role] = {}
    delete $scope.newUser.role
    $http.post '/api/get-invite-code', $scope.newUser
    .then (response) ->
      $scope.inviteUrl = response.data
      alert.log 'Invite sent'
    , (err) ->
      $scope.inviteError = err.data
    $scope.newUser =
      role: 'agency'
  $scope.copyInviteToClipboard = ->
    $('.invite-url input').select()
    alert.log 'Copied to clipboard'
    document.execCommand 'copy'
  $scope.addProgression = ->
    $scope.progressions.save
      name: 'New progression'
      side: 'Buyer'
      milestones: [
        [{
          title: 'Start'
          _id: $scope.generateId 8
          actions: []
        }]
      ]
  $scope.resetProgressions = ->
    $http.get '/api/properties/reset-progressions'
    .then (response) ->
      alert.log 'Progressions reset'
  saveDashboard = ->
    for di, i in $filter('orderBy')($filter('filter')($scope.dashboard.items, {type:'overview'}), 'i')
      di.i = i
      $scope.dashboard.save di
    for di, i in $filter('orderBy')($filter('filter')($scope.dashboard.items, {type:'income'}), 'i')
      di.i = i
      $scope.dashboard.save di
    alert.log 'Dashboard saved'
  $scope.moveDIUp = (di) ->
    $timeout ->
      di.i -= 1.1
      #$scope.dashboard.items.moveUp di
      $timeout saveDashboard
  $scope.moveDIDown = (di) ->
    $timeout ->
      di.i += 1.1
      #$scope.dashboard.items.moveDown di
      $timeout saveDashboard
  $scope.removeDI = (di) ->
    $scope.dashboard.delete di
    $scope.dashboard.items.remove di
    saveDashboard()
    
    