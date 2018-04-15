'use strict'

angular.module 'vs-agency'
.factory 'progressionPopup', ($timeout, $http, Property, Auth, alert) ->
  elem = null
  progressions = []
  data = null
  property = null
  hidden = true
  scope = null
  reset = ->
    if scope
      scope.action = null
      scope.editingAction = false
  getOffset = (elm) ->
    offset =
      left: 0
      top: 0
    while elm and elm.tagName isnt 'BODY'
      offset.left += elm.offsetLeft
      offset.top += elm.offsetTop
      elm = elm.offsetParent
    offset
  moveToElem = ->
    if elem
      offset = getOffset(elem)
      elemLeft = offset.left
      offset.top += elem.clientHeight
      popupWidth = $('.progression-popup').width()
      if offset.left + (popupWidth + 20) > window.innerWidth
        offset.left = window.innerWidth - (popupWidth + 10)
      offset.left -= 20
      if offset.left < 2
        offset.left = 2
      if window.innerWidth < 410
        offset.left = 2
      $('.progression-popup').css offset
      pointerLeft = elemLeft - offset.left + 10
      pointerDisplay = 'block'
      if pointerLeft + 40 > popupWidth
        pointerDisplay = 'none'
      $('.progression-popup .pointer').css
        left: pointerLeft
        display: pointerDisplay
  window.addEventListener 'resize', moveToElem
  show: (_elem, _data, _property) ->
    elem = _elem
    data = _data
    property = _property
    ###
    if data.title is 'Start' and not data.completed
      data.completed = true
      data.startTime = new Date().valueOf()
      data.completedTime = new Date().valueOf()
      dezrez.updatePropertyCase Auth.getUser(), true
    else
    ###
    reset()
    moveToElem()
    hidden = false
  hide: ->
    hidden = true
  getHidden: ->
    hidden
  getTitle: ->
    if data
      data.title
  getCompleted: ->
    if data
      data.completed
  setCompleted: ->
    if data
      hidden = true
      $http.post '/api/milestone/completed',
        milestone: data._id
        roleId: Property.get().RoleId
      alert.log 'Milestone updated'
  getCompletedTime: ->
    if data
      data.completedTime
  getProgressing: ->
    if data
      data.progressing
  setProgressing: ->
    if data
      hidden = true
      $http.post '/api/milestone/start',
        milestone: data._id
        roleId: Property.get().RoleId
      alert.log 'Milestone started'
  getDate: ->
    if data
      data.userCompletedTime or data.estCompletedTime
  setDate: (date) ->
    if data
      data.userCompletedTime = date
      alert.log 'Milestone updated'
      Property.get().$case.save()
  getStartDate: ->
    if data
      if data.startTime
        return new Date(data.startTime)
      else
        return new Date()
  getEstDays: ->
    if data
      data.estDays + ' ' + if data.estDays is 1 then 'day' else 'days'
  addNote: (note) ->
    if data and note
      data.notes.push
        date: new Date()
        text: note
        item: data.title
        side: data.side
        user: Auth.getUser()
      alert.log 'Note saved'
      Property.get().$case.save()
      note = ''
  getNotes: ->
    if data
      data.notes
  getData: ->
    data
  getProperty: ->
    property
  setProgressions: (_progressions) ->
    progressions = _progressions
  getProgressions: ->
    progressions
  setScope: (_scope) ->
    scope = _scope
  reset: reset