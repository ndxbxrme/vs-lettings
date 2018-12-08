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
    tenantCopy = null
    scope.edit = (tenant) ->
      tenantCopy = JSON.parse JSON.stringify tenant
      tenant.editing = true
    scope.data = ->
      property = scope.$parent.property
      if property and property.item and property.item.$case and property.item.$case.item
        return property.item.$case.item.Tenants
    scope.confirm = (tenant) ->
      #save to database
      scope.$parent.property.item.$case.save()
      alert.log 'Contact details updated'
      tenant.editing = false
    scope.cancel = (tenant) ->
      if tenantCopy
        Object.assign tenant, tenantCopy
        tenantCopy = null
      tenant.editing = false