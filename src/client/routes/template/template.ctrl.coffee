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
    displayAddress: "26 Chervil Close, Fallowfield, Manchester, M14 7DP"
    text: marked "## Advance Progression Request  \n#### Milestone  \n`Searches Completed`  \n#### Advance to  \n`Wed May 24 2017`  \n#### Requested by  \n`Dawn Wetherill`  \n#### Reason  \nA reason  \n"
    link: "https://lettings.vitalspace.co.uk/case/10993717"
    applicant:
      title: "Mr"
      firstName: "Richard"
      lastName: "Antrobus"
      terms: "12"
      movingInDate: "2019-01-15T00:00:00.000Z"
      rent: "1000"
    marketing:
      address: "67 Little Bolton Terrace, Salford"
      availableDate: "2019-01-15T00:00:00.000Z"
      tendDate: "2019-01-15T00:00:00.000Z"
      rent: "1000"
      terms: "12"
      pStatus: "Furnished"
      access: "A load of text about the access details"
      repairs: "A load of text about repairs"
      lfees: "Managed"
      tfamount: "200"
      mamount: "200"
      ma: "5"
      board: "Yes"
      windowcard: "Yes"
      epc: "Yes"
      gas: "Yes"
  fetchDefaultProp = ->
    $http.post "#{env.PROPERTY_URL}/search",
      RoleStatus: 'OfferAccepted'
      RoleType: 'Letting'
      IncludeStc: true
      PageSize: 1
    .then (response) ->
      if response.data and response.data.Collection and response.data.Collection.length
        $scope.defaultData.property = response.data.Collection[0]
        $http.get "/api/properties/#{$scope.defaultData.property.RoleId + '_' + new Date($scope.defaultData.property.AvailableDate).valueOf()}"
        .then (response) ->
          if response.data
            $scope.defaultData.property.case = response.data
            $scope.defaultData.contact = response.data.vendorsContact
  fetchDefaultProp()