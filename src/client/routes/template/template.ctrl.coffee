'use strict'

angular.module 'vs-agency'
.controller 'TemplateCtrl', ($scope, $stateParams, $state, $http, env) ->
  $scope.type = $stateParams.type
  cb = (template) ->
    if template
      $scope.template.locked = true
  if $stateParams.type is 'email'
    $scope.lang = 'jade'
    $scope.template = $scope.single 'emailtemplates', $stateParams.id, cb
  else
    $scope.lang = 'text'
    $scope.template = $scope.single 'smstemplates', $stateParams.id, cb
  $scope.save = ->
    if $scope.myForm.$valid
      $scope.template.save()
      $state.go 'setup'
  $scope.cancel = ->
    $state.go 'setup'
    
  $scope.defaultData = 
    displayAddress: "Apt 19 St Lawrence Street, Hulme, Manchester, M15 4DY"
    text: marked "## Advance Progression Request  \n#### Milestone  \n`Searches Completed`  \n#### Advance to  \n`Wed May 24 2017`  \n#### Requested by  \n`Dawn Wetherill`  \n#### Reason  \nA reason  \n"
    link: "https://conveyancing.vitalspace.co.uk/case/4653108"
  fetchDefaultProp = ->
    $http.post "#{env.PROPERTY_URL}/search",
      RoleStatus: 'OfferAccepted'
      RoleType: 'Letting'
      IncludeStc: true
      PageSize: 1
    .then (response) ->
      if response.data and response.data.Collection and response.data.Collection.length
        $scope.defaultData.property = response.data.Collection[0]
        $http.get "/api/properties/#{$scope.defaultData.property.RoleId}"
        .then (response) ->
          if response.data
            $scope.defaultData.property.case = response.data
            $scope.defaultData.contact = response.data.vendorsContact
  fetchDefaultProp()