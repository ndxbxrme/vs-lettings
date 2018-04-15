'use strict'

angular.module 'vs-agency'
.factory 'Property', ->
  property = null
  get: ->
    property
  set: (prop) ->
    property = prop