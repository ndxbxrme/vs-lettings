'use strict'

angular.module 'vs-agency'
.controller 'CaseCtrl', ($scope, $stateParams, $state, $timeout, $window, Auth, progressionPopup, Property, Upload, env, alert) ->
  $scope.propsOpts = 
    where:
      RoleStatus: 'OfferAccepted'
      RoleType: 'Letting'
      IncludeStc: true
    transform:
      items: 'Collection'
      total: 'TotalCount'
  $scope.clockStarted = false
  $scope.properties = $scope.list
    route: "#{env.PROPERTY_URL}/search"
  , $scope.propsOpts
  , (properties) ->
    for property in properties.items
      property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}, #{property.Address.Postcode}"
  $scope.notesLimit = 10
  $scope.notesPage = 1
  $scope.property = $scope.single
    route: "#{env.PROPERTY_URL}/property"
  , $stateParams.roleId
  , (res) ->
    property = res.item
    property.displayAddress = "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}, #{property.Address.Postcode}"
    property.$case = $scope.single 'properties', property.RoleId + '_' + new Date(property.AvailableDate).valueOf(), (item) ->
      item.parent.search = "#{item.parent.displayAddress}||#{item.vendor}||#{item.purchaser}"
      item.item.proposedMoving = new Date(item.item.proposedMoving)
      for progression in property.$case.item.progressions
        for branch in progression.milestones
          for milestone in branch
            if milestone.title.toLowerCase() is 'holding deposit'
              if milestone.completed
                timeLeft = (milestone.completedTime + (15 * 24 * 60 * 60 * 1000) - new Date().valueOf()) / 1000
                $scope.showClock = true
                if timeLeft > 0
                  $scope.setTime timeLeft
                  $scope.setCountdown true
                else
                  $scope.setTime -timeLeft
                  $scope.setCountdown false
                $scope.start() if not $scope.clockStarted
                $scope.clockStarted = true
            else if milestone.title.toLowerCase() is 'rental complete'
              if milestone.completed
                $scope.showClock = false
                if $scope.clockStarted
                  $scope.clockStarted = false
                  $scope.stop()
    property.$case.parent = property
    Property.set property
  $scope.progressions = $scope.list 'progressions',
    sort: 'i'
  $scope.stopCallback = ->
    $timeout ->
      if $scope.getTime().time is 0
        $scope.depositOverdue = true
        $scope.setCountdown false
        $scope.start()
  $scope.config =
    prefix: 'swiper'
    modifier: 1.5
    show: false
  $scope.date = 
    date: 'today'
  $scope.submitRT = ->
    if $scope.rentalTerms.$valid
      $scope.rentalTerms.$setPristine()
      $scope.property.item.$case.save()
      .then ->
        alert.log 'Rental terms saved'
      , ->
        alert.error 'Error saving rental terms'
  $scope.addNote = ->
    if $scope.note
      property = $scope.property.item
      if property and property.$case and property.$case.item
        if $scope.note.date
          updateProgressionNotes = (milestones, note) ->
            for branch in milestones
              for milestone in branch
                if milestone.notes and milestone.notes.length
                  for mynote in milestone.notes
                    if mynote.date is note.date and mynote.item is note.item and mynote.side is note.side
                      mynote.text = note.text
                      mynote.updatedAt = new Date()
                      mynote.updatedBy = Auth.getUser()
          if property.$case.item.notes
            for mynote in property.$case.item.notes
              if mynote.date is $scope.note.date and mynote.item is $scope.note.item and mynote.side is $scope.note.side
                mynote.text = $scope.note.text
                mynote.updatedAt = new Date()
                mynote.updatedBy = Auth.getUser()
          for progression in property.$case.item.progressions
            updateProgressionNotes progression.milestones, $scope.note
        else
          property.$case.item.notes.push
            date: new Date()
            text: $scope.note.text
            item: 'Case Note'
            side: ''
            user: Auth.getUser()
        property.$case.save()
        alert.log 'Note added'
        $scope.note = null
  $scope.editNote = (note) ->
    $scope.note = JSON.parse JSON.stringify note
    $('.add-note')[0].scrollIntoView true
  $scope.deleteNote = (note) ->
    property = $scope.property.item
    deleteProgressionNotes = (milestones, note) ->
      for branch in milestones
        for milestone in branch
          if milestone.notes and milestone.notes.length
            for mynote in milestone.notes
              if mynote.date is note.date and mynote.item is note.item and mynote.side is note.side
                return milestone.notes.remove mynote
    if property.$case.item.notes
      for mynote in property.$case.item.notes
        if mynote.date is note.date and mynote.item is note.item and mynote.side is note.side
          property.$case.item.notes.remove mynote
          break
    for progression in property.$case.item.progressions
      deleteProgressionNotes progression.milestones, note
    property.$case.save()
    alert.log 'Note deleted'
    $scope.note = null
  $scope.getNotes = ->
    property = $scope.property.item
    if property and property.$case and property.$case.item
      notes = []
      fetchProgressionNotes = (milestones) ->
        for branch in milestones
          for milestone in branch
            if milestone.notes and milestone.notes.length
              for note in milestone.notes
                notes.push note
      for progression in property.$case.item.progressions
        fetchProgressionNotes progression.milestones
      if property.$case.item.notes and property.$case.item.notes.length
        for note in property.$case.item.notes
          notes.push note
      if $scope.auth.checkRoles ['superadmin', 'admin']
        if property.$case.item.advanceRequests and property.$case.item.advanceRequests.length
          for note in property.$case.item.advanceRequests
            notes.push note
      return notes
  $scope.addProgression = (progression) ->
    property = $scope.property.item
    if property and property.$case and property.$case.item
      if not property.$case.item.progressions
        property.$case.item.progressions = []
      property.$case.item.progressions.push JSON.parse(JSON.stringify(progression)) 
      property.$case.save()
  $scope.addChain = (chain, side) ->
    index = 0
    if side is 'seller'
      index = $scope.property.item.$case.item.chainSeller.length
    chain.push
      note: ''
      reference: ''
      side: side
    $scope.chainEdit = side + index
  $scope.editChain = (side, index) ->
    $scope.chainEdit = side + index
  $scope.saveChain = (item) ->
    if item.property
      for prop in $scope.properties.items
        if prop.RoleId is +item.property
          item.propDetails = objtrans prop,
            id: true
            address: (property) ->
              "#{property.Address.Number} #{property.Address.Street }, #{property.Address.Locality }, #{property.Address.Town}"
            image: 'Images[0].Url'
            price: 'Price.PriceValue'
    $scope.chainEdit = null
    $scope.property.item.$case.save()
    alert.log 'Chain saved'
  $scope.deleteChainItem = (item, side) ->
    chain = if side is 'buyer' then $scope.property.item.$case.item.chainBuyer else $scope.property.item.$case.item.chainSeller
    chain.remove item
    $scope.saveChain()
  $scope.uploadFiles = (files, errFiles) ->
    mycase = $scope.property.item.$case
    if files
      Upload.upload
        url: '/api/upload'
        data:
          file: files
          user: Auth.getUser()
      .then (response) ->
        if response.data
          $scope.uploadProgress = 0
          if not mycase.item.documents
            mycase.item.documents = []
          for document in response.data
            mycase.item.documents.push document
          alert.log 'Document uploaded'
          mycase.save()
      , (err) ->
        false
      , (progress) ->
        $scope.uploadProgress = Math.min 100, parseInt(100.0 * progress.loaded / progress.total)
  $scope.makeDownloadUrl = (document) ->
    '/api/download/' + btoa "#{JSON.stringify({path:document.path,filename:document.originalFilename})}"
  $scope.saveDocument = (document) ->
    document.editing = false
    alert.log 'Document updated'
    $scope.property.item.$case.save()
  $scope.deleteDocument = (document) ->
    if $window.confirm 'Are you sure you want to delete this document?'
      $scope.property.item.$case.item.documents.splice $scope.property.item.$case.item.documents.indexOf(document), 1
      alert.log 'Document deleted'
      $scope.property.item.$case.save()
  $scope.hideDropdown = (dropdown) ->
    $timeout ->
      $scope[dropdown] = false
    , 200
  $scope.advanceProgression = ->
    $scope.modal
      template: 'advance-progression'
      controller: 'AdvanceProgressionCtrl'
      data:
        property: objtrans $scope.property.item,
          roleId: 'RoleId'
          displayAddress: true
          advanceRequests: '$case.item.advanceRequests'
          progressions: '$case.item.progressions'
    .then ->
      alert.log 'Request submitted'
    , ->
      false
  $scope.applyRequest = (request) ->
    for progression in $scope.property.item.$case.item.progressions
      for branch in progression.milestones
        for milestone in branch
          advanceTo = new Date(request.advanceTo)
          for advMilestone in request.milestones
            if milestone._id is advMilestone._id
              milestone.userCompletedTime = advanceTo.valueOf()
    request.applied = true
    $scope.property.item.$case.save()
  $scope.requestEmail = (to) ->
    name = (ref) -> ref.FirstName + ' ' + ref.LastName
    data = 
      type: to
      property: $scope.property.item.$case.item
    if to is 'Landlord'
      data.toName = name $scope.property.item.$case.item.Landlord
      data.toMail = $scope.property.item.$case.item.Landlord.PrimaryEmail?.Value
      data.refName = name $scope.property.item.$case.item.Tenants[0].Person
    else
      data.toName = name $scope.property.item.$case.item.Tenants[0].Person
      data.toMail = $scope.property.item.$case.item.Tenants[0].Person.PrimaryEmail?.Value
      data.refName = name $scope.property.item.$case.item.Landlord
    $scope.modal
      template: 'request-email'
      controller: 'RequestEmailCtrl'
      data: data
    .then ->
    , ->
  $scope.fallenThrough = ->
    if window.confirm 'Are you sure you want to flag this property as Fallen through?'
      $scope.property.item.$case.item.override = $scope.property.item.$case.override or {}
      $scope.property.item.$case.item.override.deleted = true
      $scope.property.item.$case.item.override.reason = 'fallenThrough'
      $scope.property.item.$case.save()
      $state.go 'cases'
  $scope.$on '$destroy', ->
    progressionPopup.hide()