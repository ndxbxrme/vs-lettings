'use strict'

angular.module 'vs-agency'
.directive 'contactDetails', (alert) ->
  restrict: 'EA'
  templateUrl: 'directives/contact-details/contact-details.html'
  replace: true
  scope:
    title: '@'
  link: (scope, elem, attrs) ->
    scope.editing = false
    fieldName = scope.title
    propCopy = null
    scope.edit = ->
      propCopy = JSON.parse JSON.stringify scope.data()
      scope.editing = true
    scope.data = ->
      property = scope.$parent.property
      if property and property.item and property.item.$case and property.item.$case.item
        if not property.item.$case.item[fieldName]
          property.item.$case.item[fieldName] = {}
        return property.item.$case.item[fieldName]
    scope.confirm = ->
      #save to database
      scope.$parent.property.item.$case.save()
      alert.log 'Contact details updated'
      scope.editing = false
    scope.cancel = ->
      if propCopy
        property = scope.data()
        Object.assign property, propCopy
        propCopy = null
      scope.editing = false