'use strict'

angular.module 'vs-agency'
.directive 'progression', (progressionPopup, $timeout, $http, alert) ->
  restrict: 'AE'
  templateUrl: 'directives/progression/progression.html'
  replace: true
  link: (scope, elem) ->
    lastEditing = false
    saveAllProgressions = ->
      for progression, i in scope.progressions.items
        progression.i = i
        scope.progressions.save progression
    scope.editing = ->
      editing = scope.progressions.$editing is scope.progression._id
      if editing isnt lastEditing
        lastEditing = editing
        scope.resize()
      editing
    drawConnection = (ctx, item, prev) ->
      ctx.beginPath()
      if item.offsetLeft > prev.offsetLeft
        ctx.moveTo item.offsetLeft + (item.clientWidth / 2) - 20, item.offsetTop + 20
        ctx.lineTo prev.offsetLeft + (prev.clientWidth / 2) + 20, prev.offsetTop + 20
      else
        ctx.moveTo prev.offsetLeft + (prev.clientWidth / 2) + 20, prev.offsetTop + 20
        ctx.lineTo prev.offsetLeft + (prev.clientWidth / 2) + 40, prev.offsetTop + 20

      ctx.strokeStyle = '#999999'
      ctx.stroke()
    resize = (elem) ->      
      $timeout ->
        c = $('canvas', elem)
        p = $('.milestones', elem)
        ctx = c[0].getContext '2d'
        c[0].width = p[0].clientWidth
        c[0].height = p[0].clientHeight
        items = $('.milestone', elem)
        for item in items
          prev = $(item).prev()[0]
          if $(item).parent().hasClass('branch')
            prev = $(item).parent().prev()[0]
          if prev
            if $(prev).hasClass('milestone')
              drawConnection ctx, item, prev
            else if $(prev).hasClass('branch')
              branchItems = $('.milestone', prev)
              for branchItem in branchItems
                drawConnection ctx, item, branchItem
    index = 0
    scope.getIndex = ->
      index++
    scope.addMilestone = (branch) ->
      if not branch
        branch = []
        scope.progression.milestones.push branch
      branch.push
        _id: scope.generateId 8
        title: 'New Milestone'
        notes: []
        todos: []
        actions: []
        estDays: 0
      scope.resize()
    scope.saveProgression = ->
      progressionPopup.hide()
      scope.progressions.save(scope.progression)
      scope.progressions.$editing = null
      alert.log 'Progression saved'
      scope.resize()
    scope.cancel = ->
      progressionPopup.hide()
      scope.progressions.refreshFn()
      scope.progressions.$editing = null
      scope.resize()
    scope.edit = ->
      scope.progressions.refreshFn()
      scope.progressions.$editing = scope.progression._id
      scope.resize()
    scope.remove = ->
      if scope.property
        scope.property.item.$case.item.progressions.remove scope.progression
        scope.property.item.$case.save()
      else if scope.progressions
        scope.progressions.delete scope.progression
        scope.progressions.items.remove scope.progression
        saveAllProgressions()
    scope.moveUp = ->
      if scope.property
        scope.property.item.$case.item.progressions.moveUp scope.progression
        scope.property.item.$case.save()
      else if scope.progressions
        scope.progressions.items.moveUp scope.progression
        saveAllProgressions()
    scope.moveDown = ->
      if scope.property
        scope.property.item.$case.item.progressions.moveDown scope.progression
        scope.property.item.$case.save()
      else if scope.progressions
        scope.progressions.items.moveDown scope.progression
        saveAllProgressions()
    scope.resize = ->
      resize elem
    scope.resize()
    window.addEventListener 'resize', scope.resize
    scope.$on '$destroy', ->
      window.removeEventListener 'resize', scope.resize