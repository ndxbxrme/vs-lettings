'use strict'

angular.module 'vs-lettings'
.controller 'RequestEmailCtrl', ($scope, $http, data, ndxModalInstance) ->
  $scope.forms = {}
  $scope.data = 
    type: data.type
    property: data.property
    toName: ''
    toMail: ''
    refName: ''
    refMail: ''
  $scope.submit = ->
    $scope.submitted = true
    if $scope.forms.myform.$valid
      $http.post '/api/properties/send-request-email', $scope.data
      ndxModalInstance.dismiss()
  $scope.cancel = ->
    ndxModalInstance.dismiss()