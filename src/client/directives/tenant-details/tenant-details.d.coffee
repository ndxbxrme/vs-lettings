'use strict'

angular.module 'vs-agency'
.directive 'tenantDetails', (alert) ->
  restrict: 'EA'
  templateUrl: 'directives/tenant-details/tenant-details.html'
  replace: true
  scope:
    title: '@'
  link: (scope, elem, attrs) ->
    scope.editing = false
    fieldName = scope.title
    scope.edit = ->
      scope.editing = true
    scope.data = ->
      property = scope.$parent.property
      if property and property.item and property.item.$case and property.item.$case.item
        return property.item.$case.item.Tenants
    scope.confirm = ->
      #save to database
      scope.$parent.property.item.$case.save()
      alert.log 'Contact details updated'
      scope.editing = false